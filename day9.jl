using BenchmarkTools

function get_input()
    parse.(Int, eachline("day9input.txt"))
end

function valid_next(window::AbstractSet{Int}, next::Int)::Bool
    for num ∈ window
        if (next - num ∈ window) && num*2 != next
            return true
        end
    end
    return false
end

function part1(nums::Array{Int}, window_size::Int)
    n = length(nums)
    if window_size >= n
        throw(ErrorException("Window size must be smaller than the input"))
    end
    window_set = Set(@view nums[1:window_size])
    for i ∈ (window_size+1):n
        val = nums[i]
        if !valid_next(window_set, val)
            return val
        end
        delete!(window_set, nums[i-window_size])
        push!(window_set, val)
    end
end

function part2(nums::Array{Int}, target::Int)::Int
    n = length(nums)
    left, right = n-1, n
    runningsum = nums[left] + nums[right]
    while runningsum != target
        if runningsum < target
            left -= 1
            runningsum += nums[left]
        else
            runningsum -= nums[right]
            right -= 1
        end
    end
    sum(extrema(@view nums[left:right]))
end

println("Parsing time:")
nums = @btime get_input()
println("Part 1:")
answer1 = @btime part1(nums, 25)
println(answer1)
println("Part 2:")
answer2 = @btime part2(nums, answer1)
println(answer2)

function solve_all()
    nums = get_input()
    answer1 = part1(nums, 25)
    answer2 = part2(nums, answer1)
end