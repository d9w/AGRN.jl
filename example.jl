# OpenAI gym environment playing in Julia
# Part of the AGRN.jl package

using AGRN
using PyCall

@pyimport gym

function normalize_obs(obs::Array{Float64})
    (atan.(obs) + (pi/2)) / pi
end

function get_actions(outputs::Array{Float64}, amins::Array{Float64}, amaxs::Array{Float64})
    outputs .* (amaxs .- amins) .+ amins
end

function get_actions(outputs::Array{Float64})
    indmax(outputs)
end

function play_env(grn::GRN, env; render::Bool=false)
    env[:seed](0)
    if render
        env[:render](mode="human")
    end
    ob = env[:reset]()
    discrete_actions = false
    if length(env[:action_space][:shape]) == 0
        discrete_actions = true
    else
        amins = Float64.(env[:action_space][:low])
        amaxs = Float64.(env[:action_space][:high])
    end
    total_reward = 0.0
    done = false
    reward = 0.0

    while ~done
        outputs = step!(grn, normalize_obs(ob))
        if discrete_actions
            action = get_actions(outputs)
        else
            action = get_actions(outputs, amins, amaxs)
        end
        try
            ob, reward, done, _ = env[:step](action)
            if render
                env[:render](mode="human")
            end
        catch
            done = true
        end
        total_reward += reward
    end

    total_reward
end

function get_fitness(env_id::String)
    env = gym.make(env_id)
    nin = length(env[:observation_space][:low])
    discrete_actions = false
    if length(env[:action_space][:shape]) == 0
        nout = env[:action_space][:n]
    else
        nout = length(env[:action_space][:low])
    end
    gym_fit = x->play_env(x, env)
    Fitness(nin, nout, gym_fit)
end

# For running interactively

# fitness = get_fitness("MountainCarContinuous-v0")
# config = AGRN.Config()
# maxfit, best = evolve(fitness, config)
