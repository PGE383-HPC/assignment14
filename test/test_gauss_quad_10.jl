using Test
using MPI
using assignment14

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)

file_path = dirname(@__FILE__)*"/../data/data.csv" 

ans = run_parallel(x -> x^2 * exp(-x^2), (0, 1), 10)

if rank == 0
    @test all(isapprox.(ans[:, 2], [0.188321172541532, 0.18947041612683269, 0.18947234529808804, 
                                    0.1894723458204381, 0.1894723458204924, 0.18947234582049277, 
                                    0.1894723458263568, 0.18947238269356845, 0.1895387663045232, 
                                    0.19470019576785122], atol=1.0e-8))
end

MPI.Finalize()
