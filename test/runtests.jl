using TreatmentTrajectories
using Dates
using Test

include("stubdrug.jl")

@testset "intervals" begin
    s = StoppedInterval(Date(2024, 1, 1), Date(2024, 3, 1))
    o = OngoingInterval(Date(2024, 1, 1))

    @testset "predicates & accessors" begin
        @test is_stopped(s)
        @test is_ongoing(o)
        @test !is_ongoing(s)
        @test start(s) == Date(2024, 1, 1)
        @test stop(s) == Date(2024, 3, 1)
        @test duration(s) == Day(60)
        # ongoing has no stop/duration: both error, guard with is_stopped
        @test_throws ArgumentError stop(o)
        @test_throws ArgumentError duration(o)
    end

    @testset "construction guard" begin
        @test_throws ArgumentError StoppedInterval(Date(2024, 3, 1), Date(2024, 1, 1))
    end

    @testset "date membership" begin
        @test Date(2024, 2, 1) in s
        @test !(Date(2024, 4, 1) in s)
        @test Date(2030, 1, 1) in o          # ongoing: open upper bound
        @test !(Date(2023, 1, 1) in o)
    end

    @testset "overlaps" begin
        win = StoppedInterval(Date(2024, 2, 1), Date(2024, 2, 28))
        @test overlaps(StoppedInterval(Date(2024, 1, 15), Date(2024, 2, 10)), win)
        @test !overlaps(StoppedInterval(Date(2023, 1, 1), Date(2023, 2, 1)), win)
        @test !overlaps(StoppedInterval(Date(2024, 5, 1), Date(2024, 6, 1)), win)
        @test overlaps(OngoingInterval(Date(2024, 1, 1)), win)
        @test !overlaps(OngoingInterval(Date(2024, 5, 1)), win)
        @test overlaps(OngoingInterval(Date(2024, 1, 1)), OngoingInterval(Date(2030, 1, 1)))

        # overlaps is commutative
        a = StoppedInterval(Date(2024, 1, 15), Date(2024, 2, 10))
        @test overlaps(a, win) == overlaps(win, a)
        ong = OngoingInterval(Date(2024, 1, 1))
        @test overlaps(ong, win) == overlaps(win, ong)
    end
end

@testset "Treatment" begin
    t = Treatment(MTX, StoppedInterval(Date(2024, 1, 1), Date(2024, 4, 1)), "side-effects")
    @test drug(t) === MTX
    @test start(t) == Date(2024, 1, 1)
    @test stop(t) == Date(2024, 4, 1)
    @test !is_ongoing(t)
    @test t.reason == "side-effects"

    # reason defaults to missing; interval may be ongoing
    u = Treatment(ADA, OngoingInterval(Date(2024, 2, 1)))
    @test ismissing(u.reason)
    @test is_ongoing(u)
    @test drug(u) === ADA
end

@testset "windows" begin
    t1 = Treatment(MTX, StoppedInterval(Date(2024, 1, 1), Date(2024, 6, 1)))
    t2 = Treatment(ADA, StoppedInterval(Date(2024, 3, 1), Date(2024, 9, 1)))
    t3 = Treatment(TOF, OngoingInterval(Date(2024, 5, 1)))

    @testset "trajectory sorts by start and spans its treatments" begin
        traj = TreatmentTrajectory(7, Date(2023, 12, 1), [t2, t3, t1])  # unsorted in
        @test treatments(traj)[1] === t1                              # sorted by start
        @test length(traj) == 3
        @test start(interval(traj)) == Date(2024, 1, 1)
        @test is_ongoing(interval(traj))                             # t3 ongoing ⇒ envelope ongoing
    end

    @testset "trajectory envelope is stopped when all treatments stopped" begin
        traj = TreatmentTrajectory(7, Date(2023, 12, 1), [t1, t2])
        @test is_stopped(interval(traj))
        @test stop(interval(traj)) == Date(2024, 9, 1)                 # latest stop
    end

    @testset "empty trajectory falls back to diagnosis" begin
        traj = TreatmentTrajectory(7, Date(2023, 12, 1), Treatment{StubDrug}[])
        @test isempty(traj)
        @test interval(traj) == StoppedInterval(Date(2023, 12, 1), Date(2023, 12, 1))
    end

    @testset "drugs and queries" begin
        traj = TreatmentTrajectory(7, Date(2023, 12, 1), [t1, t2, t3])
        @test collect(drugs(traj)) == [MTX, ADA, TOF]
        @test has_btsdmard(traj)                                     # ADA + TOF
        @test count_modes_of_action(traj) == 2                      # TNFi, JAKi
    end

    @testset "anonymous drug exclusion" begin
        d_start = Date(2024, 1, 1)
        d_stop = Date(2024, 6, 1)
        d_interval = StoppedInterval(d_start, d_stop)

        # Anonymous drugs: count of distinct modes should exclude anonymous ones
        t_anon_tnfi = Treatment(ANON_TNFi, d_interval)
        t_anon_jaki = Treatment(ANON_JAKi, d_interval)

        # single anonymous b/tsDMARD → 0 distinct modes
        traj_single_anon = TreatmentTrajectory(1, Date(2023, 12, 1), [t_anon_tnfi])
        @test count_modes_of_action(traj_single_anon) == 0

        # two different anonymous b/tsDMARDs → 0 distinct modes
        traj_anon = TreatmentTrajectory(2, Date(2023, 12, 1), [t_anon_tnfi, t_anon_jaki])
        @test count_modes_of_action(traj_anon) == 0

        # has_btsdmard still true for trajectory containing only anonymous b/tsDMARD
        traj_only_anon = TreatmentTrajectory(3, Date(2023, 12, 1), [t_anon_tnfi])
        @test has_btsdmard(traj_only_anon)
    end
end

@testset "episode" begin
    # MTX started before the window but runs through it;
    # ADA started inside the window; TOF started after it.
    t_mtx = Treatment(MTX, StoppedInterval(Date(2024, 1, 1), Date(2024, 8, 1)))
    t_ada = Treatment(ADA, StoppedInterval(Date(2024, 4, 1), Date(2024, 10, 1)))
    t_tof = Treatment(TOF, StoppedInterval(Date(2024, 9, 1), Date(2025, 1, 1)))
    traj = TreatmentTrajectory(1, Date(2023, 12, 1), [t_mtx, t_ada, t_tof])

    window = StoppedInterval(Date(2024, 3, 1), Date(2024, 5, 1))   # March–May

    @testset "started_in (default): only treatments that START in-window" begin
        ep = episode(traj, window)                            # default predicate
        @test collect(drugs(ep)) == [ADA]                     # only ADA starts in March–May
        @test interval(ep) == window
    end

    @testset "active_in: treatments RUNNING during the window" begin
        ep = episode(active_in, traj, window)
        @test Set(drugs(ep)) == Set([MTX, ADA])               # MTX runs through, ADA starts in
        @test !(TOF in collect(drugs(ep)))                    # TOF starts in September
    end

    @testset "predicates as standalone functions" begin
        @test started_in(t_ada, window)
        @test !started_in(t_mtx, window)
        @test active_in(t_mtx, window)
        @test !active_in(t_tof, window)
    end
end

@testset "lines (anchored-window)" begin
    base = Date(2024, 1, 1)
    mk(drug, day) = Treatment(drug, OngoingInterval(base + Day(day)))

    @testset "0/25/50-day example, gap=30" begin
        traj = TreatmentTrajectory(1, base, [mk(MTX, 0), mk(ADA, 25), mk(TOF, 50)])
        ls = lines(traj; gap = Day(30))
        @test length(ls) == 2
        @test Set(drugs(ls[1])) == Set([MTX, ADA])   # anchor 0, both within 30
        @test Set(drugs(ls[2])) == Set([TOF])        # 50 is >30 from anchor 0
    end

    @testset "same-date treatments share a line" begin
        traj = TreatmentTrajectory(1, base, [mk(ADA, 0), mk(RTX, 0)])
        ls = lines(traj; gap = Day(30))
        @test length(ls) == 1
        @test Set(drugs(ls[1])) == Set([ADA, RTX])
        # "RTX at line 1" query
        @test any(d -> is_substance(d, "Rituximab"), drugs(ls[1]))
    end

    @testset "no chaining: anchor does not drift" begin
        # days 0,25,50,75 — single-linkage would make ONE line; anchored makes two
        traj = TreatmentTrajectory(
            1,
            base,
            [mk(MTX, 0), mk(ADA, 25), mk(TOF, 50), mk(RTX, 75)],
        )
        ls = lines(traj; gap = Day(30))
        @test length(ls) == 2
        @test Set(drugs(ls[1])) == Set([MTX, ADA])   # anchor 0: 0,25
        @test Set(drugs(ls[2])) == Set([TOF, RTX])   # anchor 50: 50,75
    end

    @testset "gap boundary is inclusive" begin
        # day exactly == gap from anchor 0 joins the line (<= , not <)
        traj = TreatmentTrajectory(1, base, [mk(MTX, 0), mk(ADA, 30)])
        ls = lines(traj; gap = Day(30))
        @test length(ls) == 1
        @test Set(drugs(ls[1])) == Set([MTX, ADA])
    end

    @testset "single treatment, and empty" begin
        @test length(lines(TreatmentTrajectory(1, base, [mk(MTX, 0)]))) == 1
        @test isempty(lines(TreatmentTrajectory(1, base, Treatment{StubDrug}[])))
    end
end

@testset "queries on episode and line outputs" begin
    base = Date(2024, 1, 1)
    t_mtx = Treatment(MTX, StoppedInterval(base, base + Day(200)))
    t_ada = Treatment(ADA, StoppedInterval(base + Day(30), base + Day(220)))
    t_tof = Treatment(TOF, StoppedInterval(base + Day(40), base + Day(300)))
    traj = TreatmentTrajectory(1, base, [t_mtx, t_ada, t_tof])

    ep = episode(traj, StoppedInterval(base, base + Day(60)))   # started_in: all three start ≤ day 40
    @test has_btsdmard(ep)
    @test count_modes_of_action(ep) == 2                        # TNFi, JAKi
    @test length(ep) == 3

    ls = lines(traj; gap = Day(45))                               # anchor 0: 0,30,40 all ≤45
    @test length(ls) == 1
    @test count_modes_of_action(ls[1]) == 2
    @test has_btsdmard(ls[1])
end
