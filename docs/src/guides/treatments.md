# Treatments

A [`Treatment`](@ref) pairs a drug with an [`AbstractInterval`](@ref) and an
optional stop `reason` (defaulting to `missing`). Drugs come from
DrugInterface; here we define a small concrete drug for the examples.

```@setup treatments
using TreatmentTrajectories, DrugInterface, Dates
struct ExampleDrug <: AbstractAntiRheumaticDrug
    name::String; moa::Symbol
    csdmard::Bool; bdmard::Bool; tsdmard::Bool; cortisone::Bool
end
DrugInterface.substance(d::ExampleDrug)      = d.name
DrugInterface.mode_of_action(d::ExampleDrug) = d.moa
DrugInterface.is_csdmard(d::ExampleDrug)     = d.csdmard
DrugInterface.is_bdmard(d::ExampleDrug)      = d.bdmard
DrugInterface.is_tsdmard(d::ExampleDrug)     = d.tsdmard
DrugInterface.is_cortisone(d::ExampleDrug)   = d.cortisone
MTX = ExampleDrug("Methotrexate", :none, true,  false, false, false)
ADA = ExampleDrug("Adalimumab",   :TNFi, false, true,  false, false)
```

```@example treatments
t = Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,4,1)), "side-effects")

(substance(drug(t)), start(t), stop(t), is_ongoing(t))
```

An ongoing treatment omits the reason and has no stop date:

```@example treatments
u = Treatment(ADA, OngoingInterval(Date(2024,2,1)))

(substance(drug(u)), ismissing(u.reason), is_ongoing(u))
```
