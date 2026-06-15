
# API reference {#API-reference}
- [`TreatmentTrajectories.AbstractInterval`](#TreatmentTrajectories.AbstractInterval)
- [`TreatmentTrajectories.AbstractTreatmentWindow`](#TreatmentTrajectories.AbstractTreatmentWindow)
- [`TreatmentTrajectories.OngoingInterval`](#TreatmentTrajectories.OngoingInterval)
- [`TreatmentTrajectories.StoppedInterval`](#TreatmentTrajectories.StoppedInterval)
- [`TreatmentTrajectories.Treatment`](#TreatmentTrajectories.Treatment)
- [`TreatmentTrajectories.TreatmentEpisode`](#TreatmentTrajectories.TreatmentEpisode)
- [`TreatmentTrajectories.TreatmentLine`](#TreatmentTrajectories.TreatmentLine)
- [`TreatmentTrajectories.TreatmentTrajectory`](#TreatmentTrajectories.TreatmentTrajectory)
- [`TreatmentTrajectories.active_in`](#TreatmentTrajectories.active_in-Tuple{Treatment,%20AbstractInterval})
- [`TreatmentTrajectories.count_modes_of_action`](#TreatmentTrajectories.count_modes_of_action-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}})
- [`TreatmentTrajectories.drug`](#TreatmentTrajectories.drug-Tuple{Treatment})
- [`TreatmentTrajectories.drugs`](#TreatmentTrajectories.drugs-Tuple{AbstractTreatmentWindow})
- [`TreatmentTrajectories.duration`](#TreatmentTrajectories.duration-Tuple{StoppedInterval})
- [`TreatmentTrajectories.episode`](#TreatmentTrajectories.episode-Tuple{Any,%20TreatmentTrajectory,%20AbstractInterval})
- [`TreatmentTrajectories.has_btsdmard`](#TreatmentTrajectories.has_btsdmard-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}})
- [`TreatmentTrajectories.interval`](#TreatmentTrajectories.interval-Tuple{Treatment})
- [`TreatmentTrajectories.is_ongoing`](#TreatmentTrajectories.is_ongoing-Tuple{OngoingInterval})
- [`TreatmentTrajectories.is_stopped`](#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval})
- [`TreatmentTrajectories.lines`](#TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}},%20Tuple{T}}%20where%20T)
- [`TreatmentTrajectories.overlaps`](#TreatmentTrajectories.overlaps-Tuple{OngoingInterval,%20OngoingInterval})
- [`TreatmentTrajectories.start`](#TreatmentTrajectories.start-Tuple{AbstractInterval})
- [`TreatmentTrajectories.started_in`](#TreatmentTrajectories.started_in-Tuple{Treatment,%20AbstractInterval})
- [`TreatmentTrajectories.stop`](#TreatmentTrajectories.stop-Tuple{StoppedInterval})
- [`TreatmentTrajectories.treatments`](#TreatmentTrajectories.treatments-Tuple{AbstractTreatmentWindow})

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.AbstractInterval' href='#TreatmentTrajectories.AbstractInterval'><span class="jlbinding">TreatmentTrajectories.AbstractInterval</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
AbstractInterval
```


A half-open or closed span of time attached to a [`Treatment`](/api#TreatmentTrajectories.Treatment). Concrete subtypes: [`OngoingInterval`](/api#TreatmentTrajectories.OngoingInterval) (open upper bound) and [`StoppedInterval`](/api#TreatmentTrajectories.StoppedInterval) (closed). Query with [`start`](/api#TreatmentTrajectories.start-Tuple{AbstractInterval}), [`stop`](/api#TreatmentTrajectories.stop-Tuple{StoppedInterval}), [`is_ongoing`](/api#TreatmentTrajectories.is_ongoing-Tuple{OngoingInterval}), [`is_stopped`](/api#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}), [`duration`](/api#TreatmentTrajectories.duration-Tuple{StoppedInterval}), [`overlaps`](/api#TreatmentTrajectories.overlaps-Tuple{OngoingInterval,%20OngoingInterval}), and `in`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L1-L9" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.AbstractTreatmentWindow' href='#TreatmentTrajectories.AbstractTreatmentWindow'><span class="jlbinding">TreatmentTrajectories.AbstractTreatmentWindow</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
AbstractTreatmentWindow{T<:AbstractDrug}
```


A bag of `Treatment{T}`s over an interval, queryable by drug. Supertype of `TreatmentTrajectory`, `TreatmentEpisode`, and `TreatmentLine`.

**Implementing a new window**

Required: a subtype must answer
- `treatments(w)` → the `Vector{Treatment{T}}` it holds
  
- `interval(w)`   → the `AbstractInterval` it spans
  

The defaults read a `treatments` and an `interval` field respectively. A subtype that stores those fields gets both for free; a subtype that computes its interval (as `TreatmentTrajectory` does) MUST override `interval` — otherwise the field default errors.

**Provided for free**

`drugs`, `length`, `isempty` for any `T`; `has_btsdmard` and `count_modes_of_action` for `T<:AbstractAntiRheumaticDrug`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L1-L21" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.OngoingInterval' href='#TreatmentTrajectories.OngoingInterval'><span class="jlbinding">TreatmentTrajectories.OngoingInterval</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
OngoingInterval(start::Date)
```


An interval that has begun but not ended; its upper bound is `+∞`. Calling [`stop`](/api#TreatmentTrajectories.stop-Tuple{StoppedInterval}) or [`duration`](/api#TreatmentTrajectories.duration-Tuple{StoppedInterval}) on it throws — guard with [`is_stopped`](/api#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}) first.

**Examples**

```julia
julia> i = OngoingInterval(Date(2024, 1, 1));

julia> is_ongoing(i)
true

julia> Date(2030, 1, 1) in i      # open upper bound
true
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L12-L29" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.StoppedInterval' href='#TreatmentTrajectories.StoppedInterval'><span class="jlbinding">TreatmentTrajectories.StoppedInterval</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
StoppedInterval(start::Date, stop::Date)
```


A closed interval `[start, stop]`. Throws `ArgumentError` if `stop < start`.

**Examples**

```julia
julia> i = StoppedInterval(Date(2024, 1, 1), Date(2024, 3, 1));

julia> duration(i)
60 days

julia> Date(2024, 2, 1) in i
true
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L34-L49" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.Treatment' href='#TreatmentTrajectories.Treatment'><span class="jlbinding">TreatmentTrajectories.Treatment</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Treatment(drug, interval::AbstractInterval, reason)
Treatment(drug, interval::AbstractInterval)
```


A single drug exposure over an `interval`. `drug` is any `AbstractDrug` (see DrugInterface). `reason` is an optional stop reason; it defaults to `missing`. Query with [`drug`](/api#TreatmentTrajectories.drug-Tuple{Treatment}), [`interval`](/api#TreatmentTrajectories.interval-Tuple{Treatment}), [`start`](/api#TreatmentTrajectories.start-Tuple{AbstractInterval}), [`stop`](/api#TreatmentTrajectories.stop-Tuple{StoppedInterval}), and [`is_ongoing`](/api#TreatmentTrajectories.is_ongoing-Tuple{OngoingInterval}).

**Examples**

```julia
julia> t = Treatment(MTX, StoppedInterval(Date(2024, 1, 1), Date(2024, 4, 1)), "side-effects");

julia> substance(drug(t))
"Methotrexate"

julia> is_ongoing(t)
false

julia> u = Treatment(ADA, OngoingInterval(Date(2024, 2, 1)));

julia> ismissing(u.reason)
true
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/treatment.jl#L1-L25" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.TreatmentEpisode' href='#TreatmentTrajectories.TreatmentEpisode'><span class="jlbinding">TreatmentTrajectories.TreatmentEpisode</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
TreatmentEpisode(treatments::Vector{Treatment{T}}, interval::AbstractInterval)
```


A window cut from a [`TreatmentTrajectory`](/api#TreatmentTrajectories.TreatmentTrajectory) over an explicit `interval`. Usually produced by [`episode`](/api#TreatmentTrajectories.episode-Tuple{Any,%20TreatmentTrajectory,%20AbstractInterval}) rather than constructed directly.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L113-L118" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.TreatmentLine' href='#TreatmentTrajectories.TreatmentLine'><span class="jlbinding">TreatmentTrajectories.TreatmentLine</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
TreatmentLine(treatments::Vector{Treatment{T}}, interval::AbstractInterval)
```


An anchored-window cluster of treatments started close together. Usually produced by [`lines`](/api#TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}},%20Tuple{T}}%20where%20T) rather than constructed directly.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L124-L129" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.TreatmentTrajectory' href='#TreatmentTrajectories.TreatmentTrajectory'><span class="jlbinding">TreatmentTrajectories.TreatmentTrajectory</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
TreatmentTrajectory(id::Int, diagnosis::Date, treatments::Vector{Treatment{T}})
```


A patient's full treatment history. `treatments` are stored sorted by [`start`](/api#TreatmentTrajectories.start-Tuple{AbstractInterval}). Its [`interval`](/api#TreatmentTrajectories.interval-Tuple{Treatment}) is the envelope of all treatments, or a zero-width window at `diagnosis` when empty. Cut sub-windows with [`episode`](/api#TreatmentTrajectories.episode-Tuple{Any,%20TreatmentTrajectory,%20AbstractInterval}) or [`lines`](/api#TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}},%20Tuple{T}}%20where%20T).

**Examples**

```julia
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



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L74-L97" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.active_in-Tuple{Treatment, AbstractInterval}' href='#TreatmentTrajectories.active_in-Tuple{Treatment, AbstractInterval}'><span class="jlbinding">TreatmentTrajectories.active_in</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
active_in(t::Treatment, window::AbstractInterval) -> Bool
```


`true` if `t` is _running_ at any point during `window` (its interval overlaps).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/episode.jl#L9-L13" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.count_modes_of_action-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}}' href='#TreatmentTrajectories.count_modes_of_action-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}}'><span class="jlbinding">TreatmentTrajectories.count_modes_of_action</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
count_modes_of_action(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) -> Int
```


Number of distinct b/tsDMARD modes of action in the window. csDMARDs are ignored.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L59-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.drug-Tuple{Treatment}' href='#TreatmentTrajectories.drug-Tuple{Treatment}'><span class="jlbinding">TreatmentTrajectories.drug</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
drug(t::Treatment)
```


The drug carried by a [`Treatment`](/api#TreatmentTrajectories.Treatment).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/treatment.jl#L36-L40" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.drugs-Tuple{AbstractTreatmentWindow}' href='#TreatmentTrajectories.drugs-Tuple{AbstractTreatmentWindow}'><span class="jlbinding">TreatmentTrajectories.drugs</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
drugs(w::AbstractTreatmentWindow)
```


The vector of drugs in a window, in treatment order. Materialized (safe to iterate or `length` more than once).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L39-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.duration-Tuple{StoppedInterval}' href='#TreatmentTrajectories.duration-Tuple{StoppedInterval}'><span class="jlbinding">TreatmentTrajectories.duration</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
duration(i::StoppedInterval) -> Day
```


The closed-interval length `stop - start`. Throws on an [`OngoingInterval`](/api#TreatmentTrajectories.OngoingInterval).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L90-L95" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.episode-Tuple{Any, TreatmentTrajectory, AbstractInterval}' href='#TreatmentTrajectories.episode-Tuple{Any, TreatmentTrajectory, AbstractInterval}'><span class="jlbinding">TreatmentTrajectories.episode</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
episode([pred,] traj::TreatmentTrajectory, window::AbstractInterval) -> TreatmentEpisode
```


Cut a [`TreatmentEpisode`](/api#TreatmentTrajectories.TreatmentEpisode) from `traj`, keeping treatments for which `pred(t, window)` is `true`. `pred` defaults to [`started_in`](/api#TreatmentTrajectories.started_in-Tuple{Treatment,%20AbstractInterval}); pass [`active_in`](/api#TreatmentTrajectories.active_in-Tuple{Treatment,%20AbstractInterval}) to keep treatments running through the window instead.

**Examples**

```julia
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



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/episode.jl#L17-L42" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.has_btsdmard-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}}' href='#TreatmentTrajectories.has_btsdmard-Tuple{AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}}'><span class="jlbinding">TreatmentTrajectories.has_btsdmard</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
has_btsdmard(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) -> Bool
```


`true` if any drug in the window is a b/tsDMARD (biologic or targeted synthetic). Defined only for antirheumatic-drug windows.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L50-L55" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.interval-Tuple{Treatment}' href='#TreatmentTrajectories.interval-Tuple{Treatment}'><span class="jlbinding">TreatmentTrajectories.interval</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
interval(x)
```


The [`AbstractInterval`](/api#TreatmentTrajectories.AbstractInterval) spanned by a [`Treatment`](/api#TreatmentTrajectories.Treatment) or window.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/treatment.jl#L42-L46" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.is_ongoing-Tuple{OngoingInterval}' href='#TreatmentTrajectories.is_ongoing-Tuple{OngoingInterval}'><span class="jlbinding">TreatmentTrajectories.is_ongoing</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
is_ongoing(x) -> Bool
```


`true` if `x` has no stop date. See also [`is_stopped`](/api#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L75-L79" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}' href='#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}'><span class="jlbinding">TreatmentTrajectories.is_stopped</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
is_stopped(x) -> Bool
```


`true` if `x` has a stop date; the negation of [`is_ongoing`](/api#TreatmentTrajectories.is_ongoing-Tuple{OngoingInterval}).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L83-L87" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}}, Tuple{T}} where T' href='#TreatmentTrajectories.lines-Union{Tuple{TreatmentTrajectory{T}}, Tuple{T}} where T'><span class="jlbinding">TreatmentTrajectories.lines</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
lines(traj::TreatmentTrajectory; gap::Day = Day(30)) -> Vector{TreatmentLine}
```


Group a trajectory's treatments into [`TreatmentLine`](/api#TreatmentTrajectories.TreatmentLine)s by anchored window. Each line is anchored at its first treatment; later treatments within `gap` of that anchor join the line, and the first treatment beyond the anchor's window opens a new line. The anchor does not drift, so steady additions cannot chain into one perpetual line. The `gap` boundary is inclusive.

**Examples**

```julia
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



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/lines.jl#L5-L32" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.overlaps-Tuple{OngoingInterval, OngoingInterval}' href='#TreatmentTrajectories.overlaps-Tuple{OngoingInterval, OngoingInterval}'><span class="jlbinding">TreatmentTrajectories.overlaps</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
overlaps(a::AbstractInterval, b::AbstractInterval) -> Bool
```


`true` if the two intervals share at least one day. Commutative. An [`OngoingInterval`](/api#TreatmentTrajectories.OngoingInterval) is treated as unbounded above.

**Examples**

```julia
julia> a = StoppedInterval(Date(2024, 1, 15), Date(2024, 2, 10));

julia> b = StoppedInterval(Date(2024, 2, 1), Date(2024, 2, 28));

julia> overlaps(a, b)
true

julia> overlaps(b, a)            # commutative
true

julia> overlaps(OngoingInterval(Date(2024, 5, 1)), b)
false
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L109-L130" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.start-Tuple{AbstractInterval}' href='#TreatmentTrajectories.start-Tuple{AbstractInterval}'><span class="jlbinding">TreatmentTrajectories.start</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
start(x) -> Date
```


The start date of an interval, [`Treatment`](/api#TreatmentTrajectories.Treatment), or window.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L59-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.started_in-Tuple{Treatment, AbstractInterval}' href='#TreatmentTrajectories.started_in-Tuple{Treatment, AbstractInterval}'><span class="jlbinding">TreatmentTrajectories.started_in</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
started_in(t::Treatment, window::AbstractInterval) -> Bool
```


`true` if `t` _starts_ inside `window`. The default membership predicate for [`episode`](/api#TreatmentTrajectories.episode-Tuple{Any,%20TreatmentTrajectory,%20AbstractInterval}).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/episode.jl#L2-L7" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.stop-Tuple{StoppedInterval}' href='#TreatmentTrajectories.stop-Tuple{StoppedInterval}'><span class="jlbinding">TreatmentTrajectories.stop</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
stop(x) -> Date
```


The stop date of a [`StoppedInterval`](/api#TreatmentTrajectories.StoppedInterval) (or a stopped treatment/window). Throws `ArgumentError` on an [`OngoingInterval`](/api#TreatmentTrajectories.OngoingInterval) — guard with [`is_stopped`](/api#TreatmentTrajectories.is_stopped-Tuple{AbstractInterval}).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/intervals.jl#L66-L72" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='TreatmentTrajectories.treatments-Tuple{AbstractTreatmentWindow}' href='#TreatmentTrajectories.treatments-Tuple{AbstractTreatmentWindow}'><span class="jlbinding">TreatmentTrajectories.treatments</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
treatments(w::AbstractTreatmentWindow)
```


The `Vector{Treatment}` held by a window. Part of the window interface; the default reads a `treatments` field.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/simonsteiger/TreatmentTrajectories.jl/blob/31b8ff3e3e5f08b65cf2f8a0fd2447be4e546052/src/windows.jl#L25-L30" target="_blank" rel="noreferrer">source</a></Badge>

</details>

