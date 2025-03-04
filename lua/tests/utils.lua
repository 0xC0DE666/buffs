local U = require("buffs.utils")

function test_split()
	local str = ""
	local _, result = pcall(U.split, str, "")
	local expected = string.format("Invalid delimiter: '%s'", "")

	assert(string.match(result, expected) ~= nil)

	str = ""
	result = U.split(str, " ")

	assert(U.table_size(result) == 0)

	str = "1 2 3"
	result = U.split(str, " ")
	expected = {"1", "2", "3"}

	assert(U.table_size(result) == 3)
	assert(U.tables_equal(result, expected))
end
test_split();

function test_is_array()
	local t = ""
	local result = U.is_array(t)
	local expected = false

	assert(result == expected)

	t = {a = 1}
	result = U.is_array(t)
	expected = false

	assert(result == expected)

	t = {1, 2, 3}
	result = U.is_array(t)
	expected = true

	assert(result == expected)

end
test_is_array()

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

function test_tables_equal()
	local _, result = pcall(U.tables_equal, {1}, {a=1})
	local expected = "Invalid argument type: Both arguments must be tables of the same type."

	assert(string.match(result, expected) ~= nil)

	local a = {1}
	local b = {1, 2}
	result = U.tables_equal(a, b)
	expected = false

	assert(result == expected)

	a = {1, 2}
	b = {1, 2}
	result = U.tables_equal(a, b)
	expected = true

	assert(result == expected)
end
test_tables_equal()

function test_numbers_not_in_range()
	local nums = {1, 2, 3, 4, 5}
	local result = U.get_out_of_range(nums, 1, 3)
	local expected = {4, 5}

	assert(U.table_size(result) == 2)
	assert(U.tables_equal(result, expected))

	result = U.get_out_of_range(nums, 1, 5)
	expected = nil

	assert(result == expected)
end
test_numbers_not_in_range()

function test_space_numbers_to_array()
	local str = "1 a"
	local _, result = pcall(U.space_numbers_to_array, str)
	local expected = string.format("Invalid argument: '%s'", str)

	assert(string.match(result, expected) ~= nil)

	str = "1 2 3"
	_, result = pcall(U.space_numbers_to_array, str)
	expected = {1, 2, 3}

	assert(U.table_size(result) == U.table_size(expected))
	assert(U.tables_equal(result, expected))
end
test_space_numbers_to_array()

function test_range_to_array()
	local rng = "asd"
	local _, result = pcall(U.range_to_array, rng)
	local expected = string.format("Invalid argument: '%s'", rng)

	assert(string.match(result, expected) ~= nil)

	rng = "0-0"
	result = U.range_to_array(rng)
	expected = {}

	assert(result ~= nil)
	assert(U.table_size(result) == 1)
	assert(result[1] == 0)

	rng = "1-5"
	result = U.range_to_array(rng)
	expected = {1, 2, 3, 4, 5}

	assert(U.table_size(result) == 5)
	assert(U.tables_equal(result, expected))
end
test_range_to_array()
