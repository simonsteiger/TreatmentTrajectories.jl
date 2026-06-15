# Episodes and lines

Two ways to cut a [`TreatmentTrajectory`](@ref) into smaller windows.

```@setup el
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
RTX = ExampleDrug("Rituximab",    :CD20i,false, true,  false, false)
```

## Episodes

[`episode`](@ref) keeps treatments matching a predicate over a date `window`.
The default is [`started_in`](@ref); pass [`active_in`](@ref) to keep treatments
running through the window.

```@example el
traj = TreatmentTrajectory(1, Date(2023,12,1), [
    Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,8,1))),
    Treatment(ADA, StoppedInterval(Date(2024,4,1), Date(2024,10,1))),
    Treatment(TOF, StoppedInterval(Date(2024,9,1), Date(2025,1,1))),
])
window = StoppedInterval(Date(2024,3,1), Date(2024,5,1))

(substance.(drugs(episode(traj, window))),            # started_in
 substance.(drugs(episode(active_in, traj, window)))) # active_in
```

## Lines

[`lines`](@ref) clusters treatments that begin within `gap` of a line's anchor.
The anchor does not drift, so evenly spaced additions split into separate lines
rather than chaining:

```@example el
base = Date(2024,1,1)
mk(d, day) = Treatment(d, OngoingInterval(base + Day(day)))
chained = TreatmentTrajectory(1, base, [mk(MTX,0), mk(ADA,25), mk(TOF,50), mk(RTX,75)])

map(l -> substance.(drugs(l)), lines(chained; gap = Day(30)))
```
