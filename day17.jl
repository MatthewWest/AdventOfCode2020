using DataStructures
import Base

const Point3 = NTuple{3, Int}
const Point4 = NTuple{4, Int}
const PocketDimension3 = DefaultDict{Point3, Bool, Bool}
const PocketDimension4 = DefaultDict{Point4, Bool, Bool}

function Base.print(io::IO, dimension::PocketDimension3)
    points = [p for p in keys(dimension)]
    xs = map(first, points)
    ys = map(p -> p[2], points)
    zs = map(last, points)
    xmin, xmax = extrema(xs)
    ymin, ymax = extrema(ys)
    zmin, zmax = extrema(zs)
    for z ∈ zmin:zmax
        print(io, "z=$z\n")
        for y ∈ ymin:ymax
            for x ∈ xmin:xmax
                if dimension[(x, y, z)]
                    print(io, "#")
                else
                    print(io, ".")
                end
            end
            print(io, "\n")
        end
        print(io, "\n")
    end
end

function getneighbors(coordinate::Point3)
    x, y, z = coordinate
    neighbors = Point3[]
    for dx ∈ -1:1
        for dy ∈ -1:1
            for dz ∈ -1:1
                if dx == 0 && dy == 0 && dz == 0
                    continue
                end
                push!(neighbors, (x+dx, y+dy, z+dz))
            end
        end
    end
    neighbors
end

function getneighbors(coordinate::Point4)
    x, y, z, a = coordinate
    neighbors = Point4[]
    for dx ∈ -1:1
        for dy ∈ -1:1
            for dz ∈ -1:1
                for da ∈ -1:1
                    if dx == 0 && dy == 0 && dz == 0 && da == 0
                        continue
                    end
                    push!(neighbors, (x+dx, y+dy, z+dz, a+da))
                end
            end
        end
    end
    neighbors
end    


function getinput3(filename)
    lines = readlines(filename)
    dimension = PocketDimension3(false)
    for (i, line) ∈ enumerate(lines)
        for (j, c) ∈ enumerate(line)
            dimension[(j, i, 0)] = (c == '#')
        end
    end
    dimension
end

function getinput4(filename)
    lines = readlines(filename)
    dimension = PocketDimension4(false)
    for (i, line) ∈ enumerate(lines)
        for (j, c) ∈ enumerate(line)
            dimension[(j, i, 0, 0)] = (c == '#')
        end
    end
    dimension
end

function nextstatus(dimension, coordinate)
    neighbors = getneighbors(coordinate)
    active_neighbors = count([dimension[n] for n ∈ neighbors])
    if dimension[coordinate]
        if active_neighbors == 2 || active_neighbors == 3
            return true
        else
            return false
        end
    else
        if active_neighbors == 3
            return true
        else
            return false
        end
    end
end

function cycle(dimension::PocketDimension3)
    next = PocketDimension3(false)
    points = Set{Point3}()
    for point ∈ keys(dimension)
        union!(points, getneighbors(point))
    end
    for point ∈ points
        neighbors = getneighbors(point)
        # This seems strange to have an if on a boolean, but we only want to
        # store the points in the dimension if they are alive
        if nextstatus(dimension, point)
            next[point] = true
        end
    end 
    next
end

function cycle(dimension::PocketDimension4)
    next = PocketDimension4(false)
    points = Set{Point4}()
    for point ∈ keys(dimension)
        union!(points, getneighbors(point))
    end
    for point ∈ points
        neighbors = getneighbors(point)
        # This seems strange to have an if on a boolean, but we only want to
        # store the points in the dimension if they are alive
        if nextstatus(dimension, point)
            next[point] = true
        end
    end 
    next
end

population(dimension::AbstractDict) = count([dimension[p] for p ∈ keys(dimension)])

function part1(filename = "day17input.txt")
    dimension = getinput3(filename)
    print("Before any cycles\n")
    print(dimension)
    for i ∈ 1:6
        dimension = cycle(dimension)
        print("After $i cycles\n")
        print(dimension)
    end
    population(dimension)
end

function part2(filename = "day17input.txt")
    dimension = getinput4(filename)
    for i ∈ 1:6
        dimension = cycle(dimension)
    end
    population(dimension)
end
