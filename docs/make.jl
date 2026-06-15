using TreatmentTrajectories
using DrugInterface
using Dates
using Documenter, DocumenterVitepress

# DrugInterface ships only abstract drug types, so the docs define their own
# concrete drug for every example and doctest.
DocMeta.setdocmeta!(
    TreatmentTrajectories,
    :DocTestSetup,
    quote
        using TreatmentTrajectories, DrugInterface, Dates
        struct ExampleDrug <: AbstractAntiRheumaticDrug
            name::String
            moa::Symbol
            csdmard::Bool
            bdmard::Bool
            tsdmard::Bool
            cortisone::Bool
        end
        DrugInterface.substance(d::ExampleDrug) = d.name
        DrugInterface.mode_of_action(d::ExampleDrug) = d.moa
        DrugInterface.is_csdmard(d::ExampleDrug) = d.csdmard
        DrugInterface.is_bdmard(d::ExampleDrug) = d.bdmard
        DrugInterface.is_tsdmard(d::ExampleDrug) = d.tsdmard
        DrugInterface.is_cortisone(d::ExampleDrug) = d.cortisone
        MTX = ExampleDrug("Methotrexate", :none, true, false, false, false)
        ADA = ExampleDrug("Adalimumab", :TNFi, false, true, false, false)
        TOF = ExampleDrug("Tofacitinib", :JAKi, false, false, true, false)
    end;
    recursive = true,
)

makedocs(;
    modules = [TreatmentTrajectories],
    authors = "Simon Steiger",
    repo = "https://github.com/simonsteiger/02_outcomes",
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "github.com/simonsteiger/TreatmentTrajectories.jl",
        devbranch = "main",
        devurl = "dev",
    ),
    pages = [
        "Home" => "index.md",
        "Guides" => [
            "Intervals" => "guides/intervals.md",
            "Treatments" => "guides/treatments.md",
            "Windows & queries" => "guides/windows.md",
            "Episodes & lines" => "guides/episodes-and-lines.md",
        ],
        "API reference" => "api.md",
    ],
    warnonly = false,
)

DocumenterVitepress.deploydocs(;
    repo = "github.com/simonsteiger/TreatmentTrajectories.jl",
    devbranch = "main",
    target=joinpath(@__DIR__, "build"),
    push_preview = true,
)
