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
struct Position
    x::Number
    y::Number
end

Base.:+(a::Position, b::Tuple{Number, Number}) = Position(a.x + b[1], a.y + b[2])

Base.:-(a::Position, b::Position) = (a.x - b.x, a.y - b.y)

mutable struct Ship1
    pos::Position
    θ::Float64 # The angle measured in normalized degrees (range 0<=θ<360), with 0º = east
end

mutable struct Ship2
    pos::Position
    waypoint::Position # position of the waypoint relative to the ship
end

function parseline(line::AbstractString)
    return (line[1], parse(Int, (line[2:end])))
end

function getinput(filename)
    parseline.(readlines(filename))
end

function executeinstruction(state::Ship1, instr)
    code, num = instr
    if code == 'N'
        state.pos = state.pos + (0, num)
    elseif code == 'E'
        state.pos = state.pos + (num, 0)
    elseif code == 'S'
        state.pos = state.pos + (0, -num)
    elseif code == 'W'
        state.pos = state.pos + (-num, 0)
    elseif code == 'L'
        state.θ += num
    elseif code == 'R'
        state.θ -= num
    elseif code == 'F'
        state.pos = state.pos + (round(Int, cosd(state.θ) * num), round(Int, sind(state.θ) * num))
    else
        throw(ErrorException("Invalid code \"" * code * "\""))
    end
end

function part1(filename="day12input.txt")
    instructions = getinput(filename)
    ship = Ship1(Position(0, 0), 0)
    for instr in instructions
        executeinstruction(ship, instr)
    end
    return abs(ship.pos.x) + abs(ship.pos.y)
end

function executeinstruction2(state::Ship2, instr)
    code, num = instr
    if code == 'N'
        state.waypoint = state.waypoint + (0, num)
    elseif code == 'E'
        state.waypoint = state.waypoint + (num, 0)
    elseif code == 'S'
        state.waypoint = state.waypoint + (0, -num)
    elseif code == 'W'
        state.waypoint = state.waypoint + (-num, 0)
    elseif code == 'L'
        x, y = state.waypoint.x, state.waypoint.y
        magnitude = sqrt(x^2 + y^2)
        θ = atand(y, x)
        θ += num
        while θ >= 360
            θ -= 360
        end
        while θ < 0
            θ += 360
        end
        x = round(Int, cosd(θ) * magnitude)
        y = round(Int, sind(θ) * magnitude)
        state.waypoint = Position(x, y)
    elseif code == 'R'
        x, y = state.waypoint.x, state.waypoint.y
        magnitude = sqrt(x^2 + y^2)
        θ = atand(y, x)
        θ -= num
        while θ >= 360
            θ -= 360
        end
        while θ < 0
            θ += 360
        end
        x = round(Int, cosd(θ) * magnitude)
        y = round(Int, sind(θ) * magnitude)
        state.waypoint = Position(x, y)
    elseif code == 'F'
        dx, dy = state.waypoint.x, state.waypoint.y
        total_move = (dx*num, dy*num)
        state.pos += total_move
    else
        throw(ErrorException("Invalid code \"" * code * "\""))
    end
end

function part2(filename="day12input.txt")
    instructions = getinput(filename)
    ship = Ship2(Position(0, 0), Position(10, 1))
    for instr in instructions
        executeinstruction2(ship, instr)
    end
    return abs(ship.pos.x) + abs(ship.pos.y)
end

println(part1())
println(part2())