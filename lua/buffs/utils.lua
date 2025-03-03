local M = {}

M.regex = {
	number_range = "^%d+-%d+$",
	space_numbers = "^%d+[ %d+]*$",
}

local function is_array(t)
    if type(t) ~= "table" then
        return false
    end

    local count = 0
    for k, v in ipairs(t) do
        if k ~= count + 1 then
            return false  -- Found a non-consecutive key
        end
        count = count + 1
    end

    return count > 0  -- Return true if there are elements
end

M.table_size = function(tbl)
	local i = 0
	local fn = is_array(tbl) and ipairs or pairs
	for k, v in fn(tbl) do
		i = i + 1
	end

	return i
end

M.string_to_number_table = function(str)
	local invalid = string.match(str, M.regex.space_numbers) == nil
	if invalid then
		local err = string.format("Invalid argument: \'%s\'", str);
		error(err)
    end

	local numbers = {}
	for num in string.gmatch(str, "%S+") do
		table.insert(numbers, tonumber(num))
	end
	
	return numbers
end

M.remove_matching_chars = function(a, b)
	local regex = string.format("[^%s]", a)
	local iter = string.gmatch(b, regex)
	local v = iter()
	print(v)
	print(iter())
	return v
end

return M
