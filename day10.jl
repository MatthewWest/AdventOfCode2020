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
function part1(filename = "day10input.txt")
    input = parse.(Int, eachline(filename))

    sorted = sort(input)
    sorted = vcat([0], sorted, [sorted[end]+3])
    diffs = (@view sorted[2:end]) .- (@view sorted[1:end-1])

    one_jumps = count(x->x==1, diffs)
    three_jumps = count(x->x==3, diffs)
    length(diffs)
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
        # We're at an end and there's only one adjacent number
        if group_size == 1
            return number_of_ways(@view voltages[2:end])
        # Each is attached to 3-jumps on the ends
        elseif group_size == 2
            return number_of_ways(@view voltages[3:end])
        # One bit (populate or don't populate the middle one)
        elseif group_size == 3
            return 2 * number_of_ways(@view voltages[4:end])
        # Two bits (middle 2 can be present or absent)
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

function part2(filename = "day10input.txt")
    sorted = parse.(Int, eachline(filename)) |> sort
    sorted = vcat([0], sorted, [sorted[end]])
    number_of_ways(sorted)
end

println("Part 1: ", part1())
println("Part 2: ", part2())