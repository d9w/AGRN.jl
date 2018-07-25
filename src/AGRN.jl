module AGRN

using Logging

include("config.jl")
include("chromosome.jl")
include("mutation.jl")
include("crossover.jl")
include("evolution.jl")

end
