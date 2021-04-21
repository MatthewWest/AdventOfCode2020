### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 94cddadf-ac24-4523-8a2a-69c4c5eb3514
begin
	try
		using Memoize
	catch
		import Pkg
		Pkg.add("Memoize")
		using Memoize
	end
end

# ╔═╡ 66c66574-a23c-11eb-33fe-c7f4ea73d016
md"""
# Day 19: Monster Messages

You land in an airport surrounded by dense forest. As you walk to your high-speed train, the Elves at the Mythical Information Bureau contact you again. They think their satellite has collected an image of a *sea monster*! Unfortunately, the connection to the satellite is having problems, and many of the messages sent back from the satellite have been corrupted.

They sent you a list of *the rules valid messages should obey* and a list of *received messages* they've collected so far (your puzzle input).

The *rules for valid messages* (the top part of your puzzle input) are numbered and build upon each other. For example:

```
0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"
```

Some rules, like 3: "b", simply match a single character (in this case, b).

The remaining rules list the sub-rules that must be followed; for example, the rule `0: 1 2` means that to match rule 0, the text being checked must match rule `1`, and the text after the part that matched rule `1` must then match rule `2`.

Some of the rules have multiple lists of sub-rules separated by a pipe (`|`). This means that at least one list of sub-rules must match. (The ones that match might be different each time the rule is encountered.) For example, the rule `2: 1 3 | 3 1` means that to match rule `2`, the text being checked must match rule `1` followed by rule `3` or it must match rule `3` followed by rule `1`.

Fortunately, there are no loops in the rules, so the list of possible matches will be finite. Since rule 1 matches `a` and rule `3` matches `b`, rule `2` matches either `ab` or `ba`. Therefore, rule `0` matches aab or aba.

Here's a more interesting example:

```
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
```

Here, because rule `4` matches `a` and rule `5` matches `b`, rule `2` matches two letters that are the same (`aa` or `bb`), and rule `3` matches two letters that are different (`ab` or `ba`).

Since rule `1` matches rules `2` and `3` once each in either order, it must match two pairs of letters, one pair with matching letters and one pair with different letters. This leaves eight possibilities: `aaab`, `aaba`, `bbab`, `bbba`, `abaa`, `abbb`, `baaa`, or `babb`.

Rule `0`, therefore, matches a (rule `4`), then any of the eight options from rule `1`, then `b` (rule `5`): `aaaabb`, `aaabab`, `abbabb`, `abbbab`, `aabaab`, `aabbbb`, `abaaab`, or `ababbb`.

The received messages (the bottom part of your puzzle input) need to be checked against the rules so you can determine which are valid and which are corrupted. Including the rules and the messages together, this might look like:

```
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
```

Your goal is to determine the number of messages that completely match rule `0`. In the above example, `ababbb` and `abbbab` match, but `bababa`, `aaabbb`, and `aaaabbb` do not, producing the answer `2`. The whole message must match all of rule `0`; there can't be extra unmatched characters in the message. (For example, `aaaabbb` might appear to match rule `0` above, but it has an extra unmatched b on the end.)

How many messages completely match rule `0`?
"""

# ╔═╡ ca24cb61-0129-44a0-829b-9a160a89d41b
abstract type Rule end

# ╔═╡ 6fae10d7-0bad-44f3-a1d2-3d2fca9562ee
struct PrimitiveRule <: Rule
	id::Int
	match::String
end

# ╔═╡ 64e754ac-b914-4bec-98e3-551fc0d9812d
struct CompositeRule <: Rule
	id::Int
	parts::Vector{Rule}
end

# ╔═╡ a804d58d-d5ff-4749-a4f7-f93306b72bb8
struct UnionRule <: Rule
	id::Int
	left::Rule
	right::Rule
end

# ╔═╡ b07d749f-e3ca-41ec-8503-d5133dab0d8c
struct Rule0 <: Rule
	id::Int
	rule31::Rule
	rule42::Rule
end

# ╔═╡ eb65a909-9f30-41b0-a1a2-aa7bee4e8d99
Base.show(io::IO, rule::PrimitiveRule) = print(io, rule.match)

# ╔═╡ 7ba12366-5d0c-4521-8b7a-cf5a22c2c20a
Base.show(io::IO, rule::CompositeRule) = print(io, join(rule.parts))

# ╔═╡ 9a963852-57ac-4e47-ab95-c371111b0b87
Base.show(io::IO, rule::Rule0) = begin
	print(io, "($(string(rule.rule42))+")
	print(io, "($(string(rule.rule42))){n}($(string(rule.rule31))){n}")
end

# ╔═╡ 702f2804-0dcf-4488-bfaf-26e1ebb9895d
Base.show(io::IO, rule::UnionRule) = begin
	print(io, "(")
	print(io, rule.left)
	print(io, "|") 
	print(io, rule.right)
	print(io, ")")
end

# ╔═╡ 850282ea-1bd8-4b58-802c-7df2c5d4b786
function parse_rule(s, n, raw_rules, parsed_rules)
	m = match(r"\"([a-z]+)\"", s)
	if m !== nothing
		return PrimitiveRule(n, m.captures[1])
	elseif contains(s, "|")
		left_s, right_s = split(s, "|")
		left = parse_rule(left_s, n, raw_rules, parsed_rules)
		right = parse_rule(right_s, n, raw_rules, parsed_rules)
		return UnionRule(n, left, right)
	else
		indices = map(p -> parse(Int, p), split(s))
		parts = Rule[]
		for i ∈ indices
			if i ∉ keys(parsed_rules)
				parsed_rules[i] = parse_rule(raw_rules[i], i, raw_rules, parsed_rules)
			end
			push!(parts, parsed_rules[i])
		end
		return CompositeRule(n, parts)
	end
end

# ╔═╡ acf2ea81-d8a6-4a1c-b5bf-73b4dd56ace2
function parse_rule_0(s)
	lines = split(s, "\n")
	raw_rules = Dict{Int, String}()
	for line ∈ lines
		m = match(r"^([0-9]+): (.*)$", line)
		i = parse(Int, m.captures[1])
		raw_rule = m.captures[2]
		raw_rules[i] = raw_rule
	end
	parsed_rules = Dict{Int, Rule}()
	
	parse_rule(raw_rules[0], 0, raw_rules, parsed_rules)
end

# ╔═╡ aaadb3ea-f565-497d-847c-618700a20745
function parse_rules(s)
	lines = split(s, "\n")
	raw_rules = Dict{Int, String}()
	for line ∈ lines
		m = match(r"^([0-9]+): (.*)$", line)
		i = parse(Int, m.captures[1])
		raw_rule = m.captures[2]
		raw_rules[i] = raw_rule
	end
	parsed_rules = Dict{Int, Rule}()
	
	rule0 = parse_rule(raw_rules[0], 0, raw_rules, parsed_rules)
	parsed_rules[0] = rule0
	parsed_rules
end

# ╔═╡ 74506116-f26c-467d-8bb0-f15bdac5d2c7
function match_rule(rule::Rule, s::AbstractString)
	regex = Regex(string(rule))
	m = match(regex, s)
	return m !== nothing && m.match == s
end

# ╔═╡ 9d8aab4f-f7bf-492d-86d4-075a60cf3006
function get_input(filename)
	contents = read(filename, String)
	rules_text, messages_text = split(contents, "\n\n")
    return parse_rule_0(rules_text), split(messages_text)
end

# ╔═╡ 0a5bbd42-aeba-4d4a-9879-5c0ea8ecfebf
function get_parsed_rules(filename)
	contents = read(filename, String)
	rules_text, messages_text = split(contents, "\n\n")
	return parse_rules(rules_text)
end

# ╔═╡ b05c4124-89cd-4985-91be-6d65f32032cd
function get_messages(filename)
	contents = read(filename, String)
	rules_text, messages_text = split(contents, "\n\n")
    return split(messages_text)
end

# ╔═╡ e6f0828d-be18-4e77-a105-a51c3a538b64
rules = get_parsed_rules("day19input.txt")

# ╔═╡ fc067185-76a8-4f4d-bdbb-740cad8e9e05
function add_deps!(deps, rule)
	if typeof(rule) == PrimitiveRule
		push!(deps, rule.id)
	elseif typeof(rule) == CompositeRule
		push!(deps, rule.id)
		foreach(r->add_deps!(deps, r), rule.parts)
	elseif typeof(rule) == UnionRule
		push!(deps, rule.id)
		add_deps!(deps, rule.left)
		add_deps!(deps, rule.right)
	end
end

# ╔═╡ 281c7783-fdb7-4b49-99a0-89cb8fcf3998
function get_deps(rule)
	deps = Set{Int}()
	add_deps!(deps, rule)
	deps
end

# ╔═╡ cceba7b4-27c4-47d8-8bc7-7847cfc1b82e
isdisjoint(union(get_deps(rules[42]), get_deps(rules[31])),  Set([8, 11]))

# ╔═╡ 33ef31d2-0aa0-4856-b1cd-153924633cc4
md"""
Because the dependencies of rules 42 and 31 don't include 8 and 11, we can treat 8 and 11 specially.
"""

# ╔═╡ a47285ba-aca6-46dd-8513-6d0ae4134f5d
function find_potentially_infinite_rules(rules)
	recursive = Int[]
	for rule ∈ values(rules)
		deps = get_deps(rule)
		if 8 ∈ deps || 11 ∈ deps
			push!(recursive, rule.id)
		end
	end
	recursive
end

# ╔═╡ f0c36d34-6250-4eb8-9e85-39b7cc3e315b
find_potentially_infinite_rules(rules)

# ╔═╡ 43d7544c-fc2c-4240-90e9-f1b87ab56375
function get_regex(rule::Rule0)
	# Synthesize a regex from examining rule 8 and 11
	# Rule 0 becomes (rule_42)+(rule_42){n}(rule_31){n}
	# This synthesized regex only handles n ∈ 1..5, but that appears
	# to work
	rule_42 = string(rule.rule42)
	rule_31 = string(rule.rule31)
	regex_string = "^($(rule_42))+"
	regex_string *= "("
	for i ∈ 1:4
		regex_string *= "($(rule_42)){$(i)}($(rule_31)){$(i)}|"
	end
	regex_string *= "($(rule_42)){5}($(rule_31)){5})\$"
	Regex(regex_string)	
end

# ╔═╡ 86c123a9-93ea-4d06-90a6-830a704414a6
function match_rule(rule::Rule0, s::AbstractString)
	match(get_regex(rule), s) !== nothing
end

# ╔═╡ c0f37e21-e5b2-4f39-8ba3-6c2e90cc1e5c
function part1(filename="day19input.txt")
	rule_0, messages = get_input(filename)
	count(m->match_rule(rule_0, m), messages)
end

# ╔═╡ 1b5cad05-3432-4acd-b74f-b831ac0b5a44
part1()

# ╔═╡ e8f096d8-6f50-43b1-ad1e-157e35801d45
function part2(filename = "day19input.txt")
	rules = get_parsed_rules(filename)
	rules[0] = Rule0(0, rules[31], rules[42])
	# rules[0] = Rule0(0, PrimitiveRule(31, "31"), PrimitiveRule(42, "42"))
	messages = get_messages(filename)
	get_regex(rules[0])
	count(m->match_rule(rules[0], m), messages)
end

# ╔═╡ b91e0294-4019-4e83-80de-36565cb63e06
part2()

# ╔═╡ Cell order:
# ╟─66c66574-a23c-11eb-33fe-c7f4ea73d016
# ╠═94cddadf-ac24-4523-8a2a-69c4c5eb3514
# ╠═ca24cb61-0129-44a0-829b-9a160a89d41b
# ╠═6fae10d7-0bad-44f3-a1d2-3d2fca9562ee
# ╠═64e754ac-b914-4bec-98e3-551fc0d9812d
# ╠═a804d58d-d5ff-4749-a4f7-f93306b72bb8
# ╠═b07d749f-e3ca-41ec-8503-d5133dab0d8c
# ╠═eb65a909-9f30-41b0-a1a2-aa7bee4e8d99
# ╠═7ba12366-5d0c-4521-8b7a-cf5a22c2c20a
# ╠═9a963852-57ac-4e47-ab95-c371111b0b87
# ╠═702f2804-0dcf-4488-bfaf-26e1ebb9895d
# ╠═850282ea-1bd8-4b58-802c-7df2c5d4b786
# ╠═acf2ea81-d8a6-4a1c-b5bf-73b4dd56ace2
# ╠═aaadb3ea-f565-497d-847c-618700a20745
# ╠═74506116-f26c-467d-8bb0-f15bdac5d2c7
# ╠═9d8aab4f-f7bf-492d-86d4-075a60cf3006
# ╠═0a5bbd42-aeba-4d4a-9879-5c0ea8ecfebf
# ╠═b05c4124-89cd-4985-91be-6d65f32032cd
# ╠═c0f37e21-e5b2-4f39-8ba3-6c2e90cc1e5c
# ╠═1b5cad05-3432-4acd-b74f-b831ac0b5a44
# ╠═e6f0828d-be18-4e77-a105-a51c3a538b64
# ╠═fc067185-76a8-4f4d-bdbb-740cad8e9e05
# ╠═281c7783-fdb7-4b49-99a0-89cb8fcf3998
# ╠═cceba7b4-27c4-47d8-8bc7-7847cfc1b82e
# ╟─33ef31d2-0aa0-4856-b1cd-153924633cc4
# ╠═a47285ba-aca6-46dd-8513-6d0ae4134f5d
# ╠═f0c36d34-6250-4eb8-9e85-39b7cc3e315b
# ╠═43d7544c-fc2c-4240-90e9-f1b87ab56375
# ╠═86c123a9-93ea-4d06-90a6-830a704414a6
# ╠═e8f096d8-6f50-43b1-ad1e-157e35801d45
# ╠═b91e0294-4019-4e83-80de-36565cb63e06
