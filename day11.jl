@enum State floor empty occupied

function Base.show(io::Core.IO, state::State)
    if state == empty
        print(io, 'L')
    elseif state == occupied
        print(io, '#')
    else
        print(io, '.')
    end
end

function Base.show(io::Core.IO, state::AbstractArray{State, 2})
    height, width = size(state)
    for i in 1:height
        for j in 1:width
            show(io, state[i, j])
        end
        print(io, '\n')
    end
end

function parsechar(c)::State
    if c == '.'
        return floor
    elseif c == 'L'
        return empty
    elseif c == '#'
        return occupied
    end
    throw(ErrorException("Unrecognized character"))
end

function adjacents(state::AbstractArray{State, 2}, i, j)
    height, width = size(state)
    [(-1, -1), (-1, 0), (-1, +1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)] |>
        dirs->map(c->(x=i+c[1], y=j+c[2]), dirs) |>
        coords->filter(c -> !(c.x < 1 || c.y < 1 || c.x > height || c.y > width), coords) |>
        coords->filter(c -> state[c.x, c.y] != floor, coords) |>
        coords->map(c->(c.x, c.y), coords)
end

function nextstate(state::State, neighbors::AbstractArray{State}, threshold_to_leave::Int)
    if state == empty
        if count(s->s==occupied, neighbors) == 0
            return occupied
        end
    elseif state == occupied
        if count(s->s==occupied, neighbors) >= threshold_to_leave
            return empty
        end
    end
    return state
end

function coords_visible(state::AbstractArray{State, 2}, i, j)
    height, width = size(state)
    neighbor_dirs = [(-1, -1), (-1, 0), (-1, +1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    coords = Tuple{Int, Int}[]
    for dir ∈ neighbor_dirs
        x = i
        y = j
        while true
            x = x + dir[1]
            y = y + dir[2]
            if x < 1 || x > height || y < 1 || y > width
                break
            end
            if state[x, y] != floor
                push!(coords, (x, y))
                break
            end
        end
    end
    coords    
end

function find_relevant_coords(state::AbstractArray{State, 2}, relevancy_function)
    height, width = size(state)
    relevant_coords = Dict{Tuple{Int, Int}, AbstractArray{Tuple{Int, Int}}}()
    for i ∈ 1:height
        for j ∈ 1:width
            relevant_coords[(i, j)] = relevancy_function(state, i, j)
        end
    end
    relevant_coords
end

function parseinput(lines)
    height = length(lines)
    width = length(lines[1])
    state = Array{State}(undef, (height, width))
    for i ∈ 1:height
        for j ∈ 1:width
            state[i, j] = parsechar(lines[i][j])
        end
    end
    state    
end

function evolve(state::AbstractArray{State, 2}, relevant_coords, threshold_to_leave::Int)
    next = copy(state)
    for i ∈ 1:size(state)[1]
        for j ∈ 1:size(state)[2]
            neighbors = map(ind->state[ind[1], ind[2]], relevant_coords[(i, j)])
            next[i, j] = nextstate(state[i, j], neighbors, threshold_to_leave)
        end
    end
    next
end

function part1(filename="day11input.txt")
    state = parseinput(readlines(filename))
    relevant_coords = find_relevant_coords(state, adjacents)

    prev = nothing
    while prev != state
        prev = state
        state = evolve(state, relevant_coords, 4)
    end
    return count(s->s==occupied, state)
end

function part2(filename="day11input.txt")
    state = parseinput(readlines(filename))
    relevant_coords = find_relevant_coords(state, coords_visible)
    prev = nothing
    while prev != state
        prev = state
        state = evolve(state, relevant_coords, 5)
    end
    return count(s->s==occupied, state)
end
