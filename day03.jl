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
raw_input = readlines("day03input.txt")

@enum Square tree snow

function parse(lines)
    h = length(lines)
    w = length(first(lines))
    area = fill(snow, (w, h))
    for y in 1:h
        for x in 1:w
            if lines[y][x] == '.'
                area[x, y] = snow
            elseif lines[y][x] == '#'
                area[x, y] = tree
            end
        end
    end
    return area
end

input = parse(raw_input)

function count_trees(input, step::Tuple{Int,Int})
    w, h = size(input)
    dx, dy = step
    pos = (1, 1)
    n = 0
    while pos[2] <= h
        if input[(pos[1] - 1) % w + 1, pos[2]] == tree
            n += 1
        end
        pos = (pos[1] + dx, pos[2] + dy)        
    end
    return n
end

part1(input) = count_trees(input, (3, 1))

function part2(input)
    slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
    reduce(
        *, 
        map(slope -> count_trees(input, slope), slopes))
end

println(part1(input))

println(part2(input))
