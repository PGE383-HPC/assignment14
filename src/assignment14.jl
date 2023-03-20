#!/usr/bin/env julia

# Copyright 2022 John T. Foster
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
module assignment14

using MPI
using StaticArrays
using FastGaussQuadrature


function generate_my_table(f::Function, limits::NTuple{2, Real}, 
        N::Integer, comm::MPI.Comm)

    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)
    a, b = limits
    v = Vector{SVector{2, Float64}}()
    # Add your code here. For each integration order / integration value pair, you 
    # should `push!` your solution to v, i.e. push!(v, [int_order, value])



    # Do not changed the return statement.  This returns the solutions as a
    # one-dimensional array which is easier to `Gather`
    return copy(reinterpret(Float64, v))
end

function pprint(line, comm::MPI.Comm)
    rank = MPI.Comm_rank(comm)
    print("Rank $rank, has:\n $line \n")
end

function run_parallel(f::Function, limits::NTuple{2, Real}=(-1, 1), N::Integer=10)
    MPI.Init()
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    my_table = generate_my_table(f, limits, N, comm)
    lengths = MPI.Gather(length(my_table), comm)
    
    if rank == 0
        ans = Vector{Float64}(undef, sum(lengths))
        recv_buf = MPI.VBuffer(ans, lengths)
    else
        recv_buf = nothing
    end

    MPI.Gatherv!(my_table, recv_buf, comm; root=0)

    if rank == 0
        return sort(reshape(ans, 2, :)'; dims=1, by=x->x[1])
    end
    nothing
end

export run_parallel

end
