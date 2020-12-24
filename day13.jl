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
function getinput(filename)
    lines = readlines(filename)
    earliest_time = parse(Int, lines[1])
    buses = split(lines[2], ',') |> bs->filter(b->b!="x", bs) |> bs->parse.(Int, bs)
    return (earliest_time, buses)
end

function part1(filename="day13input.txt")
    earliest, buses = getinput(filename)
    next_buses = ((earliest .÷ buses) .* buses) .+ buses
    differences = next_buses .- earliest
    (minval, min_index) = findmin(differences)
    return buses[min_index] * minval
end

part1()

struct Bus
    id::Int
    offset::Int
end

function getbuses(filename)
    bus_strings = readlines(filename)[2] |> line -> split(line, ',')
    buses = Bus[]
    offset = 0
    for bus_string ∈ bus_strings
        if bus_string != "x"
            push!(buses, Bus(parse(Int, bus_string), offset))
        end
        offset += 1
    end
    return buses
end

function number_that_fit(buses::AbstractVector{Bus}, t::Int)
    next = t
    nfit = 0
    for bus ∈ buses
        next = t + bus.offset
        if next % bus.id == 0
            nfit += 1
        else
            break
        end
    end
    return nfit
end

function part2(filename="day13input.txt")
    buses = getbuses(filename)
    n = length(buses)

    ids = map(b->b.id, buses)
    t = buses[1].id + buses[1].offset
    amount_to_add_by = buses[1].id
    max_nfit = 0
    while true
        nfit = number_that_fit(buses, t)
        if nfit == n
            return t
        elseif nfit > max_nfit
            amount_to_add_by = lcm(amount_to_add_by, ids[nfit])
            max_nfit = nfit
        end
        t += amount_to_add_by
    end 
    return t
end

println(part1())
println(part2())