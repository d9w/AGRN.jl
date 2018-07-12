
function mutate_add(parent::GRN)
    ids = [copy(parent.ids); rand()]
    enh = [copy(parent.enh); rand()]
    inh = [copy(parent.inh); rand()]
    nreg = parent.nreg + 1
    GRN(parent.nin, parent.nout, nreg, ids, enh, inh, parent.beta, parent.delta)
end

function mutate_delete(parent::GRN)
    to_remove = rand((parent.nin+parent.nout+1):length(parent.ids))
    ids = deleteat!(copy(parent.ids), to_remove)
    enh = deleteat!(copy(parent.enh), to_remove)
    inh = deleteat!(copy(parent.inh), to_remove)
    nreg = parent.nreg - 1
    GRN(parent.nin, parent.nout, nreg, ids, enh, inh, parent.beta, parent.delta)
end

function mutate_modify(parent::GRN, config::Config)
    target = rand(1:(length(parent.ids)+2))
    ids = copy(parent.ids); enh = copy(parent.enh); inh = copy(parent.inh)
    beta = parent.beta; delta = parent.delta
    if target <= length(parent.ids)
        tag = rand(1:3)
        if tag == 1
            ids[target] = rand()
        elseif tag == 2
            enh[target] = rand()
        else
            inh[target] = rand()
        end
    elseif target == (length(parent.ids) + 1)
        beta = rand() * (config.beta_max - config.beta_min) + config.beta_min
    else
        delta = rand() * (config.delta_max - config.delta_min) + config.delta_min
    end
    GRN(parent.nin, parent.nout, parent.nreg, ids, enh, inh, beta, delta)
end

function mutate(parent::GRN, config::Config)
    mutation = rand()
    if mutation < config.mutate_add_rate
        child = mutate_add(parent)
    elseif (mutation < (config.mutate_add_rate + config.mutate_delete_rate) &&
            length(parent.ids) > (parent.nin + parent.nout))
        child = mutate_delete(parent)
    else
        child = mutate_modify(parent, config)
    end
    child
end

