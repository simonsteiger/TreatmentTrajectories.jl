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


## What is TreatmentTrajectories? {#What-is-TreatmentTrajectories?}

`TreatmentTrajectories` represents a patient's drugs as `Treatment`s, each tied to an `AbstractInterval` (`OngoingInterval` or `StoppedInterval`). Treatments are collected into _windows_ — a `TreatmentTrajectory` (the whole history), a `TreatmentEpisode` (a cut over a date range), or a `TreatmentLine` (an anchored-window cluster). Windows answer queries like "how many modes of action?" or "is a b/tsDMARD present?".

## Installation {#Installation}

This package is not yet registered. Add it via URL:

```julia
using Pkg
Pkg.add(url = "https://github.com/simonsteiger/TreatmentTrajectories.jl")
```


## Quick example {#Quick-example}

```julia
using TreatmentTrajectories, Dates

traj = TreatmentTrajectory(1, Date(2023,12,1), [
    Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,6,1))),
    Treatment(ADA, OngoingInterval(Date(2024,3,1))),
])

(length(traj), has_btsdmard(traj), count_modes_of_action(traj))
```


```ansi
(2, true, 1)
```

