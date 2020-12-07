lines = readlines("day7input.txt")

function parse_requirement(line)
    color_match = match(r"^([a-z ]+) bags contain", line)
    if color_match === nothing
        println(line)
        return
    end
    color = strip(color_match.captures[1])
    children_match = match(r"contain ([a-z, 0-9]+).$", line)
    children = children_match.captures[1]
    parts = split(children, ",")
    contained_colors = []
    for part in parts
        if contains(part, "no other bags")
            break
        else
            child_match = match(r"^([ 0-9]+)([a-z ]+) bag[s]{0,1}", part)
            num = parse(Int, child_match.captures[1])
            child_color = child_match.captures[2]
            push!(contained_colors, (num, child_color))
        end
    end
    return (color, contained_colors)
end

function parse_requirements(lines)
    requirements = Dict()
    for req ∈ map(parse_requirement, lines)
        parent, children = req
        if haskey(requirements, parent)
            throw(ErrorException("Non-unique key"))
        end
        requirements[parent] = children
    end
    return requirements
end

function invert_requirements(requirements)
    parents = Dict{AbstractString, AbstractArray{AbstractString}}()
    for color ∈ keys(requirements)
        for (n, child_color) ∈ requirements[color]
            if haskey(parents, child_color)
                push!(parents[child_color], color)
            else
                parents[child_color] = [color]
            end
        end
    end
    return Dict(key => Set(value) for (key, value) ∈ parents)
end

function find_possible_containers(requirements, target::AbstractString)
    parents = invert_requirements(requirements)

    to_visit = Vector()
    push!(to_visit, target)
    visited = Set{String}()
    while length(to_visit) > 0
        color_to_find = pop!(to_visit)
        push!(visited, color_to_find)
        if haskey(parents, color_to_find)
            push!(to_visit, setdiff(parents[color_to_find], visited)...)
        end
    end
    delete!(visited, target)
    return visited
end

function part1(requirements)
    find_possible_containers(requirements, "shiny gold") |> length
end

function count_bags_inside(requirements, parent::AbstractString)
    total = 0
    for child ∈ requirements[parent]
        n, color = child
        total += n
        total += n * count_bags_inside(requirements, color)
    end
    return total
end

function part2(requirements)
    count_bags_inside(requirements, "shiny gold")
end

requirements = parse_requirements(lines)
println("Part 1: ", part1(requirements))
println("Part 2: ", part2(requirements))