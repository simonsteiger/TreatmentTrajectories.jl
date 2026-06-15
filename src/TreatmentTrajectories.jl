module TreatmentTrajectories

using Dates
using DrugInterface

include("intervals.jl")
include("treatment.jl")
include("windows.jl")
include("episode.jl")
include("lines.jl")

export AbstractInterval, OngoingInterval, StoppedInterval
export start, stop, is_ongoing, is_stopped, duration, overlaps
export Treatment, drug, interval
export AbstractTreatmentWindow, TreatmentTrajectory, TreatmentEpisode, TreatmentLine
export treatments, drugs, has_btsdmard, count_modes_of_action
export started_in, active_in, episode
export lines

end # module
