local M = {};

M.dict_size = function(tbl)
	local i = 0;
	for k, v in pairs(tbl) do
		i = i + 1;
	end

	return i;
end

M.array_size = function(tbl)
	local i = 0;
	for k, v in ipairs(tbl) do
		i = i + 1;
	end
	return i;
end

M.string_to_number_table = function(str)
	local numbers = {}
	for num in string.gmatch(str, "%S+") do
		table.insert(numbers, tonumber(num))
	end
	
	return numbers
end

M.remove_matching_chars = function(a, b)
	local idx = 1;
	while idx <= #a and idx <= #b do
		local char_a = a:sub(idx, 1);
		local char_b = b:sub(idx, 1);
		if char_a ~= char_b then
			break;
		end
		idx = idx + 1;
	end

	local last = (#b - idx) * -1;
	return b:sub(last);
end

return M;
