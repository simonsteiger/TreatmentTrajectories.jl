# Windows and queries

A *window* is a bag of treatments queryable by drug: the supertype
[`AbstractTreatmentWindow`](@ref). The whole history is a
[`TreatmentTrajectory`](@ref); [`episode`](@ref) and [`lines`](@ref) cut it into
[`TreatmentEpisode`](@ref)s and [`TreatmentLine`](@ref)s. Every window answers
[`treatments`](@ref), [`drugs`](@ref), `length`, and `isempty`; antirheumatic
windows also answer [`has_btsdmard`](@ref) and [`count_modes_of_action`](@ref).

```@setup windows
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
TOF = ExampleDrug("Tofacitinib",  :JAKi, false, false, true,  false)
```

A trajectory sorts treatments by start and spans their envelope:

```@example windows
traj = TreatmentTrajectory(7, Date(2023,12,1), [
    Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,6,1))),
    Treatment(ADA, StoppedInterval(Date(2024,3,1), Date(2024,9,1))),
    Treatment(TOF, OngoingInterval(Date(2024,5,1))),
])

(length(traj), is_ongoing(interval(traj)))
```

The RA-branch queries summarise the drug mix:

```@example windows
(has_btsdmard(traj), count_modes_of_action(traj))   # ADA (TNFi) + TOF (JAKi) ⇒ 2
```
