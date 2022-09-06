using HiGHS, JuMP
m = Model(HiGHS.Optimizer);
@variable(m, 0 ≤ x[1:3] ≤ 1);
@objective(m, Min, 3 * x[1] + 5 * x[2] + 3 * x[3] );
@constraint(m, 5 * x[1] + 5 * x[2] - x[3] ≥ 3);
@constraint(m,- x[1] + x[2] + 4 * x[3] ≥ 4);
@constraint(m, 3 * x[1] + x[2] + 5 * x[3] ≥ 2);
optimize!(m);
println("x: ", value.(x))
