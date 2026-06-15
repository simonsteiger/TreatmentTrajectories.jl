# membership relations: (treatment, window) -> Bool
"""
    started_in(t::Treatment, window::AbstractInterval) -> Bool

`true` if `t` *starts* inside `window`. The default membership predicate for
[`episode`](@ref).
"""
started_in(t::Treatment, window::AbstractInterval) = start(t) in window
"""
    active_in(t::Treatment, window::AbstractInterval) -> Bool

`true` if `t` is *running* at any point during `window` (its interval overlaps).
"""
active_in(t::Treatment, window::AbstractInterval) = overlaps(interval(t), window)

# cut a window from a trajectory using a membership predicate (f-first, like filter)
"""
    episode([pred,] traj::TreatmentTrajectory, window::AbstractInterval) -> TreatmentEpisode

Cut a [`TreatmentEpisode`](@ref) from `traj`, keeping treatments for which
`pred(t, window)` is `true`. `pred` defaults to [`started_in`](@ref); pass
[`active_in`](@ref) to keep treatments running through the window instead.

# Examples
```jldoctest
julia> traj = TreatmentTrajectory(1, Date(2023,12,1), [
           Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,8,1))),
           Treatment(ADA, StoppedInterval(Date(2024,4,1), Date(2024,10,1))),
       ]);

julia> window = StoppedInterval(Date(2024,3,1), Date(2024,5,1));

julia> substance.(drugs(episode(traj, window)))            # started_in: only ADA
1-element Vector{String}:
 "Adalimumab"

julia> substance.(drugs(episode(active_in, traj, window))) # active_in: MTX too
2-element Vector{String}:
 "Methotrexate"
 "Adalimumab"
```
"""
function episode(pred, traj::TreatmentTrajectory, window::AbstractInterval)
    kept = filter(t -> pred(t, window), treatments(traj))
    return TreatmentEpisode(kept, window)
end

# default predicate is started_in
episode(traj::TreatmentTrajectory, window::AbstractInterval) =
    episode(started_in, traj, window)
