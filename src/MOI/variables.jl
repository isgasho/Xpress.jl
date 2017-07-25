# initial very simple interface

function MOI.VariableReference(m::XpressSolverInstance)
    m.last_variable_reference += 1
    ref = MOI.VariableReference(m.last_variable_reference)
    m.variable_mapping[ref] = length(m.variable_mapping)+1
    push!(m.variable_bound, None)
    push!(m.variable_type, ConVar)
    push!(m.variable_lb, -Inf)
    push!(m.variable_ub,  Inf)
    return ref
end
function MOI.VariableReference(m::XpressSolverInstance, n::Int)
    refs = MOI.VariableReference[]
    sizehint!(refs, n)
    addsizehint!(m.variable_bound, n)
    addsizehint!(m.variable_type, n)
    addsizehint!(m.variable_lb, n)
    addsizehint!(m.variable_ub, n)
    for i in 1:n
        push!(refs, MOI.VariableReference(m))
    end
    return refs
end

# Variables

function addvariables!(m::XpressSolverInstance, n::Int) 
    add_cvars!(m.inner, zeros(n))
    return VariableReference(m, n)
end
function addvariable!(m::XpressSolverInstance)
    add_cvar!(m.inner, 0.0)
    return VariableReference(m)
end


"""
    We assume a VariableReference is valid if it exists in the mapping, and returns
    a column between 1 and the number of variables in the model.
"""
function MOI.isvalid(m::XpressSolverInstance, ref::MOI.VariableReference)
    if haskey(m.variable_mapping, ref.value)
        column = m.variable_mapping[ref.value]
        if column > 0 && column <= length(m.variable_bound)
            return true
        end
    end
    return false
end



## Variable attributes

# """
#     VariablePrimalStart()
# An initial assignment of the variables that the solver may use to warm-start the solve.
# """
# struct VariablePrimalStart <: AbstractVariableAttribute end

# """
#     VariablePrimal(N)
#     VariablePrimal()
# The assignment to the primal variables in result `N`.
# If `N` is omitted, it is 1 by default.
# """
# struct VariablePrimal <: AbstractVariableAttribute
#     N::Int
# end
# VariablePrimal() = VariablePrimal(1)

# """
#     VariableBasisStatus()
# Returns the `BasisStatusCode` of a given variable, with respect to an available optimal solution basis.
# """
# struct VariableBasisStatus <: AbstractVariableAttribute end

# """
#     BasisStatusCode
# An Enum of possible values for the `VariableBasisStatus` and `ConstraintBasisStatus` attribute.
# This explains the status of a given element with respect to an optimal solution basis.
# Possible values are:
# * `Basic`: element is in the basis
# * `Nonbasic`: element is not in the basis
# * `NonbasicAtLower`: element is not in the basis and is at its lower bound
# * `NonbasicAtUpper`: element is not in the basis and is at its upper bound
# * `SuperBasic`: element is not in the basis but is also not at one of its bounds
# """
# @enum BasisStatusCode Basic Nonbasic NonbasicAtLower NonbasicAtUpper SuperBasic
