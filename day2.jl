input = readlines("day2input.txt")

function parseline(line::String)
    words = split(line)
    string_range = words[1]
    nums = map(s->parse(Int, s), split(string_range, '-'))
    
    return (nums[1]:nums[2], words[2][1], words[3])
end

parsed = map(parseline, input)

function matches1(tuple)
    req_num, character, password = tuple
    return count(c->c==character, password) ∈ req_num
end

part1(input) = count(matches1, input)

function matches2(tuple)
    req_num, character, password = tuple
    return xor(password[req_num[1]] == character, password[req_num[end]] == character)
end

part2(input) = count(matches2, input)

print(part1(parsed))
print(part2(parsed))
