# Exclude Anonymous Drugs from Mode-of-Action Count Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `&& !is_anonymous(d)` to `count_modes_of_action` so anonymous b/tsDMARDs don't inflate the distinct-mode count used for difficult-to-treat classification.

**Architecture:** One-clause change in `src/windows.jl`. New anonymous stub fixture in `test/stubdrug.jl`. DrugInterface compat bumped to `"0.2"` in `Project.toml` to unlock `is_anonymous`. No new deps, no new files.

**Tech Stack:** Julia 1.11, DrugInterface 0.2, Test stdlib.

## Global Constraints

- DrugInterface compat floor: `"0.2"` (adds `is_anonymous`; default `= false` for non-anonymous drugs)
- TreatmentTrajectories version stays `0.1.0` (no public API change)
- No new package dependencies
- Test runner: kaimon MCP tool (`mcp__kaimon__run_tests`, `project_path` = repo root). Never bare `julia -e`.

---

### Task 1: Write failing tests for anonymous exclusion

**Files:**
- Modify: `test/stubdrug.jl`
- Modify: `test/runtests.jl`

**Interfaces:**
- Consumes: `StubDrug` struct from `test/stubdrug.jl` (fields: `name::String`, `moa::Symbol`, `csdmard::Bool`, `bdmard::Bool`, `tsdmard::Bool`, `cortisone::Bool`)
- Consumes: `DrugInterface.is_anonymous` — default `= false` for any `AbstractDrug` (no override needed for normal stubs; override only for anonymous fixture)
- Produces: `ANON_TNFi` — anonymous b/tsDMARD fixture visible to new testset

- [ ] **Step 1: Add anonymous fixture to `test/stubdrug.jl`**

`StubDrug` already has a `DrugInterface.is_anonymous` default of `false` from the base implementation. Add one named fixture that overrides it to `true`. Append after the last `const` line (line 24):

```julia
# AnonymousStubDrug: is_anonymous returns true; used to test exclusion
struct AnonymousStubDrug <: AbstractAntiRheumaticDrug
    moa::Symbol
    bdmard::Bool
    tsdmard::Bool
end

DrugInterface.substance(d::AnonymousStubDrug) = missing
DrugInterface.mode_of_action(d::AnonymousStubDrug) = d.moa
DrugInterface.is_csdmard(::AnonymousStubDrug) = false
DrugInterface.is_bdmard(d::AnonymousStubDrug) = d.bdmard
DrugInterface.is_tsdmard(d::AnonymousStubDrug) = d.tsdmard
DrugInterface.is_cortisone(::AnonymousStubDrug) = false
DrugInterface.is_anonymous(::AnonymousStubDrug) = true

const ANON_TNFi = AnonymousStubDrug(:unknown, true, false)
const ANON_JAKi = AnonymousStubDrug(:unknown, false, true)
```

- [ ] **Step 2: Write the failing testset in `test/runtests.jl`**

Add a new `@testset` block after the existing `"count_modes_of_action"` tests (search for the last `@test count_modes_of_action` assertion to find insertion point). The block goes inside the enclosing window testset, not at top level.

```julia
@testset "anonymous drug exclusion" begin
    d_start = Date(2024, 1, 1)
    d_stop  = Date(2024, 6, 1)

    # one normal TNFi + one anonymous b/tsDMARD → only 1 distinct mode
    w_mixed = TreatmentWindow(
        [Treatment(ADA,      StoppedInterval(d_start, d_stop), missing),
         Treatment(ANON_TNFi, StoppedInterval(d_start, d_stop), missing)],
    )
    @test count_modes_of_action(w_mixed) == 1

    # two anonymous b/tsDMARDs → 0 distinct modes
    w_anon = TreatmentWindow(
        [Treatment(ANON_TNFi, StoppedInterval(d_start, d_stop), missing),
         Treatment(ANON_JAKi, StoppedInterval(d_start, d_stop), missing)],
    )
    @test count_modes_of_action(w_anon) == 0

    # has_btsdmard still true for window containing only anonymous b/tsDMARD
    w_only_anon = TreatmentWindow(
        [Treatment(ANON_TNFi, StoppedInterval(d_start, d_stop), missing)],
    )
    @test has_btsdmard(w_only_anon)
end
```

> **Note on `TreatmentWindow` constructor:** look up how existing tests build `TreatmentWindow` — use the same pattern. If the constructor takes `(id, diagnosis, treatments)`, match that. The code above shows the `treatments` vector; supply the other args from an existing test.

- [ ] **Step 3: Run tests to verify they fail**

Use kaimon MCP tool — do NOT use `julia` directly:

```
mcp__kaimon__run_tests  project_path=/Users/simonsteiger/.julia/dev/TreatmentTrajectories.jl
```

Expected: tests in `"anonymous drug exclusion"` testset fail with something like `UndefVarError: ANON_TNFi not defined` (compat not bumped yet) or method errors. All pre-existing tests must still pass.

- [ ] **Step 4: Commit**

```bash
git add test/stubdrug.jl test/runtests.jl
git commit -m "test: add failing tests for anonymous drug exclusion from mode count"
```

---

### Task 2: Implement anonymous exclusion

> **Note (post-execution update):** DrugInterface compat bump was moved to Task 1 — required to define `AnonymousStubDrug` fixtures since `is_anonymous` is a 0.2 API. Task 2 is implementation only.

**Files:**
- Modify: `src/windows.jl:64-65`

**Interfaces:**
- Consumes: `DrugInterface.is_anonymous` — available (compat already at `"0.2.0"` from Task 1)
- Produces: updated `count_modes_of_action` that skips anonymous drugs

- [ ] **Step 1: Update `count_modes_of_action` in `src/windows.jl`**

Current (line 64–65):
```julia
count_modes_of_action(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) =
    length(unique(mode_of_action(d) for d in drugs(w) if is_btsdmard(d)))
```

Replace with:
```julia
count_modes_of_action(w::AbstractTreatmentWindow{<:AbstractAntiRheumaticDrug}) =
    length(unique(mode_of_action(d) for d in drugs(w) if is_btsdmard(d) && !is_anonymous(d)))
```

- [ ] **Step 3: Run full test suite**

```
mcp__kaimon__run_tests  project_path=/Users/simonsteiger/.julia/dev/TreatmentTrajectories.jl
```

Expected: all tests pass including the three new ones from Task 1. All pre-existing `count_modes_of_action` and `has_btsdmard` tests must remain green.

- [ ] **Step 4: Commit**

```bash
git add src/windows.jl Project.toml
git commit -m "feat: exclude anonymous drugs from count_modes_of_action"
```
