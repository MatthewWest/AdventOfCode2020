raw_input = open(f->read(f, String), "day6input.txt")

function unique_letters(group)
    length(unique(filter(c->(c>='a' && c <= 'z'), group)))
end

part1(raw_input) = sum(map(unique_letters, split(raw_input, "\n\n")))

function consensus_letters(group)
    members = split(group)
    total = 0
    for question ∈ 'a':'z'
        if count(m->contains(m, question), members) == length(members)
            total += 1
        end
    end
    return total
end

part2(raw_input) = sum(map(consensus_letters, split(raw_input, "\n\n")))

println("Part 1: ", part1(raw_input))
println("Part 2: ", part2(raw_input))