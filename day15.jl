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

function part1(filename="day15input.txt", nth=2020)
    starting_numbers = map(s->parse(Int, s), split(String(read(filename)), ","))
    last_said = Dict{Int, Int}()
    prev = nothing
    saying = nothing
    for i ∈ 1:nth
        if i <= length(starting_numbers)
            saying = starting_numbers[i]
        elseif prev ∈ keys(last_said)
            saying = i - last_said[prev] - 1
        else
            saying = 0
        end
        if prev !== nothing
            last_said[prev] = i-1
        end
        prev = saying
    end
    return saying
end

println("Part 1: ", part1())
part2() = part1("day15input.txt", 30000000)
println("Part 2: ", part2())