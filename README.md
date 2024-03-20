# Homework Assignment 14

![Assignment 14](https://github.com/PGE383-HPC/assignment14-solution/actions/workflows/main.yml/badge.svg)


[Gauss quadrature](https://en.wikipedia.org/wiki/Gaussian_quadrature) is a clever procedure for numerically evaluating definite integrals. Gauss quadrature gets more accurate as the number (order) of quadrature points increases.

Your assignment is to create a parallel scheme with [MPI.jl](https://juliaparallel.github.io/MPI.jl/latest/), using only `Send`, `Isend`, `Recv`, and `Gather/Gather!/Gatherv!` calls, that can be used to generate a table of the number of Gauss points and the corresponding value of the integral from 1 to 50.  To compute the value of an integral with an integrand defined by `f(x)` we'll use the `FastGaussQuadrature` package as follows


```julia
using FastGaussQuadrature

ξ, w = gausslegendre(int_order)
x = (b - a) / 2 .* ξ .+ (a + b) / 2
value = sum(w .* f.(x)) * (b - a) / 2
```

where `a` and `b` are the lower and upper bounds of the definite integral respectively, `value` is the computed value of the integral, and `int_order` is the integration order.

You should **not** use `Scatter` to evenly distribute an array of the integration orders, because the higher orders are more computationally expensive and this method will cause most of the work to be done on the highest numbered rank, leaving the others unutilized; but, instead, try to design a program that will keep all ranks busy computing the integrals until they are all complete.  One idea is to use a boss/worker model, where the rank 0 processor just serves to hand out work to other processors when they are not busy.

Complete the function `generate_my_table(f::Function, limits::NTuple{2, Real}, N::Integer, comm::MPI.Comm)` in [assignment14.jl](src/assignment14.jl).   Each rank that is assigned work should store a `[int_order, value]` pair as a row in the `Vector{SVector{2, Float64}}` that has already been allocated for you to `push!` updates to, where each row will be `SVector[ int_order, value ]`.

`generate_my_table` takes a function defining the integral, the integration limits, the total number of integration points in the table, and an MPI communicator as arguments.  See the tests if you need assistance in using the function.

When the script is executed with the following command in the Terminal application from the root of the assignment repository with

```bash
$HOME/.julia/bin/mpiexecjl --project=. -np 2 julia -e 'using assignment14; run_parallel(x -> x^2, (0, 1), 5) |> print'
```

it will print the table for the integrand $f(x) = x^2$ integrated from 0 to 1 to the screen for 5 orders of Guass integration. 

## Testing

To see if your answer is correct, run the following command at the Terminal
command line from the repository's root directory

```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

the tests will run and report if passing or failing.
