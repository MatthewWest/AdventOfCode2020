input = readlines("day1input.txt")
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