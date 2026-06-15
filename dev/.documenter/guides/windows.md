
# Windows and queries {#Windows-and-queries}

A _window_ is a bag of treatments queryable by drug: the supertype [`AbstractTreatmentWindow`](/api#TreatmentTrajectories.AbstractTreatmentWindow). The whole history is a [`TreatmentTrajectory`](/api#TreatmentTrajectories.TreatmentTrajectory); [`episode`](/api#TreatmentTrajectories.episode-Tuple{Any,%20TreatmentTrajectory,%20AbstractInterval}) and [`lines`](/api#TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}},%20Tuple{T}}%20where%20T) cut it into [`TreatmentEpisode`](/api#TreatmentTrajectories.TreatmentEpisode)s and [`TreatmentLine`](/api#TreatmentTrajectories.TreatmentLine)s. Every window answers [`treatments`](/api#TreatmentTrajectories.treatments-Tuple{AbstractTreatmentWindow}), [`drugs`](/api#TreatmentTrajectories.drugs-Tuple{AbstractTreatmentWindow}), `length`, and `isempty`; antirheumatic windows also answer [`has_btsdmard`](/api#TreatmentTrajectories.has_btsdmard-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}}) and [`count_modes_of_action`](/api#TreatmentTrajectories.count_modes_of_action-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}}).

A trajectory sorts treatments by start and spans their envelope:

```julia
traj = TreatmentTrajectory(7, Date(2023,12,1), [
    Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,6,1))),
    Treatment(ADA, StoppedInterval(Date(2024,3,1), Date(2024,9,1))),
    Treatment(TOF, OngoingInterval(Date(2024,5,1))),
])

(length(traj), is_ongoing(interval(traj)))
```


```ansi
(3, true)
```


The RA-branch queries summarise the drug mix:

```julia
(has_btsdmard(traj), count_modes_of_action(traj))   # ADA (TNFi) + TOF (JAKi) ⇒ 2
```


```ansi
(true, 2)
```

