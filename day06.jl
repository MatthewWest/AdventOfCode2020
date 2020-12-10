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

raw_input = open(f->read(f, String), "day06input.txt")

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