"""
    AbstractInterval

A half-open or closed span of time attached to a [`Treatment`](@ref). Concrete
subtypes: [`OngoingInterval`](@ref) (open upper bound) and
[`StoppedInterval`](@ref) (closed). Query with [`start`](@ref), [`stop`](@ref),
[`is_ongoing`](@ref), [`is_stopped`](@ref), [`duration`](@ref),
[`overlaps`](@ref), and `in`.
"""
abstract type AbstractInterval end

"""
    OngoingInterval(start::Date)

An interval that has begun but not ended; its upper bound is `+∞`. Calling
[`stop`](@ref) or [`duration`](@ref) on it throws — guard with
[`is_stopped`](@ref) first.

# Examples
```jldoctest
julia> i = OngoingInterval(Date(2024, 1, 1));

julia> is_ongoing(i)
true

julia> Date(2030, 1, 1) in i      # open upper bound
true
```
"""
struct OngoingInterval <: AbstractInterval
    start::Date
end

"""
    StoppedInterval(start::Date, stop::Date)

A closed interval `[start, stop]`. Throws `ArgumentError` if `stop < start`.

# Examples
```jldoctest
julia> i = StoppedInterval(Date(2024, 1, 1), Date(2024, 3, 1));

julia> duration(i)
60 days

julia> Date(2024, 2, 1) in i
true
```
"""
struct StoppedInterval <: AbstractInterval
    start::Date
    stop::Date
    function StoppedInterval(start::Date, stop::Date)
        stop >= start || throw(ArgumentError("stop $stop precedes start $start"))
        return new(start, stop)
    end
end

"""
    start(x) -> Date

The start date of an interval, [`Treatment`](@ref), or window.
"""
start(i::AbstractInterval) = i.start

"""
    stop(x) -> Date

The stop date of a [`StoppedInterval`](@ref) (or a stopped treatment/window).
Throws `ArgumentError` on an [`OngoingInterval`](@ref) — guard with
[`is_stopped`](@ref).
"""
stop(i::StoppedInterval)   = i.stop

"""
    is_ongoing(x) -> Bool

`true` if `x` has no stop date. See also [`is_stopped`](@ref).
"""
is_ongoing(::OngoingInterval) = true
is_ongoing(::StoppedInterval) = false

"""
    is_stopped(x) -> Bool

`true` if `x` has a stop date; the negation of [`is_ongoing`](@ref).
"""
is_stopped(i::AbstractInterval) = !is_ongoing(i)

"""
    duration(i::StoppedInterval) -> Day

The closed-interval length `stop - start`. Throws on an
[`OngoingInterval`](@ref).
"""
duration(i::StoppedInterval) = i.stop - i.start

# An ongoing interval has no stop date and no finite duration. Rather than
# return `missing` (which would reintroduce the missing-branching the interval
# type split exists to remove), these error: guard with `is_stopped` first.
stop(::OngoingInterval)     = throw(ArgumentError("ongoing interval has no stop date; guard with is_stopped"))
duration(::OngoingInterval) = throw(ArgumentError("ongoing interval has no duration; guard with is_stopped"))

# date membership (the upper bound is open for an ongoing interval)
Base.in(x::Date, i::OngoingInterval) = x >= i.start
Base.in(x::Date, i::StoppedInterval) = i.start <= x <= i.stop

# interval overlap. An ongoing interval's relevant bound is +∞.
"""
    overlaps(a::AbstractInterval, b::AbstractInterval) -> Bool

`true` if the two intervals share at least one day. Commutative. An
[`OngoingInterval`](@ref) is treated as unbounded above.

# Examples
```jldoctest
julia> a = StoppedInterval(Date(2024, 1, 15), Date(2024, 2, 10));

julia> b = StoppedInterval(Date(2024, 2, 1), Date(2024, 2, 28));

julia> overlaps(a, b)
true

julia> overlaps(b, a)            # commutative
true

julia> overlaps(OngoingInterval(Date(2024, 5, 1)), b)
false
```
"""
overlaps(::OngoingInterval, ::OngoingInterval) = true
overlaps(a::OngoingInterval, b::StoppedInterval) = a.start <= b.stop
overlaps(a::StoppedInterval, b::OngoingInterval) = overlaps(b, a)
overlaps(a::StoppedInterval, b::StoppedInterval) = a.start <= b.stop && a.stop >= b.start
