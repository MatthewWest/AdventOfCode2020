struct Rule
    name::AbstractString
    ranges::AbstractVector{AbstractRange{Int}}
end

function parserule(line::AbstractString)
    m = match(r"^([^:]+): ([0-9]+)-([0-9]+) or ([0-9]+)-([0-9]+)$", line)
    name = m.captures[1]
    range1_start = parse(Int, m.captures[2])
    range1_end = parse(Int, m.captures[3])
    range2_start = parse(Int, m.captures[4])
    range2_end = parse(Int, m.captures[5])
    return Rule(name, [range1_start:range1_end, range2_start:range2_end])
end

function getinput(filename)
    contents = read(filename, String)
    parts = split(contents, "\n\n")
    rules = [parserule(line) for line ∈ split(parts[1], "\n")]
    my_ticket_line = split(parts[2], "\n")[2]
    my_ticket = parse.(Int, split(my_ticket_line, ","))
    nearby_tickets_lines = split(parts[3], "\n")[2:end]
    nearby_tickets = map(line -> parse.(Int, split(line, ",")), nearby_tickets_lines)
    return (rules, my_ticket, nearby_tickets)
end

meetsrule(rule::Rule, value::Int) = any(range -> value ∈ range, rule.ranges)

meetsrules(rules::AbstractVector{Rule}, value) = any(rule -> meetsrule(rule, value), rules)

function day1(filename="day16input.txt")
    rules, my_ticket, nearby_tickets = getinput(filename)
    invalid = Int[]
    for t ∈ nearby_tickets
        append!(invalid, filter(value -> !meetsrules(rules, value), t))
    end
    sum(invalid)
end

function allvalid(rules::AbstractVector{Rule}, ticket)
    all(value -> meetsrules(rules, value), ticket)
end

function possible_field_names(rules, value)
    possible = Set{String}()
    for rule ∈ rules
        if meetsrule(rule, value)
            push!(possible, rule.name)
        end
    end
    return possible
end

function map_field_number_to_possible_names(rules, tickets)
    possible_names = Dict{Int,Set{String}}()
    for ticket ∈ tickets
        for i ∈ 1:length(ticket)
            if i ∈ keys(possible_names)
                intersect!(possible_names[i], possible_field_names(rules, ticket[i]))
            else
                possible_names[i] = possible_field_names(rules, ticket[i])
            end
        end
    end
    return possible_names
end

function remove_field_name!(possible_names, name)
    for i ∈ keys(possible_names)
        if name ∈ possible_names[i]
            pop!(possible_names[i], name)
        end
    end
end

function find_mapping(rules, tickets)
    possible_names = map_field_number_to_possible_names(rules, tickets)
    unmapped = Set(1:20)
    mapping = similar(1:20, Union{String,Nothing})
    fill!(mapping, nothing)
    changed = true
    while changed
        changed = false
        for i ∈ 1:20
            if mapping[i] !== nothing
                continue
            elseif length(possible_names[i]) == 1
                mapping[i] = only(possible_names[i])
                remove_field_name!(possible_names, mapping[i])
                changed = true
            end
        end
    end
    return Dict(name=>i for (i, name) ∈ enumerate(mapping))
end

function day2(filename="day16input.txt")
    rules, my_ticket, nearby_tickets = getinput(filename)
    valid_tickets = filter(ticket -> allvalid(rules, ticket), nearby_tickets)
    println("Total tickets: ", length(nearby_tickets))
    println("Valid nearby tickets: ", length(valid_tickets))
    possible_fields = map_field_number_to_possible_names(rules, vcat(valid_tickets, [my_ticket]))
    mapping = find_mapping(rules, vcat(valid_tickets, [my_ticket]))
    departure_names = collect(filter(startswith("departure"), keys(mapping)))
    indices = map(s->mapping[s], departure_names)
    return prod(my_ticket[indices])
end

day1()
day2()