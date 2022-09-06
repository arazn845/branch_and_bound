using JuMP, HiGHS

function bab()
    m = Model(HiGHS.Optimizer);
    @variable(m, 0 ≤ x[1:3] ≤ 1);
    @objective(m, Min, 3 * x[1] + 5 * x[2] + 3 * x[3] );
    @constraint(m, 5 * x[1] + 5 * x[2] - x[3] ≥ 3);
    @constraint(m,- x[1] + x[2] + 4 * x[3] ≥ 4);
    @constraint(m, 3 * x[1] + x[2] + 5 * x[3] ≥ 2);
    optimize!(m);
    println("x: ", value.(x))
    if x[1] == 0 | 1
        println("x[1] is binary")
    else
        m1 = m
        cut = @constraint(m1, x[1] ≥ 1)
        @info "adding the $(cut) to m1"
    end
    if x[1] == 0 | 1
        println("x[1] is binary")
    else
        m2 = m
        cut = @constraint(m2, x[1] ≤ 0)
        @info "adding the $(cut) to m2"
    end
    print(m1)
    optimize!(m1);
    println("result for model 2")
    println("x = ", value.(x))
    print(m2)
    optimize!(m2);
    println("result for model 2")
    println("x = ", value.(x))
end







