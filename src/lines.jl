# Anchored-window grouping: each line is anchored at its first treatment;
# later treatments within `gap` of that anchor join the line; the first
# treatment beyond the anchor's window opens a new line. No anchor drift,
# so steady additions cannot chain into one perpetual line.
"""
    lines(traj::TreatmentTrajectory; gap::Day = Day(30)) -> Vector{TreatmentLine}

Group a trajectory's treatments into [`TreatmentLine`](@ref)s by anchored window.
Each line is anchored at its first treatment; later treatments within `gap` of
that anchor join the line, and the first treatment beyond the anchor's window
opens a new line. The anchor does not drift, so steady additions cannot chain
into one perpetual line. The `gap` boundary is inclusive.

# Examples
```jldoctest
julia> base = Date(2024,1,1);

julia> mk(d, day) = Treatment(d, OngoingInterval(base + Day(day)));

julia> traj = TreatmentTrajectory(1, base, [mk(MTX,0), mk(ADA,25), mk(TOF,50)]);

julia> ls = lines(traj; gap = Day(30));

julia> length(ls)            # 0,25 anchor together; 50 is >30 from anchor 0
2

julia> substance.(drugs(ls[1]))
2-element Vector{String}:
 "Methotrexate"
 "Adalimumab"
```
"""
function lines(traj::TreatmentTrajectory{T}; gap::Day = Day(30)) where {T}
    ts = treatments(traj)                      # already sorted by start
    isempty(ts) && return TreatmentLine{T}[]

    result  = TreatmentLine{T}[]
    current = [ts[1]]
    anchor  = start(ts[1])

    for t in @view ts[2:end]
        if start(t) - anchor <= gap
            push!(current, t)
        else
            push!(result, _line(current))
            current = [t]
            anchor  = start(t)
        end
    end
    push!(result, _line(current))
    return result
end

_line(ts::Vector{Treatment{T}}) where {T} = TreatmentLine{T}(ts, _envelope(ts))
