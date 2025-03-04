local M = {}

M.regex = {
	number = "^%d+$",
	range = "^%d+-%d+$",
	space_numbers = "^%d+[ %d+]*$",
}

M.is_number = function(str)
	return string.match(str, M.regex.number) ~= nil
end

M.is_range = function(str)
	return string.match(str, M.regex.range) ~= nil
end

M.is_space_numbers = function(str)
	return string.match(str, M.regex.space_numbers) ~= nil
end

M.in_range = function(n, min, max)
	return n >= min and n <= max
end

M.print_table = function(tbl)
	local iter = M.is_array(tbl) and ipairs or pairs
	for k, v in iter(tbl) do
		print(k .. " - " .. v)
	end
end

M.split = function(str, delimiter)
	if #delimiter == 0 then
		error(string.format("Invalid delimiter: '%s'", delimiter))
	end

	local result = {}
	for s in string.gmatch(str, "([^" .. delimiter .. "]+)") do
		table.insert(result, s)
	end
	
	return result
end

M.is_array = function(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local count = 0
    for k, v in ipairs(tbl) do
        if k ~= count + 1 then
            return false  -- Found a non-consecutive key
        end
        count = count + 1
    end

    return count > 0  -- Return true if there are elements
end

M.table_size = function(tbl)
	local i = 0
	local iter = M.is_array(tbl) and ipairs or pairs
	for _, _ in iter(tbl) do
		i = i + 1
	end

	return i
end

M.tables_equal = function(a, b)
	local arrays = M.is_array(a) == M.is_array(b)
	if not arrays then
		error("Invalid argument type: Both arguments must be tables of the same type.")
	end

	if M.table_size(a) ~= M.table_size(b) then
		return false;
	end

	local iter = arrays and ipairs or pairs
	for i, _ in iter(a) do
		if a[i] ~= b[i] then
			return false
		end
	end

	return  true
end

M.get_out_of_range = function(numbers, min, max)
	local invalid = {}
	idx = 1;
	for _, n in ipairs(numbers) do
		if not M.in_range(n, min, max) then
			invalid[idx] = n
			idx = idx + 1
		end
	end
	return M.table_size(invalid) > 0 and invalid or nil
end

M.space_numbers_to_array = function(nums)
	if not M.is_space_numbers(nums) then
		local err = string.format("Invalid argument: '%s'", nums);
		error(err)
    end

	local numbers = {}
	for n in string.gmatch(nums, "%S+") do
		table.insert(numbers, tonumber(n))
	end
	
	return numbers
end

M.range_to_array = function(rng)
	if not M.is_range(rng) then
		local err = string.format("Invalid argument: '%s'", rng);
		error(err)
    end

	local range = {}
	local bounds = M.split(rng, "-")
	local low = tonumber(bounds[1])
	local up = tonumber(bounds[2])
	for i = low, up, 1 do
		table.insert(range, i)
	end

	return range
end

return M
