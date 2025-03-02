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


