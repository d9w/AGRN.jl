
struct Config
    beta_min::Float64
    beta_max::Float64
    delta_min::Float64
    delta_max::Float64
    mutate_add_rate::Float64
    mutate_delete_rate::Float64
end

function Config(beta_min=0.02, beta_max=0.5, delta_min=0.02, delta_max=0.5,
                mutate_add_rate=0.25, mutate_delete_rate=0.25)
    Config(beta_min, beta_max, delta_min, delta_max, mutate_add_rate, mutate_delete_rate)
end
