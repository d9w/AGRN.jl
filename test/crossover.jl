using Base.Test
using AGRN

function get_diff(parent::GRN, child::GRN)
    diffs = 0
    for i in 1:100
        inputs = rand(parent.nin)
        parent_outs = step!(parent, inputs)
        child_outs = step!(parent, inputs)
        if any(parent_outs .!= child_outs)
            diffs += 1
        end
    end
    diffs
end

@testset "Crossover tests" begin
    config = AGRN.Config()
    nin = rand(1:10)
    nout = rand(1:10)
    nreg = rand(1:10)
    parent1 = GRN(nin, nout, rand(1:10), config)
    parent2 = GRN(nin, nout, rand(1:10), config)
    child = crossover(parent1, parent2, config)
    @test (child.nin == parent1.nin) && (child.nin == parent2.nin)
    @test (child.nout == parent1.nout) && (child.nout == parent2.nout)
    @test (child.nreg <= max(parent1.nreg, parent2.nreg))
    @test (child.beta == parent1.beta) || (child.beta == parent2.beta)
    @test (child.delta == parent1.delta) || (child.delta == parent2.delta)
    @test get_diff(parent1, child) > 0
    @test get_diff(parent2, child) > 0
    @test distance(parent1, child, config) <= distance(parent1, parent2, config)
    @test distance(parent2, child, config) <= distance(parent1, parent2, config)
end
