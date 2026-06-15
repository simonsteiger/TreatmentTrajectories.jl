
# Episodes and lines {#Episodes-and-lines}

Two ways to cut a [`TreatmentTrajectory`](/api#TreatmentTrajectories.TreatmentTrajectory) into smaller windows.

## Episodes {#Episodes}

[`episode`](/api#TreatmentTrajectories.episode-Tuple{Any,%20TreatmentTrajectory,%20AbstractInterval}) keeps treatments matching a predicate over a date `window`. The default is [`started_in`](/api#TreatmentTrajectories.started_in-Tuple{Treatment,%20AbstractInterval}); pass [`active_in`](/api#TreatmentTrajectories.active_in-Tuple{Treatment,%20AbstractInterval}) to keep treatments running through the window.

```julia
traj = TreatmentTrajectory(1, Date(2023,12,1), [
    Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,8,1))),
    Treatment(ADA, StoppedInterval(Date(2024,4,1), Date(2024,10,1))),
    Treatment(TOF, StoppedInterval(Date(2024,9,1), Date(2025,1,1))),
])
window = StoppedInterval(Date(2024,3,1), Date(2024,5,1))

(substance.(drugs(episode(traj, window))),            # started_in
 substance.(drugs(episode(active_in, traj, window)))) # active_in
```


```ansi
(["Adalimumab"], ["Methotrexate", "Adalimumab"])
```


## Lines {#Lines}

[`lines`](/api#TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}},%20Tuple{T}}%20where%20T) clusters treatments that begin within `gap` of a line's anchor. The anchor does not drift, so evenly spaced additions split into separate lines rather than chaining:

```julia
base = Date(2024,1,1)
mk(d, day) = Treatment(d, OngoingInterval(base + Day(day)))
chained = TreatmentTrajectory(1, base, [mk(MTX,0), mk(ADA,25), mk(TOF,50), mk(RTX,75)])

map(l -> substance.(drugs(l)), lines(chained; gap = Day(30)))
```


```ansi
2-element Vector{Vector{String}}:
 ["Methotrexate", "Adalimumab"]
 ["Tofacitinib", "Rituximab"]
```

