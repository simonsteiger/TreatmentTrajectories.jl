"""
    AbstractTreatmentWindow{T<:AbstractDrug}

A bag of `Treatment{T}`s over an interval, queryable by drug. Supertype of
`TreatmentTrajectory`, `TreatmentEpisode`, and `TreatmentLine`.

# Implementing a new window
Required: a subtype must answer

- `treatments(w)` → the `Vector{Treatment{T}}` it holds
- `interval(w)`   → the `AbstractInterval` it spans

The defaults read a `treatments` and an `interval` field respectively. A subtype
that stores those fields gets both for free; a subtype that computes its interval
(as `TreatmentTrajectory` does) MUST override `interval` — otherwise the field
default errors.

# Provided for free
`drugs`, `length`, `isempty` for any `T`; `has_btsdmard` and
`count_modes_of_action` for `T<:AbstractAntiRheumaticDrug`.
"""
abstract type AbstractTreatmentWindow{T<:AbstractDrug} end

# ---- required interface (default: field access) ----
"""
    treatments(w::AbstractTreatmentWindow)

The `Vector{Treatment}` held by a window. Part of the window interface; the
default reads a `treatments` field.
"""
treatments(w::AbstractTreatmentWindow) = w.treatments
# default reads an `interval` field; any concrete window without one (e.g.
# TreatmentTrajectory) MUST override this, as TreatmentTrajectory does below.
interval(w::AbstractTreatmentWindow) = w.interval

# ---- generic queries (any drug) ----
# materialized (not a lazy generator) so the result is safe to iterate or
# `length` more than once at call sites.
"""
    drugs(w::AbstractTreatmentWindow)

The vector of drugs in a window, in treatment order. Materialized (safe to
iterate or `length` more than once).
"""
drugs(w::AbstractTreatmentWindow) = [t.drug for t in treatments(w)]
Base.length(w::AbstractTreatmentWindow) = length(treatments(w))
Base.isempty(w::AbstractTreatmentWindow) = isempty(treatments(w))

# ---- RA-branch queries (only meaningful for antirheumatic drugs) ----
"""
    has_btsdmard(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) -> Bool

`true` if any drug in the window is a b/tsDMARD (biologic or targeted synthetic).
Defined only for antirheumatic-drug windows.
"""
has_btsdmard(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) =
    any(is_btsdmard, drugs(w))

"""
    count_modes_of_action(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) -> Int

Number of distinct b/tsDMARD modes of action in the window. csDMARDs are ignored.
"""
count_modes_of_action(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) =
    length(unique(mode_of_action(d) for d in drugs(w) if is_btsdmard(d)))

# ---- span helper: envelope of a treatment vector ----
function _envelope(ts::AbstractVector{<:Treatment})
    s = minimum(start, ts)
    any(is_ongoing, ts) ? OngoingInterval(s) : StoppedInterval(s, maximum(stop, ts))
end

# ---- concrete window types ----
"""
    TreatmentTrajectory(id::Int, diagnosis::Date, treatments::Vector{Treatment{T}})

A patient's full treatment history. `treatments` are stored sorted by
[`start`](@ref). Its [`interval`](@ref) is the envelope of all treatments, or a
zero-width window at `diagnosis` when empty. Cut sub-windows with
[`episode`](@ref) or [`lines`](@ref).

# Examples
```jldoctest
julia> traj = TreatmentTrajectory(7, Date(2023,12,1), [
           Treatment(ADA, OngoingInterval(Date(2024,3,1))),
           Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,6,1))),
       ]);

julia> substance.(drugs(traj))       # sorted by start: MTX (Jan) before ADA (Mar)
2-element Vector{String}:
 "Methotrexate"
 "Adalimumab"

julia> is_ongoing(interval(traj))    # ADA ongoing ⇒ envelope ongoing
true
```
"""
struct TreatmentTrajectory{T} <: AbstractTreatmentWindow{T}
    id::Int
    diagnosis::Date
    treatments::Vector{Treatment{T}}
    function TreatmentTrajectory(
        id::Int,
        diagnosis::Date,
        treatments::Vector{Treatment{T}},
    ) where {T}
        return new{T}(id, diagnosis, sort(treatments; by = start))
    end
end

# trajectory span: envelope of treatments, or a zero-width window at diagnosis if empty
interval(traj::TreatmentTrajectory) =
    isempty(traj.treatments) ? StoppedInterval(traj.diagnosis, traj.diagnosis) :
    _envelope(traj.treatments)

"""
    TreatmentEpisode(treatments::Vector{Treatment{T}}, interval::AbstractInterval)

A window cut from a [`TreatmentTrajectory`](@ref) over an explicit `interval`.
Usually produced by [`episode`](@ref) rather than constructed directly.
"""
struct TreatmentEpisode{T} <: AbstractTreatmentWindow{T}
    treatments::Vector{Treatment{T}}
    interval::AbstractInterval
end

"""
    TreatmentLine(treatments::Vector{Treatment{T}}, interval::AbstractInterval)

An anchored-window cluster of treatments started close together. Usually produced
by [`lines`](@ref) rather than constructed directly.
"""
struct TreatmentLine{T} <: AbstractTreatmentWindow{T}
    treatments::Vector{Treatment{T}}
    interval::AbstractInterval
end
