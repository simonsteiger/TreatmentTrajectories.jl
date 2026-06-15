# Intervals

Every [`Treatment`](@ref) spans an [`AbstractInterval`](@ref). There are two:
[`StoppedInterval`](@ref) (closed, has a [`stop`](@ref) and a
[`duration`](@ref)) and [`OngoingInterval`](@ref) (open above — no stop, no
duration). The split removes `missing`-branching: instead of a nullable stop
date, you ask [`is_stopped`](@ref) and only then call [`stop`](@ref).

```@example intervals
using TreatmentTrajectories, Dates

s = StoppedInterval(Date(2024,1,1), Date(2024,3,1))
o = OngoingInterval(Date(2024,1,1))

(is_stopped(s), is_ongoing(o), duration(s))
```

Date membership uses `in`; the upper bound is open for an ongoing interval:

```@example intervals
(Date(2024,2,1) in s, Date(2030,1,1) in o)
```

[`overlaps`](@ref) is commutative and treats an ongoing interval as unbounded
above:

```@example intervals
win = StoppedInterval(Date(2024,2,1), Date(2024,2,28))
(overlaps(s, win), overlaps(OngoingInterval(Date(2024,5,1)), win))
```
