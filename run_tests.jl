using AGRN
using Base.Test

info("Chromosome tests")
include("test/chromosome.jl")
info("Mutation tests")
include("test/mutation.jl")
info("Crossover tests")
include("test/crossover.jl")
info("Evolution tests")
include("test/evolution.jl")
