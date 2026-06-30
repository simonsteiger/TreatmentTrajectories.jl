using DrugInterface

struct StubDrug <: AbstractAntiRheumaticDrug
    name::String
    moa::Symbol
    csdmard::Bool
    bdmard::Bool
    tsdmard::Bool
    cortisone::Bool
    is_anon::Bool
end

StubDrug(name, moa, csdmard, bdmard, tsdmard, cortisone) =
    StubDrug(name, moa, csdmard, bdmard, tsdmard, cortisone, false)

DrugInterface.substance(d::StubDrug) = d.name
DrugInterface.mode_of_action(d::StubDrug) = d.moa
DrugInterface.is_csdmard(d::StubDrug) = d.csdmard
DrugInterface.is_bdmard(d::StubDrug) = d.bdmard
DrugInterface.is_tsdmard(d::StubDrug) = d.tsdmard
DrugInterface.is_cortisone(d::StubDrug) = d.cortisone
DrugInterface.is_anonymous(d::StubDrug) = d.is_anon

# named fixtures used across testsets
const MTX = StubDrug("Methotrexate", :none, true, false, false, false)
const ADA = StubDrug("Adalimumab", :TNFi, false, true, false, false)
const ETN = StubDrug("Etanercept", :TNFi, false, true, false, false)
const TOF = StubDrug("Tofacitinib", :JAKi, false, false, true, false)
const RTX = StubDrug("Rituximab", :CD20i, false, true, false, false)

# AnonymousStubDrug fixtures: StubDrug with is_anon=true
const ANON_TNFi = StubDrug("", :unknown, false, true, false, false, true)
const ANON_JAKi = StubDrug("", :unknown, false, false, true, false, true)
