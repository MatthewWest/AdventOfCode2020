function part1(filename = "day9input.txt")
    input = parse.(Int, eachline(filename))

    sorted = sort(input)
    sorted = vcat([0], sorted, [sorted[end]+3])
    diffs = (@view sorted[2:end]) .- (@view sorted[1:end-1])

    one_jumps = count(x->x==1, diffs)
    three_jumps = count(x->x==3, diffs)
    length(diffs)
    println("One jumps:", one_jumps)
    println("Three jumps", three_jumps)
    return one_jumps * three_jumps
end

function number_of_ways(voltages::AbstractArray{Int})
    if length(voltages) <= 2
        return 1
    elseif voltages[1] + 3 == voltages[2]
        return number_of_ways(@view voltages[2:end])
    else
        group_size = 1
        for i ∈ 2:length(voltages)
            if voltages[i-1] + 1 == voltages[i]
                group_size += 1
            else
                break
            end
        end
        if group_size == 1
            return number_of_ways(@view voltages[2:end])
        elseif group_size == 2
            return number_of_ways(@view voltages[3:end])
        # One degree of freedom (populate or don't populate the middle one)
        elseif group_size == 3
            return 2 * number_of_ways(@view voltages[4:end])
        # Two degrees of freedom (middle can be present or absent)
        elseif group_size == 4
            return 4 * number_of_ways(@view voltages[5:end])
        # Would be 3 bits, except that at least one of the middle ones must be populated
        elseif group_size == 5
            return 7 * number_of_ways(@view voltages[6:end])
        end
    end
end

function kinds_of_groupings(sorted)
    consecutive_groupings = Set()
    group_num = 0
    prev = nothing
    for n ∈ sorted
        if n-1 == prev
            group_num+=1
        elseif group_num >= 1
            push!(consecutive_groupings, group_num)
            group_num = 1
        end
        prev = n
    end
    return consecutive_groupings
end

function part2(filename = "day9input.txt")
    sorted = parse.(Int, eachline(filename)) |> sort
    sorted = vcat([0], sorted, [sorted[end]])
    number_of_ways(sorted)
end

println("Part 1: ", part1())
println("Part 2: ", part2())