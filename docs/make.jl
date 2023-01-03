using Documenter, DocumenterCitations
using ClimaTimeSteppers

bib = CitationBibliography(joinpath(@__DIR__, "refs.bib"))


#! format: off
pages = [
    "index.md",
    "Algorithm formulations" => [
        "algo_formulations/lsrk.md",
        "algo_formulations/ssprk.md",
        "algo_formulations/ark.md",
        "algo_formulations/mrrk.md",
    ],
    "Non-linear solvers" => [
        "Formulation" => "nl_solvers/formulation.md",
        "Newtons method" => "nl_solvers/newtons_method.md",
    ],
    "Test problems" => [
        "index.md",
    ],
    "API docs" => [
        "Algorithms" => "api/algorithms.md",
        "Tableaus" => "api/tableaus.md",
        "Non-linear solvers" => "api/nl_solvers.md",
        "Callbacks" => "api/callbacks.md",
    ],
    "Algorithm comparisons" => "algo_comparisons.md",
    "Developer docs" => [
        "Types" => "dev/types.md",
        "Report generator" => "dev/report_gen.md",
    ],
    "references.md",
]
#! format: on

makedocs(
    bib,
    sitename = "ClimaTimeSteppers",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [ClimaTimeSteppers],
    checkdocs = :exports,
    clean = true,
    strict = true,
    pages = pages,
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/CliMA/ClimaTimeSteppers.jl.git",
    target = "build",
    push_preview = true,
    devbranch = "main",
    forcepush = true,
)
