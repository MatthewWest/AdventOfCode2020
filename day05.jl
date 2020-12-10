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
raw_input = readlines("day05input.txt")

function find_seat_id(seat)
    lo = 0
    hi = 127
    mid = 0
    for half ∈ seat[1:7]
        mid = (lo + hi) ÷ 2
        if half == 'F'
            hi = mid
        elseif half == 'B'
            lo = mid
        end
    end
    if seat[7] == 'B'
        mid += 1
    end
    row = mid
    
    lo = 0
    hi = 7
    mid = 0
    for side ∈ seat[8:10]
        mid = (lo + hi) ÷ 2
        if side == 'L'
            hi = mid
        elseif side == 'R'
            lo = mid
        end
    end
    if seat[10] == 'R'
        mid += 1
    end
    col = mid

    return row * 8 + col
end

@assert find_seat_id("FBFBBFFRLR") == 357
@assert find_seat_id("BFFFBBFRRR") == 567
@assert find_seat_id("FFFBBBFRRR") == 119
@assert find_seat_id("BBFFBBFRLL") == 820

part1(inputs) = maximum(map(find_seat_id, inputs))

function part2(inputs)
    ids = sort(map(find_seat_id, inputs))
    for i in 1:(length(ids)-1)
        if ids[i] + 1 != ids[i+1]
            return ids[i] + 1
        end
    end
end

part1(raw_input)
part2(raw_input)
