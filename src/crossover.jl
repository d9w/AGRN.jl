export crossover

function onepoint_crossover(parent1::GRN, parent2::GRN)
    point = rand(1:max(length(parent1), length(parent2)))
    order = rand()
    if rand(Bool)
        p1 = parent1
        p2 = parent2
    else
        p1 = parent2
        p2 = parent1
    end
    point = min(min(point, length(p1)), length(p2)-1)
    ids = [p1.ids[1:point]; p2.ids[point+1:end]]
    enh = [p1.enh[1:point]; p2.enh[point+1:end]]
    inh = [p1.inh[1:point]; p2.inh[point+1:end]]
    nreg = length(ids) - p1.nin - p1.nout
    beta = parent1.beta
    if rand(Bool)
        beta = parent2.beta
    end
    delta = parent1.delta
    if rand(Bool)
        delta = parent2.delta
    end
    GRN(p1.nin, p1.nout, nreg, ids, enh, inh, beta, delta)
end

function crossover(parent1::GRN, parent2::GRN, config::Config)
    eval(config.crossover)(parent1, parent2)
end
