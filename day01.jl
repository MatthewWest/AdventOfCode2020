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

input = readlines("day01input.txt")
nums = map(s->parse(Int, s), input)

function part1(nums)
    for i=1:length(nums)-1
        for j=(i+1):length(nums)
            if nums[i] + nums[j] == 2020
                return nums[i] * nums[j]
            end
        end
    end
end

function part2(nums)
    for i=1:length(nums)-2
        for j=(i+1):length(nums)-1
            for k=(j+1):length(nums)
                if nums[i] + nums[j] + nums[k] == 2020
                    return nums[i] * nums[j] * nums[k]
                end
            end
        end
    end
end

part1(nums)
part2(nums)