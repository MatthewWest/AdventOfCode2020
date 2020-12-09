nums = readlines("day9input.txt") |> lines -> map(l->parse(Int, l), lines)

function valid_next(window::Set{Int}, next::Int)::Bool
    for num ∈ window
        if (next - num ∈ window) && num*2 != next
            return true
        end
    end
    return false
end

function part1(nums, window_size)
    if window_size >= length(nums)
        throw(ErrorException("Window size must be smaller than the input"))
    end
    window_set = Set(@view nums[1:window_size])
    for i ∈ (window_size+1):length(nums)
        if !valid_next(window_set, nums[i])
            return nums[i]
        end
        delete!(window_set, nums[i-window_size])
        push!(window_set, nums[i])
    end
end

function part2(nums, target)
    left, right = 1, 2
    n = length(nums)
    while right < n
        range = @view nums[left:right]        
        total = sum(range)
        if total < target
            right += 1
        elseif total > target
            left += 1
        else
            return minimum(range) + maximum(range)
        end
    end
    for i ∈ 1:(length(nums)-1)
        for j ∈ i:length(nums)
            range = @view nums[i:j]
            total = sum(range)
            if total == target
                return minimum(range) + maximum(range)
            elseif total > target
                break
            end
        end
    end
end

println("Part 1:")
answer1 = @btime part1(nums, 25)
println(answer1)
println("Part 2:")
answer2 = @btime part2(nums, answer1)
println(answer2)