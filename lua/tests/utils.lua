local U = require("buffs.utils")

function test_table_size()
	local t = {}
	local result = U.table_size(t)
	local expected = 0

	assert(result == expected)

	t = {a = 1, b = 2, c = 3}
	result = U.table_size(t)
	expected = 3

	assert(result == expected)

	t = {1, 2, 3}
	result = U.table_size(t)
	expected = 3

	assert(result == expected)

end

test_table_size()

function test_string_to_number_table()
	local str = "1 a"
	local _, result = pcall(U.string_to_number_table, str)
	local expected = string.format("Invalid argument: '%s'", str);

	assert(string.match(result, expected) ~= nil)

	str = "1 2 3";
	_, result = pcall(U.string_to_number_table, str)
	expected = {1, 2, 3}

	assert(U.table_size(result) == U.table_size(expected))
	for i, v in ipairs(expected) do
		assert(result[i] == v)
	end
end

test_string_to_number_table();
