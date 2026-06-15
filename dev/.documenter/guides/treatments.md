
# Treatments {#Treatments}

A [`Treatment`](/api#TreatmentTrajectories.Treatment) pairs a drug with an [`AbstractInterval`](/api#TreatmentTrajectories.AbstractInterval) and an optional stop `reason` (defaulting to `missing`). Drugs come from DrugInterface; here we define a small concrete drug for the examples.

```julia
t = Treatment(MTX, StoppedInterval(Date(2024,1,1), Date(2024,4,1)), "side-effects")

(substance(drug(t)), start(t), stop(t), is_ongoing(t))
```


```ansi
("Methotrexate", Date("2024-01-01"), Date("2024-04-01"), false)
```


An ongoing treatment omits the reason and has no stop date:

```julia
u = Treatment(ADA, OngoingInterval(Date(2024,2,1)))

(substance(drug(u)), ismissing(u.reason), is_ongoing(u))
```


```ansi
("Adalimumab", true, true)
```

