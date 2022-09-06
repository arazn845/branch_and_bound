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

bnb_model = BB.initialize(; 
    Node = MIPNode,  # stores information to evaluate the subproblems
    root = m,        #is the model itself
    sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min # whether it's a minimization or maximization problem
)
