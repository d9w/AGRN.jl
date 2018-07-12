
struct Config
    beta_min::Float64
    beta_max::Float64
    delta_min::Float64
    delta_max::Float64
end

function Config(beta_min=0.02, beta_max=0.5, delta_min=0.02, delta_max=0.5)
    Config(beta_min, beta_max, delta_min, delta_max)
end
