using ClimaTimeSteppers, LinearAlgebra, Test

include(joinpath(@__DIR__, "convergence_utils.jl"))
include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "problems.jl"))

@testset "LSRK and SSP convergence" begin
    dts = 0.5 .^ (4:7)

    for (prob, sol, tscale) in [
        (linear_prob(), linear_sol, 1)
        (sincos_prob(), sincos_sol, 1)
    ]

        @test convergence_order(prob, sol, LSRKEulerMethod(), dts.*tscale)     ≈ 1 atol=0.1
        @test convergence_order(prob, sol, LSRK54CarpenterKennedy(), dts.*tscale)       ≈ 4 atol=0.05
        @test convergence_order(prob, sol, LSRK144NiegemannDiehlBusch(),  dts.*tscale)   ≈ 4 atol=0.05

        @test convergence_order(prob, sol, SSPRK22Heuns(), dts.*tscale)                 ≈ 2 atol=0.05
        @test convergence_order(prob, sol, SSPRK22Ralstons(), dts.*tscale)              ≈ 2 atol=0.05
        @test convergence_order(prob, sol, SSPRK33ShuOsher(), dts.*tscale)              ≈ 3 atol=0.05
        @test convergence_order(prob, sol, SSPRK34SpiteriRuuth(), dts.*tscale)          ≈ 3 atol=0.05
    end

    for (prob, sol, tscale) in [
        (linear_prob_wfactt(), linear_sol, 1)
    ]
        @test convergence_order(prob, sol, SSPKnoth(linsolve=linsolve_direct), dts.*tscale) ≈ 2 atol=0.05

    end


    # ForwardEulerODEFunction
    for (prob, sol, tscale) in [
        (linear_prob_fe(), linear_sol, 1)
        (sincos_prob_fe(), sincos_sol, 1)
    ]
        @test convergence_order(prob, sol, SSPRK22Heuns(), dts.*tscale)                 ≈ 2 atol=0.05
        @test convergence_order(prob, sol, SSPRK22Ralstons(), dts.*tscale)              ≈ 2 atol=0.05
        @test convergence_order(prob, sol, SSPRK33ShuOsher(), dts.*tscale)              ≈ 3 atol=0.05
        @test convergence_order(prob, sol, SSPRK34SpiteriRuuth(), dts.*tscale)          ≈ 3 atol=0.05

    end
end

ENV["GKSwstype"] = "nul" # avoid displaying plots

@testset "IMEX ARK Algorithms" begin
    tab1 = (ARS111, ARS121)
    tab2 = (ARS122, ARS232, ARS222, IMKG232a, IMKG232b, IMKG242a, IMKG242b)
    tab2 = (tab2..., IMKG252a, IMKG252b, IMKG253a, IMKG253b, IMKG254a)
    tab2 = (tab2..., IMKG254b, IMKG254c, HOMMEM1)
    tab3 = (ARS233, ARS343, ARS443, IMKG342a, IMKG343a, DBM453)
    tabs = [tab1..., tab2..., tab3...]
    test_algs("IMEX ARK", tabs, ark_analytic_nonlin_test(Float64), 400)
    test_algs("IMEX ARK", tabs, ark_analytic_sys_test(Float64), 60)
    test_algs("IMEX ARK", tabs, ark_analytic_test(Float64), 16000; super_convergence=ARS121)
end

@testset "New IMEX ARK Algorithms" begin
    tabs = [NewARS343]
    test_algs("IMEX ARK", tabs, ark_analytic_nonlin_test, 400)
    test_algs("IMEX ARK", tabs, ark_analytic_sys_test, 60)
    test_algs("IMEX ARK", tabs, ark_analytic_test, 16000)
end

#=
if ArrayType == Array
for (prob, sol) in [
    imex_autonomous_prob => imex_autonomous_sol,
    #imex_nonautonomous_prob => imex_nonautonomous_sol,
]
# IMEX
    @test convergence_order(prob, sol, ARK1ForwardBackwardEuler(linsolve=DirectSolver), dts)       ≈ 1 atol=0.1
    @test convergence_order(prob, sol, ARK2ImplicitExplicitMidpoint(linsolve=DirectSolver), dts)   ≈ 2 atol=0.05
    @test convergence_order(prob, sol, ARK2GiraldoKellyConstantinescu(linsolve=DirectSolver), dts) ≈ 2 atol=0.05
    @test convergence_order(prob, sol, ARK2GiraldoKellyConstantinescu(linsolve=DirectSolver; paperversion=true), dts) ≈ 2 atol=0.05
    @test convergence_order(prob, sol, ARK437L2SA1KennedyCarpenter(linsolve=DirectSolver), dts)    ≈ 4 atol=0.05
    @test convergence_order(prob, sol, ARK548L2SA2KennedyCarpenter(linsolve=DirectSolver), dts)    ≈ 5 atol=0.05
end
end
for (prob, sol) in [
    imex_autonomous_prob => imex_autonomous_sol,
    imex_nonautonomous_prob => imex_nonautonomous_sol,
    # kpr_multirate_prob => kpr_sol,
]
    # Multirate
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),LSRK54CarpenterKennedy()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 4 atol=0.05
    # MIS
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),MIS2()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 2 atol=0.05
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),MIS3C()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 2 atol=0.05
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),MIS4()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 3 atol=0.05
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),MIS4a()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 3 atol=0.05
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),TVDMISA()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 2 atol=0.05
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),TVDMISB()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 2 atol=0.05

    # Wicker Skamarock
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),WSRK2()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 2 atol=0.05
    @test convergence_order(prob, sol, Multirate(LSRK54CarpenterKennedy(),WSRK3()), dts;
        fast_dt = 0.5^12, adjustfinal=true) ≈ 2 atol=0.05


    end
=#