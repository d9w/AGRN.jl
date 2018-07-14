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

@testset "Mutation tests" begin
    config = AGRN.Config()
    nin = rand(1:10)
    nout = rand(1:10)
    nreg = rand(1:10)
    parent = GRN(nin, nout, nreg, config)
    @testset "Add mutate" begin
        child = AGRN.mutate_add(parent)
        @test child.nin == parent.nin
        @test child.nout == parent.nout
        @test child.beta == parent.beta
        @test child.delta == parent.delta
        @test length(child.ids) == length(parent.ids) + 1
        @test length(child.enh) == length(parent.enh) + 1
        @test length(child.inh) == length(parent.inh) + 1
    end
    @testset "Delete mutate" begin
        child = AGRN.mutate_delete(parent)
        @test child.nin == parent.nin
        @test child.nout == parent.nout
        @test child.beta == parent.beta
        @test child.delta == parent.delta
        @test length(child.ids) == length(parent.ids) - 1
        @test length(child.enh) == length(parent.enh) - 1
        @test length(child.inh) == length(parent.inh) - 1
    end
    @testset "Modify mutate" begin
        child = AGRN.mutate_modify(parent, config)
        @test child.nin == parent.nin
        @test child.nout == parent.nout
        @test length(child.ids) == length(parent.ids)
        @test length(child.enh) == length(parent.enh)
        @test length(child.inh) == length(parent.inh)
        @test get_diff(parent, child) > 0
    end
    @testset "General mutation" begin
        child = mutate(parent, config)
        @test child.nin == parent.nin
        @test child.nout == parent.nout
        @test get_diff(parent, child) > 0
    end
end
