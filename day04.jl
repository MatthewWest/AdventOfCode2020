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
raw_input = open(f->read(f, String), "day04input.txt")

passport_strings = split(raw_input, "\n\n")

function parsePassport(passport)
    fields = Dict{String, String}()
    words = split(passport)
    for word ∈ words
        field, value = split(word, ':')
        fields[field] = value
    end
    return fields
end

passports = map(parsePassport, passport_strings)

function hasRequiredFields(passport)
    haskey(passport, "byr") && haskey(passport, "iyr") && haskey(passport, "eyr") && haskey(passport, "hgt") && haskey(passport, "hcl") && haskey(passport, "ecl") && haskey(passport, "pid")
end

part1(passports) = count(hasRequiredFields, passports)

function byr_valid(byr)
    byr = parse(Int, byr)
    if byr < 1920 || byr > 2002
        return false
    end
    return true
end    

function iyr_valid(iyr)
    iyr = parse(Int, iyr)
    if iyr < 2010 || iyr > 2020
        return false
    end
    return true
end

function eyr_valid(eyr)
    eyr = parse(Int, eyr)
    if eyr < 2020 || eyr > 2030
        return false
    end
    return true
end

function hgt_valid(hgt)
    hgtmatch = match(r"^([0-9]+)(cm|in)$", hgt)
    if hgtmatch === nothing
        return false
    end
    hgt = parse(Int, hgtmatch.captures[1])
    if hgtmatch.captures[2] == "cm"
        if hgt < 150 || hgt > 193
            return false
        end
    else
        if hgt < 59 || hgt > 76
            return false
        end
    end
    return true
end

function fieldsValidate(passport)
    if !byr_valid(passport["byr"])
        return false
    end
    if !iyr_valid(passport["iyr"])
        return false
    end
    if !eyr_valid(passport["eyr"])
        return false
    end
    if !hgt_valid(passport["hgt"])
        return false
    end
    hcl = match(r"^#[0-9a-f]{6}$", passport["hcl"])
    if hcl === nothing
        return false
    end
    ecl = match(r"^(amb|blu|brn|gry|grn|hzl|oth)$", passport["ecl"])
    if ecl === nothing
        return false
    end
    pid = match(r"^[0-9]{9}$", passport["pid"])
    if pid === nothing
        return false
    end
    return true
end

count(p->hasRequiredFields(p) && fieldsValidate(p), passports)