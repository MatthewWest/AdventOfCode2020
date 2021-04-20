### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 8f377998-a17a-11eb-1277-ad9277acfc62
md"# Day 18: Operation Order"

# ╔═╡ 1b9a5f93-3633-491a-b6f4-3da9692e7480
md"""
As you look out the window and notice a heavily-forested continent slowly appear over the horizon, you are interrupted by the child sitting next to you. They're curious if you could help them with their math homework.

Unfortunately, it seems like this "math" follows different rules than you remember.

The homework (your puzzle input) consists of a series of expressions that consist of addition (+), multiplication (*), and parentheses ((...)). Just like normal math, parentheses indicate that the expression inside must be evaluated before it can be used by the surrounding expression. Addition still finds the sum of the numbers on both sides of the operator, and multiplication still finds the product.

However, the rules of *operator precedence* have changed. Rather than evaluating multiplication before addition, the operators have the *same precedence*, and are evaluated left-to-right regardless of the order in which they appear.

For example, the steps to evaluate the expression `1 + 2 * 3 + 4 * 5 + 6` are as follows:

```
1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
      9   + 4 * 5 + 6
         13   * 5 + 6
             65   + 6
                 71
```

Parentheses can override this order; for example, here is what happens if parentheses are added to form `1 + (2 * 3) + (4 * (5 + 6))`:

```
1 + (2 * 3) + (4 * (5 + 6))
1 +    6    + (4 * (5 + 6))
     7      + (4 * (5 + 6))
     7      + (4 *   11   )
     7      +     44
            51
```

Here are a few more examples:

- `2 * 3 + (4 * 5)` becomes **`26`**.
- `5 + (8 * 3 + 9 + 3 * 4 * 3)` becomes **`437`**
- `5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))` becomes **`12240`**
- `((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2` becomes **`13632`**

Before you can help with the homework, you need to understand it yourself. *Evaluate the expression on each line of the homework; what is the sum of the resulting values?*
"""

# ╔═╡ eb826757-a608-4eaa-bbe3-df732916f11a
function find_matching_index(s, pos)
	level = 1
	if s[pos] != '('
		throw(ArgumentError("Expected position to refer to a '(' character"))
	end
	for (i, c) ∈ enumerate(s[pos+1:end])
		if c == '('
			level += 1
		elseif c == ')'
			level -= 1
		end
		
		if level == 0
			return i + pos
		end
	end
end

# ╔═╡ d4e1b7fe-4679-40c7-bd77-e80ebcfc747d
ops = Set(['+', '*'])

# ╔═╡ 37dd5443-2b4f-45b7-afbe-429bf47e7477
function parse_expression(s)
	i = 1
	n = length(s)
	current_num = Char[]
	parts = []
	while i <= n
		c = s[i]
		if c == '('
			j = find_matching_index(s, i)
			push!(parts, parse_expression(s[i+1:j-1]))
			i = j+1
		elseif c ∈ ops
			push!(parts, Symbol(c))
			i += 1
		elseif c >= '0' && c <= '9'
			push!(current_num, c)
			i += 1
		else
			if length(current_num) > 0
				push!(parts, parse(Int, String(current_num)))
				empty!(current_num)
			end
			i += 1
		end
	end
	if length(current_num) > 0
		push!(parts, parse(Int, String(current_num)))
	end
	parts
end

# ╔═╡ c1df810b-cf5d-475a-94e9-ad6901a17b1e
parse_expression("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")

# ╔═╡ c05d4712-f583-4ff5-86dc-b606244461c6
function evaluate(expr)
	n = length(expr)
	if n == 1
		if length(expr[1]) > 1
			return evaluate(expr[1])
		else
			return expr[1]
		end
	elseif n == 2
		throw(ArgumentError("Unexpected 2 argument expression"))
	elseif n == 3
		left, op, right = evaluate(expr[1]), eval(expr[2]), evaluate(expr[3])
		return op(left, right)
	else
		left, op, right = evaluate(expr[1]), eval(expr[2]), evaluate(expr[3])
		res = op(left, right)		
		return evaluate(vcat(res, expr[4:end]))
	end
end

# ╔═╡ 062ffb66-a6fb-41fa-8745-d6002b7c94ed
function evaluate(expr::String)
	return evaluate(parse_expression(expr))
end

# ╔═╡ c5353f1b-03b0-4438-8d69-ab5e57678f65
function part1(filename="day18input.txt")
	lines = readlines(filename)
	sum(map(evaluate, lines))
end

# ╔═╡ 0c639002-d70c-48ef-82e9-da6b9881ec8f
part1()

# ╔═╡ 004d6fdf-0be3-480f-8489-2a4cbc52b7d9
md"""
# Part Two

You manage to answer the child's questions and they finish part 1 of their homework, but get stuck when they reach the next section: advanced math.

Now, addition and multiplication have different precedence levels, but they're not the ones you're familiar with. Instead, addition is evaluated before multiplication.

For example, the steps to evaluate the expression `1 + 2 * 3 + 4 * 5 + 6` are now as follows:

```
1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
  3   *   7   * 5 + 6
  3   *   7   *  11
     21       *  11
         231
```
Here are the other examples from above:

- `1 + (2 * 3) + (4 * (5 + 6))` still becomes **`51`**.
- `2 * 3 + (4 * 5)` becomes **`46`**.
- `5 + (8 * 3 + 9 + 3 * 4 * 3)` becomes **`1445`**.
- `5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))` becomes **`669060`**.
- `((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2` becomes **`23340`**.
What do you get if you add up the results of evaluating the homework problems using these new rules?
"""

# ╔═╡ 86b86adc-41a9-444a-ba9d-8fa690c2c4b0
function evaluate_additions(expr)
	new_expr = []
	n = length(expr)
	i = 1
	j = 0
	while i <= n
		if expr[i] == :+
			op = eval(expr[i])
			left = new_expr[j]
			right = expr[i+1]
			new_expr[j] = op(left, right)
			i += 1 # jump over the right element
		else
			push!(new_expr, expr[i])
			j += 1
		end
		i += 1
	end
	new_expr
end

# ╔═╡ f9a522f6-d56b-41c7-81d2-99cba876dfab
function evaluate_multiplications(expr)
	new_expr = []
	n = length(expr)
	i = 1
	j = 0
	while i <= n
		if expr[i] == :*
			op = eval(expr[i])
			left = new_expr[j]
			right = expr[i+1]
			new_expr[j] = op(left, right)
			i += 1 # jump over the right element
		else
			push!(new_expr, expr[i])
			j += 1
		end
		i += 1
	end
	new_expr
end

# ╔═╡ 77e23e48-1c9f-4cfb-9056-e357674d1f92
function evaluate_with_precedence(expr)
	if typeof(expr) == Symbol
		return expr
	end
	n = length(expr)
	if n == 1
		if typeof(expr[1]) == Symbol || length(expr[1]) > 1
			return evaluate_with_precedence(expr[1])
		else
			return expr[1]
		end
	elseif n == 2
		throw(ArgumentError("Unexpected 2 argument expression"))
	elseif n == 3
		left = evaluate_with_precedence(expr[1])
		op = eval(expr[2])
		right = evaluate_with_precedence(expr[3])
		return op(left, right)
	else
		simplified = map(evaluate_with_precedence, expr)
		added = evaluate_additions(simplified)
		return evaluate_multiplications(added)[1]
	end	
end

# ╔═╡ 88c9a70d-0dc1-43e4-a809-0670cf45fdb9
function evaluate_with_precedence(expr::String)
	evaluate_with_precedence(parse_expression(expr))
end

# ╔═╡ 263700b4-fc9c-4191-9807-fc5f7095826c
function part2(filename="day18input.txt")
	lines = readlines(filename)
	sum(map(evaluate_with_precedence, lines))
end

# ╔═╡ 4f266104-128a-4812-a73a-81b1564c55bd
part2()

# ╔═╡ Cell order:
# ╟─8f377998-a17a-11eb-1277-ad9277acfc62
# ╟─1b9a5f93-3633-491a-b6f4-3da9692e7480
# ╠═eb826757-a608-4eaa-bbe3-df732916f11a
# ╠═d4e1b7fe-4679-40c7-bd77-e80ebcfc747d
# ╠═37dd5443-2b4f-45b7-afbe-429bf47e7477
# ╠═c1df810b-cf5d-475a-94e9-ad6901a17b1e
# ╠═c05d4712-f583-4ff5-86dc-b606244461c6
# ╠═062ffb66-a6fb-41fa-8745-d6002b7c94ed
# ╠═c5353f1b-03b0-4438-8d69-ab5e57678f65
# ╠═0c639002-d70c-48ef-82e9-da6b9881ec8f
# ╟─004d6fdf-0be3-480f-8489-2a4cbc52b7d9
# ╠═86b86adc-41a9-444a-ba9d-8fa690c2c4b0
# ╠═f9a522f6-d56b-41c7-81d2-99cba876dfab
# ╠═77e23e48-1c9f-4cfb-9056-e357674d1f92
# ╠═88c9a70d-0dc1-43e4-a809-0670cf45fdb9
# ╠═263700b4-fc9c-4191-9807-fc5f7095826c
# ╠═4f266104-128a-4812-a73a-81b1564c55bd
