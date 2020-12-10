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
input = readlines("day02input.txt")

function parseline(line::String)
    words = split(line)
    string_range = words[1]
    nums = map(s->parse(Int, s), split(string_range, '-'))
    
    return (nums[1]:nums[2], words[2][1], words[3])
end

parsed = map(parseline, input)

function matches1(tuple)
    req_num, character, password = tuple
    return count(c->c==character, password) ∈ req_num
end

part1(input) = count(matches1, input)

function matches2(tuple)
    req_num, character, password = tuple
    return xor(password[req_num[1]] == character, password[req_num[end]] == character)
end

part2(input) = count(matches2, input)

print(part1(parsed))
print(part2(parsed))
