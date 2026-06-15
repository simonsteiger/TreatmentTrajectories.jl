
# Intervals {#Intervals}

Every [`Treatment`](/api#TreatmentTrajectories.Treatment) spans an [`AbstractInterval`](/api#TreatmentTrajectories.AbstractInterval). There are two: [`StoppedInterval`](/api#TreatmentTrajectories.StoppedInterval) (closed, has a [`stop`](/api#TreatmentTrajectories.stop-Tuple{StoppedInterval}) and a [`duration`](/api#TreatmentTrajectories.duration-Tuple{StoppedInterval})) and [`OngoingInterval`](/api#TreatmentTrajectories.OngoingInterval) (open above — no stop, no duration). The split removes `missing`-branching: instead of a nullable stop date, you ask [`is_stopped`](/api#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}) and only then call [`stop`](/api#TreatmentTrajectories.stop-Tuple{StoppedInterval}).

```julia
using TreatmentTrajectories, Dates

s = StoppedInterval(Date(2024,1,1), Date(2024,3,1))
o = OngoingInterval(Date(2024,1,1))

(is_stopped(s), is_ongoing(o), duration(s))
```


```ansi
(true, true, Day(60))
```


Date membership uses `in`; the upper bound is open for an ongoing interval:

```julia
(Date(2024,2,1) in s, Date(2030,1,1) in o)
```


```ansi
(true, true)
```


[`overlaps`](/api#TreatmentTrajectories.overlaps-Tuple{OngoingInterval,%20OngoingInterval}) is commutative and treats an ongoing interval as unbounded above:

```julia
win = StoppedInterval(Date(2024,2,1), Date(2024,2,28))
(overlaps(s, win), overlaps(OngoingInterval(Date(2024,5,1)), win))
```


```ansi
(true, false)
```

