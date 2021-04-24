"""
    MAPiteration(xMAP,ProjectA,ProjectB)

Computes a MAP iteration
"""

"""
    MAPiteration(xMAP,ProjectA,ProjectB)

Computes a MAP iteration
"""

function MAPiteration(xMAP::Vector, ProjA::Vector, ProjectB::Function,
                    filedir::String="", print_intermediate::Bool=true, isprod::Bool=false)
    print_intermediate ? printOnFile(filedir,k, tolMAP, ProjA ,deletefile=true, isprod=isprod) : nothing
    xMAP = ProjectB(ProjA)
    return xMAP  
end 

"""
    MAP(x₀,ProjectA, ProjectB)

    Method of Alternating Projections
"""
function MAP(x₀::Vector,ProjectA::Function, ProjectB::Function; 
        EPSVAL::Float64=1e-5,itmax::Int = 100,filedir::String = "",xSol::Vector = [],
        print_intermediate::Bool=true,gap_distance::Bool=false, isprod::Bool = false)
    k = 0
    tolMAP = 1.
    xMAP = x₀
    printOnFile(filedir,k, tolMAP, xMAP ,deletefile=true, isprod=isprod)
    ProjA = ProjectA(xMAP)
    while tolMAP > EPSVAL && k < itmax
        ProjA = ProjectA(xMAP)
        if gap_distance
            xMAP  = MAPiteration(xMAP, ProjA, ProjectB, filedir, print_intermediate, isprod)
            tolMAP = norm(ProjA-xMAP)
        else
            xMAPOld = copy(xMAP)
            xMAP  =  MAPiteration(xMAP, ProjA, ProjectB, filedir, print_intermediate, isprod)
            tolMAP = Tolerance(xMAP,xMAPOld,xSol)
        end
        k += 1
        printOnFile(filedir,k, tolMAP, xMAP , isprod=isprod)
    end
    isprod ? method = :MAPprod : method = :MAP
    return Results(iter_total= k,final_tol=tolMAP,xApprox=xMAP,method=method)
end


"""
    MAPprod(x₀, SetsProjections)

    Method of Alternating projections on Pierra's product space reformulation
"""
function MAPprod(x₀::Vector{Float64},Projections::Vector; 
    EPSVAL::Float64=1e-5,itmax::Int = 100,filedir::String = "", xSol::Vector = [],
    print_intermediate::Bool=false,gap_distance::Bool=false)
    k = 0
    tolMAPprod = 1.
    num_sets = length(Projections)
    xMAPprod = Vector[]
    for i = 1:num_sets
        push!(xMAPprod,x₀)
    end
    ProjectAprod(x) = ProjectProdSpace(x,Projections)
    ProjectBprod(x) = ProjectProdDiagonal(x)
    results = MAP(xMAPprod, ProjectAprod, ProjectBprod, isprod = true,
    EPSVAL=EPSVAL,itmax=itmax,filedir=filedir, xSol=xSol,
    print_intermediate=print_intermediate,gap_distance=gap_distance)
    return results
end    

"""
    MAPprod(x₀, ProjectA, ProjectB)
"""
MAPprod(x₀::Vector{Float64},ProjectA::Function, ProjectB::Function;kwargs...) = MAPprod(x₀,[ProjectA,ProjectB],kwargs...) 