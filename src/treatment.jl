"""
    Treatment(drug, interval::AbstractInterval, reason)
    Treatment(drug, interval::AbstractInterval)

A single drug exposure over an `interval`. `drug` is any `AbstractDrug`
(see DrugInterface). `reason` is an optional stop reason; it defaults to
`missing`. Query with [`drug`](@ref), [`interval`](@ref), [`start`](@ref),
[`stop`](@ref), and [`is_ongoing`](@ref).

# Examples
```jldoctest
julia> t = Treatment(MTX, StoppedInterval(Date(2024, 1, 1), Date(2024, 4, 1)), "side-effects");

julia> substance(drug(t))
"Methotrexate"

julia> is_ongoing(t)
false

julia> u = Treatment(ADA, OngoingInterval(Date(2024, 2, 1)));

julia> ismissing(u.reason)
true
```
"""
struct Treatment{T<:AbstractDrug}
    drug::T
    interval::AbstractInterval
    reason::Union{String,Missing}
end

# reason defaults to missing
Treatment(drug::T, interval::AbstractInterval) where {T<:AbstractDrug} =
    Treatment{T}(drug, interval, missing)

"""
    drug(t::Treatment)

The drug carried by a [`Treatment`](@ref).
"""
drug(t::Treatment)       = t.drug
"""
    interval(x)

The [`AbstractInterval`](@ref) spanned by a [`Treatment`](@ref) or window.
"""
interval(t::Treatment)   = t.interval
start(t::Treatment)      = start(t.interval)
stop(t::Treatment)       = stop(t.interval)
is_ongoing(t::Treatment) = is_ongoing(t.interval)
