# Copyright 2020 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

using BenchmarkTools
include("./basiccomputer.jl")

lines = readlines("day08input.txt")

function part1(lines)
    state = initializecomputer(lines)
    visited = BitSet()
    repeat_visit(state::ComputerState) = state.pc in visited
    execute(state, visited, repeat_visit)
    return state.accumulator
end

function swap_jmp_and_nop!(instr::Instruction)
    if instr.op == jmp
        instr.op = nop
    elseif instr.op == nop
        instr.op = jmp
    else
        throw(ErrorException("No jmp or nop found"))
    end    
end

function part2(lines::AbstractArray{String})
    visited = BitSet()
    n = length(lines)
    n_next = n+1
    instructions = map(parseline, lines)
    state = ComputerState(0, 1, instructions)
    function repeat_visit_or_out_of_range(state::ComputerState)
        state.pc in visited || state.pc > n
    end
    for i in 1:n
        if instructions[i].op == acc
            continue
        end
        original_instr = instructions[i]
        swap_jmp_and_nop!(instructions[i])

        execute(state, visited, repeat_visit_or_out_of_range)

        # check for completion
        if state.pc == n_next
            return state.accumulator
        end

        # reset
        empty!(visited)
        swap_jmp_and_nop!(instructions[i])
        state.accumulator = 0
        state.pc = 1
    end
end

println("Part 1:")
answer1 = @btime part1(lines)
println(answer1)
println("Part 2:")
answer2 = @btime part2(lines)
println(answer2)
