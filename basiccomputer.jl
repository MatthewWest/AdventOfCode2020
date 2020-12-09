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

function initializecomputer(lines::AbstractVector{String})::ComputerState
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
