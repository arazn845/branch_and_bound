#problem description

m = Model(Cbc.Optimizer)
set_optimizer_attribute(m, "logLevel", 0)
@variable(m, x[1:3] >= 0)
@constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] <= 6.1)   
@constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] <= 8.1)   
@constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] <= 10.5)   
@objective(m, Max, x[1]+1.2x[2]+3.2x[3])

############################################################
const BB = Bonobo
##########################################################
mutable struct MIPNode <: AbstractNode
    std :: BnBNodeInfo #has to have the field named std with type BnBNode as Bonobo itself also stores some information in each node
    lbs :: Vector{Float64} #lower bound for each variable
    ubs :: Vector{Float64} #upper bound for each variable
    status :: MOI.TerminationStatusCode #can be OPTIMAL or INFEASIBLE 
end

#########################################################
function BB.get_branching_indices(model::JuMP.Model)
    # every variable should be discrete
    vis = MOI.get(model, MOI.ListOfVariableIndices())
    return 1:length(vis)
end


##########################################################
#initialize (Bonobo.initalize(; kwargs...))
###For initializing the BnBTree structure itself with the model information and setting options like the traverse and branch strategy.
###It returns the created BnBTree object which I'll call tree.

bnb_model = BB.initialize(; 
    branch_strategy = BB.MOST_INFEASIBLE, # branch strategy
    Node = MIPNode,  # stores information to evaluate the subproblems
    root = m,        #is the model itself
    sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min # whether it's a minimization or maximization problem
)

##########################################################

function BB.evaluate_node!(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode)
    m = tree.root
    vids = MOI.get(m ,MOI.ListOfVariableIndices())
    vars = VariableRef.(m, vids)
    JuMP.set_lower_bound.(vars, node.lbs)
    JuMP.set_upper_bound.(vars, node.ubs)

    optimize!(m)
    status = termination_status(m)
    node.status = status
    if status != MOI.OPTIMAL
        return NaN,NaN
    end

    obj_val = objective_value(m)
    if all(BB.is_approx_feasible.(tree, value.(vars)))
        node.ub = obj_val
        return obj_val, obj_val
    end
    return obj_val, NaN
end

function BB.get_relaxed_values(tree::BnBTree{MIPNode, JuMP.Model}, node)
    vids = MOI.get(tree.root ,MOI.ListOfVariableIndices())
    vars = VariableRef.(tree.root, vids)
    return JuMP.value.(vars)
end

function BB.get_branching_indices(model::JuMP.Model)
    # every variable should be discrete
    vis = MOI.get(model, MOI.ListOfVariableIndices())
    return 1:length(vis)
end
