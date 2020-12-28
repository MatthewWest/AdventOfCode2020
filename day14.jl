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

struct SetInstruction
    addr::Int
    value::Int
end

struct MaskInstrunction
    newmask::AbstractString
end

Instruction = Union{SetInstruction, MaskInstrunction}

mutable struct ComputerState
    mem::Dict{Int, Int}
    mask::AbstractString
end

function applymask(mask, n::Number)::Number
    result = 0
    rev_mask = reverse(mask)
    for i ∈ reverse(1:36)
        bit = nothing
        if rev_mask[i] == 'X'
            bit = (n ÷ 2^(i-1)) % 2
        elseif rev_mask[i] == '0'
            bit = 0
        elseif rev_mask[i] == '1'
            bit = 1
        else
            throw(ErrorException("Unexpected mask character"))
        end
        result += bit * 2^(i-1)
    end
    return result
end

function parseinstruction(line::AbstractString)::Instruction
    if startswith(line, "mask = ")
        return MaskInstrunction(split(line)[3])
    else
        m = match(r"^mem\[([0-9]+)\] = ([0-9]+)$", line)
        if m === nothing
            throw(ErrorException("Unexpected instruction: " * line))
        end
        addr = parse(Int, m.captures[1])
        value = parse(Int, m.captures[2])
        return SetInstruction(addr, value)
    end
end

function execute!(state::ComputerState, instr::Instruction)
    if typeof(instr) == MaskInstrunction
        state.mask = instr.newmask
    elseif typeof(instr) == SetInstruction
        state.mem[instr.addr] = applymask(state.mask, instr.value)
    end
end

function part1(filename = "day14input.txt")
    instructions = parseinstruction.(readlines(filename))
    mask = 'X'^36
    mem = Dict{Int, Int}()
    state = ComputerState(mem, mask)
    for instr ∈ instructions
        execute!(state, instr)
    end
    return sum(values(mem))
end

function applyfloatingtozero(mask, n::Number)::Number
    result = 0
    rev_mask = reverse(mask)
    for i ∈ reverse(1:36)
        bit = nothing
        if rev_mask[i] == '0'
            bit = (n ÷ 2^(i-1)) % 2
        elseif rev_mask[i] == 'x'
            bit = 0
        elseif rev_mask[i] == '1'
            bit = 1
        else
            throw(ErrorException("Unexpected mask character"))
        end
        result += bit * 2^(i-1)
    end
    return result
end

function getmaskedaddresses(mask, addr::Number)
    if contains(mask, 'X')
        ind = findfirst('X', mask)
        place = 2^(length(mask) - ind)
        newmask = mask[1:ind-1] * "x" * mask[ind+1:end]
        addrs = getmaskedaddresses(newmask, addr)
        to_add = Int[]
        for a ∈ addrs
            push!(to_add, place + a)
        end
        union!(addrs, to_add)
    else
        res = applyfloatingtozero(mask, addr)
        addrs = Set{Int}()
        push!(addrs, res)
        return addrs
    end
end

function executev2!(state::ComputerState, instr::Instruction)
    if typeof(instr) == MaskInstrunction
        state.mask = instr.newmask
    elseif typeof(instr) == SetInstruction
        addrs = getmaskedaddresses(state.mask, instr.addr)
        for addr ∈ addrs
            state.mem[addr] = instr.value
        end
    end
end

function part2(filename = "day14input.txt")
    instructions = parseinstruction.(readlines(filename))
    mask = 'X'^36
    mem = Dict{Int, Int}()
    state = ComputerState(mem, mask)
    for instr ∈ instructions
        executev2!(state, instr)
    end
    return sum(values(mem))
end

