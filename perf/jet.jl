using ArgParse, JET, Test, BenchmarkTools, DiffEqBase, ClimaTimeSteppers
import ClimaTimeSteppers as CTS
function parse_commandline()
    s = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table s begin
        "--problem"
        help = "Problem type [`ode_fun`, `fe`]"
        arg_type = String
        default = "ode_fun"
    end
    parsed_args = ArgParse.parse_args(ARGS, s)
    return (s, parsed_args)
end
(s, parsed_args) = parse_commandline()
cts = joinpath(dirname(@__DIR__));
include(joinpath(cts, "test", "problems.jl"))
function config_integrators(problem)
    algorithm = CTS.IMEXARKAlgorithm(ARS343(), NewtonsMethod(; max_iters = 2))
    dt = 0.01
    integrator = DiffEqBase.init(problem, algorithm; dt)
    integrator.cache = CTS.cache(problem, algorithm)
    return (; integrator)
end
prob = if parsed_args["problem"]=="ode_fun"
    split_linear_prob_wfact_split()
elseif parsed_args["problem"]=="fe"
    split_linear_prob_wfact_split_fe()
else
    error("Bad option")
end
(; integrator) = config_integrators(prob)

JET.@test_opt CTS.step_u!(integrator, integrator.cache)

