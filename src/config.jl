
struct Config
    beta_min::Float64
    beta_max::Float64
    delta_min::Float64
    delta_max::Float64
    mutate_add_rate::Float64
    mutate_delete_rate::Float64
    dist_coef_ids::Float64
    dist_coef_enh::Float64
    dist_coef_inh::Float64
    crossover::Symbol
    speciation_thresh::Float64
    init_species::Int64
    ga_population::Int64
    ga_crossover_rate::Float64
    ga_mutation_rate::Float64
    ga_num_generations::Int64
end

function Config(;beta_min=0.02, beta_max=0.5, delta_min=0.02, delta_max=0.5,
                mutate_add_rate=0.25, mutate_delete_rate=0.25,
                dist_coef_ids=0.75, dist_coef_enh=0.25, dist_coef_inh=0.25,
                crossover=:onepoint_crossover, speciation_thresh=0.15,
                init_species=20, ga_population=100, ga_crossover_rate=0.25,
                ga_mutation_rate=0.5, ga_num_generations=10)
    Config(beta_min, beta_max, delta_min, delta_max, mutate_add_rate, mutate_delete_rate,
           dist_coef_ids, dist_coef_enh, dist_coef_inh, crossover, speciation_thresh,
           init_species, ga_population, ga_crossover_rate, ga_mutation_rate,
           ga_num_generations)
end
