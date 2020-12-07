raw_input = readlines("day5input.txt")

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
