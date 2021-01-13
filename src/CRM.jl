"""
CRM
"""

function CRMiteration(xCRM::Vector, ReflectA, ReflectB)
    xCRM_RA = ReflectA(xCRM)
    xCRM_RBRA = ReflectB(xCRM_RA)
    if norm(xCRM_RA - xCRM)<ZERO_VAL
        xCRM = FindCircumcentermSet([xCRM, xCRM_RBRA])
    elseif norm(xCRM_RBRA - xCRM_RA)<ZERO_VAL
        xCRM =FindCircumcentermSet([xCRM,  xCRM_RA])
    else
        xCRM = FindCircumcentermSet([xCRM, xCRM_RA, xCRM_RBRA])
    end
    return xCRM  
end 


function CRM(x₀::Vector,ProjectA::Function, ProjectB::Function; EPSVAL::Float64=1e-5,itmax::Int = 100,filedir::String = "", xSol::Vector = [])
    k = 1
    tolCRM = 1.
    xCRM = x₀
    ReflecA(x) = Reflection(x,ProjectA)
    ReflecB(x) = Reflection(x,ProjectB)
    printoOnFile(filedir,xCRM',deletefile=true)
    while tolCRM > EPSVAL && k <= itmax
        xCRMOld = copy(xCRM)
        xCRM  = CRMiteration(xCRM, ReflectA, ReflectB)
        printoOnFile(filedir,xCRM')
        tolCRM = Tolerance(xCRM,xCRMOld,xSol)
        k += 1
    end
    return Results(iter_total= k,final_tol=tolCRM,xApprox=xCRM,method="CRM")
end