raw_input = readlines("day3input.txt")

@enum Square tree snow

function parse(lines)
    height = length(lines)
    width = length(first(lines))
    area = Array{Square}(undef, width, height)
    for y in 1:height
        for x in 1:width
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