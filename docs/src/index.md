```@raw html
---
layout: home

hero:
  name: "TreatmentTrajectories.jl"
  text: "Tools for working with treatment trajectories"
  tagline: Intervals, treatments, and windowed queries for longitudinal drug data
  actions:
    - theme: brand
      text: Get started
      link: /guides/intervals
    - theme: alt
      text: API reference
      link: /api
    - theme: alt
      text: View on GitHub
      link: https://github.com/simonsteiger/TreatmentTrajectories.jl
---
```

## What is TreatmentTrajectories?

`TreatmentTrajectories` represents a patient's drugs as `Treatment`s, each tied to
an `AbstractInterval` (`OngoingInterval` or `StoppedInterval`). Treatments are
collected into *windows* — a `TreatmentTrajectory` (the whole history), a
`TreatmentEpisode` (a cut over a date range), or a `TreatmentLine` (an
anchored-window cluster). Windows answer queries like "how many modes of action?"
or "is a b/tsDMARD present?".

## Installation

This package is not yet registered. Add it via URL:

```julia
using Pkg
Pkg.add(url = "https://github.com/simonsteiger/TreatmentTrajectories.jl")
```

## Quick example

```@setup quick
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

```@example quick
using TreatmentTrajectories, Dates

traj = TreatmentTrajectory(1, Date(2023,12,1), [
    Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,6,1))),
    Treatment(ADA, OngoingInterval(Date(2024,3,1))),
])

(length(traj), has_btsdmard(traj), count_modes_of_action(traj))
```
