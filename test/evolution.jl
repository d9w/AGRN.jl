using Base.Test
using AGRN
using Logging

config = AGRN.Config()

@testset "Evolution functions" begin
    @testset "tournament" begin
        @test AGRN.tournament([rand()]) == 1
        for i in 2:10
            fits = rand(i)
            winner = AGRN.tournament(fits)
            @test winner >= 1
            @test winner <= i
            @test fits[winner] > minimum(fits)
        end
    end
    @testset "speciation" begin
        distance(a::Float64, b::Float64, config::AGRN.Config) = abs(a-b)
        population = rand(rand(5:15))
        reprs = rand(rand(2:5))
        species = AGRN.speciation(population, reprs, config; dfunc=distance)
        @test length(species) == length(population)
        @test all(species .<= length(reprs))
    end
    @testset "species sizes" begin
        fits = rand(config.ga_population)
        species = rand(1:5, config.ga_population)
        spec_sizes = AGRN.species_sizes(fits, species, config)
        @test length(spec_sizes) == 5
        @test sum(spec_sizes) == config.ga_population
    end
end

@testset "Evolutionary runs" begin
    @testset "Length fit" begin
        function length_fit(ind::GRN)
            length(ind)
        end
        fitness = Fitness(1, 1, length_fit)
        config = AGRN.Config()
        max_fit, best = evolve(fitness, config)
        @test max_fit > (1.0 + 1.0 + 1.0)
        @test length(best) == max_fit
    end
    @testset "sin fit" begin
        function sin_fit(ind::GRN)
            inputs = (sin.(0.0:0.1:5.0) + 1.0) / 2.0
            outs = zeros(length(inputs))
            for i in eachindex(inputs)
                outs[i] = step!(ind, [inputs[i]])[1]
            end
            -sqrt(sum((inputs - outs).^2)/length(inputs))
        end
        fitness = Fitness(1, 1, sin_fit)
        config = AGRN.Config()
        max_fit, best = evolve(fitness, config)
        @test max_fit < 0.0
        rand_grn = GRN(1, 1, 1, config)
        @test sin_fit(best) >= sin_fit(rand_grn)
    end
end
