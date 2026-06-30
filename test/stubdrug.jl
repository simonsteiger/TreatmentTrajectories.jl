using DrugInterface

abstract type AbstractStubDrug <: AbstractAntiRheumaticDrug end

struct StubDrug <: AbstractStubDrug
    name::String
    moa::Symbol
    csdmard::Bool
    bdmard::Bool
    tsdmard::Bool
    cortisone::Bool
end

DrugInterface.substance(d::StubDrug) = d.name
DrugInterface.mode_of_action(d::StubDrug) = d.moa
DrugInterface.is_csdmard(d::StubDrug) = d.csdmard
DrugInterface.is_bdmard(d::StubDrug) = d.bdmard
DrugInterface.is_tsdmard(d::StubDrug) = d.tsdmard
DrugInterface.is_cortisone(d::StubDrug) = d.cortisone

# named fixtures used across testsets
const MTX = StubDrug("Methotrexate", :none, true, false, false, false)
const ADA = StubDrug("Adalimumab", :TNFi, false, true, false, false)
const ETN = StubDrug("Etanercept", :TNFi, false, true, false, false)
const TOF = StubDrug("Tofacitinib", :JAKi, false, false, true, false)
const RTX = StubDrug("Rituximab", :CD20i, false, true, false, false)

struct AnonymousStubDrug <: AbstractStubDrug
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

# AnonymousStubDrug fixtures
const ANON_TNFi = AnonymousStubDrug(:unknown, true, false)
const ANON_JAKi = AnonymousStubDrug(:unknown, false, true)
