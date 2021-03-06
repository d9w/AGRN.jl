import Base.length
import JSON
export GRN, reset!, set_input!, get_output, step!, distance

struct GRN
    nin::Int64
    nout::Int64
    nreg::Int64
    ids::Array{Float64}
    enh::Array{Float64}
    inh::Array{Float64}
    beta::Float64
    delta::Float64
    weights::Array{Float64}
    cons::Array{Float64}
end

function get_weights(ids::Array{Float64}, enh::Array{Float64}, inh::Array{Float64},
                     beta::Float64)
    glen = length(ids)
    weights = zeros(length(ids), length(ids))
    for i in eachindex(ids)
        for j in eachindex(ids)
            # influence of i on j (based on excitatory and inhibitory proteins of i)
            weights[i, j] = (exp(-beta * abs(enh[i] - ids[j])) -
                             exp(-beta * abs(inh[i] - ids[j])))
        end
    end
    weights
end

function GRN(nin::Int64, nout::Int64, nreg::Int64, config::Config)
    grn_size = nin + nout + nreg
    ids = rand(grn_size)
    enh = rand(grn_size)
    inh = rand(grn_size)
    beta = rand() * (config.beta_max - config.beta_min) + config.beta_min
    delta = rand() * (config.delta_max - config.delta_min) + config.delta_min
    weights = get_weights(ids, enh, inh, beta)
    cons = ones(grn_size) ./ grn_size
    GRN(nin, nout, nreg, ids, enh, inh, beta, delta, weights, cons)
end

function GRN(nin::Int64, nout::Int64, nreg::Int64, ids::Array{Float64},
             enh::Array{Float64}, inh::Array{Float64},
             beta::Float64, delta::Float64)
    grn_size = nin + nout + nreg
    weights = get_weights(ids, enh, inh, beta)
    cons = ones(grn_size) ./ grn_size
    GRN(nin, nout, nreg, ids, enh, inh, beta, delta, weights, cons)
end

function GRN(grn::GRN)
    grn_size = grn.nin + grn.nout + grn.nreg
    cons = ones(grn_size) ./ grn_size
    weights = get_weights(grn.ids, grn.enh, grn.inh, grn.beta)
    GRN(grn.nin, grn.nout, grn.nreg, copy(grn.ids), copy(grn.enh),
        copy(grn.inh), grn.beta, grn.delta, weights, cons)
end

function GRN(json_repr::String)
    d = JSON.parse(json_repr)
    ids = Array{Float64}(d["ids"])
    enh = Array{Float64}(d["enh"])
    inh = Array{Float64}(d["inh"])
    GRN(d["nin"], d["nout"], d["nreg"], ids, enh, inh, d["beta"], d["delta"])
end

function length(grn::GRN)
    length(grn.ids)
end

function reset!(grn::GRN)
    grn.cons .= 1./length(grn.ids)
end

function set_input!(grn::GRN, input::Array{Float64})
    @assert length(input) == grn.nin
    # @assert all(input .>= 0.0)
    # @assert all(input .<= 1.0)
    for i in eachindex(input)
        grn.cons[i] = input[i]
    end
end

function get_output(grn::GRN)
    grn.cons[grn.nin+(1:grn.nout)]
end

function step!(grn::GRN)
    reg = deepcopy(grn.cons)
    reg[grn.nin+(1:grn.nout)] .= 0.0
    cons = max.(0.0, grn.delta / length(grn.ids) * (reg' * grn.weights))
    sumcons = sum(cons[(grn.nin+1):end])
    if sumcons > 0
        cons = cons ./ sumcons
    end
    for i in (grn.nin+1):length(grn.ids)
        grn.cons[i] = cons[i]
    end
end

function step!(grn::GRN, nsteps::Int64)
    for i in 1:nsteps
        step!(grn)
    end
end

function step!(grn::GRN, inputs::Array{Float64})
    set_input!(grn, inputs)
    step!(grn)
    get_output(grn)
end

function distance(g1::Array{Float64}, g2::Array{Float64})
    # TODO: align regulatory
    dist = 1.0
    if (length(g1) > 0) || (length(g2) > 0)
        if length(g1) > length(g2)
            dist = sum(abs.(g1 - [g2; zeros(length(g1)-length(g2))]))
        elseif length(g1) < length(g2)
            dist = sum(abs.(g2 - [g1; zeros(length(g2)-length(g1))]))
        else
            dist = sum(abs.(g1 .- g2))
        end
    end
    dist
end

function distance(g1::GRN, g2::GRN, config::Config)
    (distance(g1.ids, g2.ids) * config.dist_coef_ids +
     distance(g1.enh, g2.enh) * config.dist_coef_enh +
     distance(g1.inh, g2.inh) * config.dist_coef_inh +
     (abs(g1.beta - g2.beta) / (config.beta_max - config.beta_min)) +
     (abs(g1.delta - g2.delta) / (config.delta_max - config.delta_min)))
end

