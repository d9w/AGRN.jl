export Fitness, GRN, evolve

struct Fitness
    nin::Int64
    nout::Int64
    func::Function
    cacheable::Bool
end

function Fitness(nin::Int64, nout::Int64, func::Function)
    Fitness(nin, nout, func, true)
end

function tournament(fits::Array{Float64}; tsize=3)
    # return the index of the winner of a n-way tournament
    if length(fits) == 1
        return 1
    else
        n = min(tsize, length(fits))
        fshuffle = randperm(length(fits))[1:n]
        winner = indmax(fits[fshuffle])
        return fshuffle[winner]
    end
end

function speciation(population::Array, reprs::Array, config::Config;
                    dfunc::Function=AGRN.distance)
    # return a vector of ints corresponding to the species of each individual in population
    ptype = typeof(population[1])
    species = Array{Int64}(length(population))
    for p in eachindex(population)
        distances = Array{Float64}(length(reprs))
        for r in eachindex(reprs)
            distances[r] = dfunc(population[p], reprs[r], config)
        end
        # distances = [distance(population[p], reprs[r]) for r in eachindex(reprs)]
        if minimum(distances) < config.speciation_thresh
            species[p] = indmin(distances)
        else
            species[p] = length(reprs)+1
            append!(reprs, [ptype(population[p])])
        end
    end
    species_set = sort(unique(species))
    for s in eachindex(species_set)
        species[species.==species_set[s]] = s
    end
    species
end

function species_sizes(fits::Array{Float64}, species::Array{Int64}, config::Config)
    nspecies = length(unique(species))
    spec_fits = map(x->mean(fits[species.==x])-minimum(fits), 1:nspecies)
    Logging.debug("spec fits: $spec_fits")
    spec_sizes = map(x->spec_fits[x]/sum(spec_fits), 1:nspecies)
    spec_sizes = spec_sizes./sum(spec_sizes).*config.ga_population
    spec_sizes[isnan.(spec_sizes)] = 0
    spec_sizes = Int64.(round.(spec_sizes))

    while sum(spec_sizes) > config.ga_population
        spec_sizes[indmax(spec_sizes)] -= 1
    end
    while sum(spec_sizes) < config.ga_population
        spec_sizes[indmin(spec_sizes)] += 1
    end
    Logging.debug("spec sizes: $spec_sizes")
    spec_sizes
end

function evolve(fitness::Fitness, config::Config)
    population = Array{GRN}(config.ga_population)
    fits = -Inf*ones(Float64, config.ga_population)
    species = Array{Int64}(config.ga_population)
    for p in eachindex(population)
        if p <= config.init_species
            population[p] = GRN(fitness.nin, fitness.nout, 1, config)
            species[p] = p
        else
            repr = rand(1:config.init_species)
            population[p] = mutate(population[repr], config)
            species[p] = repr
        end
    end
    best = population[1]
    max_fit = -Inf
    eval_count = 0

    for generation in 1:config.ga_num_generations
        # evaluation
        Logging.debug("evaluation $generation")
        new_best = false
        for p in eachindex(population)
            if fits[p] == -Inf
                fit = fitness.func(population[p])
                fits[p] = fit
                eval_count += 1
                if fit > max_fit
                    max_fit = fit
                    best = population[p]
                    new_best = true
                end
            end
        end

        Logging.info(@sprintf("E: %d %d %0.5f %0.5f",
                              generation, eval_count, mean(fits), max_fit))
        if new_best
            Logging.info(@sprintf("B: %d %0.5f|%s", generation, max_fit,
                                  JSON.json(best)))
        end

        # representatives
        Logging.debug("representatives $generation")
        nspecies = length(unique(species))
        reprs = Array{GRN}(nspecies)
        for s in 1:nspecies
            reprs[s] = GRN(population[rand(find(species.==s))])
        end

        # species sizes
        Logging.debug("species sizes $generation $nspecies")
        spec_sizes = species_sizes(fits, species, config)
        new_pop = Array{GRN}(config.ga_population)
        new_fits = -Inf*ones(Float64, config.ga_population)
        popi = 1

        # create new population
        Logging.debug("new population $generation $spec_sizes")
        for s in 1:nspecies
            Logging.debug("species $s")
            sfits = fits[species.==s]
            spec = population[species.==s]
            ncross = round(spec_sizes[s] * config.ga_crossover_rate)
            nmut = round(spec_sizes[s] * config.ga_mutation_rate)
            ncopy = spec_sizes[s] - (ncross+nmut)
            while ncopy < 0
                if nmut > ncross
                    nmut -= 1
                else
                    ncross -= 1
                end
                ncopy = spec_sizes[s] - (ncross+nmut)
            end

            if popi > length(new_pop)
                break
            end

            # crossover
            Logging.debug("Crossover $s popi: $popi, ncross: $ncross")
            for i in 1:ncross
                p1 = spec[tournament(sfits)]
                p2 = spec[tournament(sfits)]
                new_pop[popi] = crossover(p1, p2, config)
                popi += 1
            end

            if popi > length(new_pop)
                break
            end

            # mutation
            Logging.debug("Mutation $s popi: $popi, nmut: $nmut")
            for i in 1:nmut
                parent = spec[tournament(sfits)]
                child = mutate(parent, config)
                if fitness.cacheable
                    if distance(parent, child, config) == 0
                        new_fits[popi] = fits[popi]
                    end
                end
                new_pop[popi] = child
                popi += 1
            end

            if popi > length(new_pop)
                break
            end

            # copy
            Logging.debug("Copy $s popi: $popi, ncopy: $ncopy")
            for i in 1:ncopy
                new_pop[popi] = GRN(spec[tournament(sfits)])
                if fitness.cacheable
                    new_fits[popi] = fits[popi]
                end
                popi += 1
            end

            if popi > length(new_pop)
                break
            end
        end

        Logging.debug("variable set $generation")
        species = speciation(new_pop, reprs, config)
        population = new_pop
        fits = new_fits

        Logging.debug("done $generation")
    end

    max_fit, best
end
