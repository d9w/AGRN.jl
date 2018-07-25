# AGRN.jl
Artificial Gene Regulatory Networks and their evolution, in Julia

## Installation

In the Julia REPL, call

```julia
> Pkg.checkout("https://github.com/d9w/AGRN.jl.git")
```

## Testing

Tests are provided to demonstrate use. To run all tests, simply call

```bash
$ julia run_tests.jl
```

## Usage

Unless you're making changes to the AGRN model, it's recommended to run in the
Julia REPL to avoid compilation on each call. An example script using the OpenAI
gym benchmark set has been provided. This script can take some time to compile
due to the use of the [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) library.
If you are missing python packages for running this script, check out
the [Conda.jl](https://github.com/JuliaPy/Conda.jl) package.

```julia
> include("example.jl");
> fitness = get_fitness("MountainCarContinuous-v0");
> config = AGRN.Config();
> maxfit, best = evolve(fitness, config)
```
