raw_input = open(f->read(f, String), "day6input.txt")

function unique_letters(group)
    length(unique(filter(c->(c>='a' && c <= 'z'), group)))
end

part1(raw_input) = split(raw_input, "\n\n") |> groups->map(unique_letters, groups) |> sum

function consensus_letters(group)
    members = split(group)
    total = 0
    for question ∈ 'a':'z'
        if all(m->contains(m, question), members)
            total += 1
        end
    end
    return total
end

part2(raw_input) = split(raw_input, "\n\n") |> groups->map(consensus_letters, groups) |> sum

println("Part 1: ", part1(raw_input))
println("Part 2: ", part2(raw_input))