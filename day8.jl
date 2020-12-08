using BenchmarkTools

lines = readlines("day8input.txt")

@enum Op nop acc jmp

mutable struct Instruction
    op::Op
    arg::Int
end

mutable struct ComputerState
    accumulator::Int
    pc::Int
    memory::AbstractVector{Instruction}
end

function parseline(line::AbstractString)::Instruction
    if startswith(line, "nop")
        return Instruction(nop, parse(Int, line[4:end]))
    elseif startswith(line, "acc")
        return Instruction(acc, parse(Int, line[4:end]))
    elseif startswith(line, "jmp")
        return Instruction(jmp, parse(Int, line[4:end]))
    else
        throw(ErrorException("Unrecognized op"))
    end
end

function initializecomputer(lines)::ComputerState
    memory = map(parseline, lines)
    return ComputerState(0, 1, memory)
end

function execute(state::ComputerState, visited::AbstractSet{Int}, termination_predicate)
    while true
        instr = state.memory[state.pc]
        push!(visited, state.pc)
        if instr.op == nop
            state.pc += 1
        elseif instr.op == acc
            state.pc += 1
            state.accumulator += instr.arg
        elseif instr.op == jmp
            state.pc += instr.arg
        end
        if termination_predicate(state)
            return
        end
    end
end

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
