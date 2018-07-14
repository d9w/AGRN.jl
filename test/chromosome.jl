using Base.Test
using AGRN

@testset "Chromosome test" begin
    config = AGRN.Config()
    nin = rand(1:10)
    nout = rand(1:10)
    nreg = rand(1:10)
    grn = GRN(nin, nout, nreg, config)
    set_input!(grn, zeros(nin))
    step!(grn, 10)
    @test all(grn.cons[1:nin] .== 0.0)
    new_grn = GRN(grn)
    @test all(new_grn.cons .!= grn.cons)
    reset!(grn)
    @test all(new_grn.cons .== grn.cons)
    for i in 1:100
        inputs = rand(nin)
        step!(grn, inputs)
        step!(new_grn, inputs)
        @test all(new_grn.cons .== grn.cons)
    end
    @test distance(grn, new_grn, config) == 0.0
end

