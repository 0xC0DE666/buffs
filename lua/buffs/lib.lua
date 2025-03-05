local U = require("buffs.utils")

local NAMED_BUFFERS = "named"
local UNNAMED_BUFFERS = "unamed"

local function get_buffers(type)
	local default = type == nil or type == ""
	if not default then
		assert(type == NAMED_BUFFERS or type == UNNAMED_BUFFERS, string.format("Invalid type: '%s'. ['%s', '%s']", type, NAMED_BUFFERS, UNNAMED_BUFFERS))
	end
	type = default and NAMED_BUFFERS or type

	local bufs =
		type == NAMED_BUFFERS and vim.fn.getbufinfo({ buflisted = 1 })
		or vim.fn.getbufinfo({ buflisted = 0, scratch = 1 })

	local filtered = {}
	local idx = 1
	for _, buf in ipairs(bufs) do
		if type == NAMED_BUFFERS and buf.name ~= "" then
			filtered[idx] = buf
			idx = idx + 1
		end

		if type == UNNAMED_BUFFERS and buf.name == "" then
			filtered[idx] = buf
			idx = idx + 1
		end
	end

	return filtered
end

-- ####################
-- LIST
-- ####################
local function list_buffers(type)
 	local bufs = get_buffers(type)
	if U.table_size(bufs) == 0 then
		print("No buffers exist.")
		return
	end


	local cwd = vim.fn.getcwd()
	print(string.format("%-5s %-5s %-50s %s", "Idx", "Id", "Name", "Status"))
	for i, buf in ipairs(bufs) do
		local buf_name = buf.name:gsub(cwd..'/', "")
		local buf_status = buf.changed == 1 and "Modified" or "Unmodified"

		print(string.format("%-5d %-5d %-50s %s", i, buf.bufnr, buf_name, buf_status))
	end
end

vim.api.nvim_create_user_command("List", function(opts)
	list_buffers(opts.args)
end, { nargs = "*" })

-- ####################
-- OPEN
-- ####################
local function open_buffer(index)
 	local bufs = get_buffers()
	local idx = tonumber(index)

	-- no buffers
	if U.table_size(bufs) == 0 then
		print("No buffers exist.")
		return
	end

	-- idx out of range
	if not U.in_range(idx, 1, U.table_size(bufs)) then
		print(idx .. " out of range [" .. 1 .. ", " .. U.table_size(bufs) .. "]")
		return
	end

	-- open buffer
	vim.cmd("buffer " .. bufs[idx].bufnr)
end

vim.api.nvim_create_user_command("Open", function(opts)
	open_buffer(opts.args)
end, {nargs = 1})

-- ####################
-- SWAP
-- ####################
-- local function swap_buffers(args)
-- 	-- invalid args
-- 	-- if not U.is_space_numbers(args) then
-- 	--	 print("Delete buffers failed, invalid argument. \"" .. args .. "\"")
-- 	--	 return
-- 	-- end
-- 
-- 	-- no buffers
-- 	if U.table_size(BUFFERS) == 0 then
-- 		print("No buffers exist.")
-- 		return
-- 	end
-- 
-- 	local idxs = U.space_numbers_to_array(args)
-- 
-- 	-- idx out of range
-- 	local invalid = {}
-- 	for i, n in ipairs(idxs) do
-- 		print("==> " .. n)
-- 		if n < 1 or n > U.table_size(BUFFERS) then
-- 			invalid[i] = n
-- 		end
-- 	end
-- 
-- 	print("--> " .. U.table_size(invalid))
-- 	-- print out of range args
-- 	if U.table_size(invalid) > 0 then
-- 		local str_invalid = table.concat(idxs, " ")
-- 		print(str_invalid .. " out of range [" .. 1 .. ", " .. U.table_size(BUFFERS) .. "]")
-- 		return
-- 	end
-- 
-- 	-- swap buffers
-- 	local temp_buf = BUFFERS[idxs[2]]
-- 	BUFFERS[idxs[2]] = BUFFERS[idxs[1]]
-- 	BUFFERS[idxs[1]] = temp_buf
-- end
-- 
-- vim.api.nvim_create_user_command("Swap", function(opts)
-- 	swap_buffers(opts.args)
-- end, {nargs = "+"})

local RANGE = "range"
local SPACE_NUMBERS = "indexes"
local INVALID = "invalid"

-- ####################
-- DELETE
-- ####################
local function delete_buffers(args)
	local type = 
		(U.is_range(args) and RANGE)
    	or (U.is_space_numbers(args) and SPACE_NUMBERS)
    	or INVALID

	-- invalid args
	if type == INVALID then
	  print(string.format("Invalid argument: '%s'", args))
	  return
	end

 	local bufs = get_buffers()
	local bufs_len = U.table_size(bufs)

	-- no buffers
	if bufs_len == 0 then
		print("No buffers exist.")
		return
	end

	if type == RANGE then 
		local bounds = U.split(args, '-')
		local low = tonumber(bounds[1])
		local up = tonumber(bounds[2])
		local out_of_range = not U.in_range(low, 1, bufs_len) or not U.in_range(up, 1, bufs_len)
		if out_of_range then
			print(string.format("%s out of range [%d, %d]", args, 1, bufs_len))
			return
		end

		local idxs = U.range_to_array(args)
		local ids = ""
		for _, i in ipairs(idxs) do
			ids = string.format("%s %d", ids, bufs[i].bufnr)
		end

		local _, err = pcall(function()
			vim.cmd("bdelete! " .. ids)
		end)

		if err then
			vim.notify("Failed to delete buffers " .. err)
		end
		return
	end

	local idxs = U.space_numbers_to_array(args)

	-- indexes out of range
	local invalid = U.get_out_of_range(idxs, 1, bufs_len)
	if invalid and U.table_size(invalid) > 0 then
		local str_invalid = table.concat(invalid, " ")
		print(string.format("%s out of range [%d, %d]", str_invalid, 1, bufs_len))
		return
	end

	-- delete buffers
	local ids = ""
	for _, i in ipairs(idxs) do
		ids = string.format("%s %d", ids, bufs[i].bufnr)
	end

	local _, err = pcall(function()
		vim.cmd("bdelete! " .. ids)
	end)

	if err then
		vim.notify("Failed to delete buffers " .. err)
	end
end

vim.api.nvim_create_user_command("Delete", function(opts)
	delete_buffers(opts.args)
end, {nargs = "+"})

local DEFAULT = "default"

-- ####################
-- WIPEOUT
-- ####################
local function wipeout_buffers(args)
	local default = args == nil or args == ""
	local type =
		(U.is_range(args) and RANGE)
    	or (U.is_space_numbers(args) and SPACE_NUMBERS)
    	or DEFAULT

	-- invalid args
	--if type == INVALID then
	--  print(string.format("Invalid argument: '%s'", args))
	--  return
	--end

	local buf_type = type == DEFAULT and UNNAMED_BUFFERS or NAMED_BUFFERS
 	local bufs = get_buffers(buf_type)
	local bufs_len = U.table_size(bufs)

	-- no buffers
	if bufs_len == 0 then
		print("No buffers exist.")
		return
	end

	if type == DEFAULT then
		local ids = ""
		for _, buf in ipairs(bufs) do
			ids = string.format("%s %d", ids, buf.bufnr)
		end

		local _, err = pcall(function()
			vim.cmd("bwipeout! " .. ids)
		end)

		if err then
			vim.notify("Failed to wipeout buffers " .. err)
		end
		return
	end

	if type == RANGE then
		local bounds = U.split(args, '-')
		local low = tonumber(bounds[1])
		local up = tonumber(bounds[2])
		local out_of_range = not U.in_range(low, 1, bufs_len) or not U.in_range(up, 1, bufs_len)
		if out_of_range then
			print(string.format("%s out of range [%d, %d]", args, 1, bufs_len))
			return
		end

		local idxs = U.range_to_array(args)
		local ids = ""
		for _, i in ipairs(idxs) do
			ids = string.format("%s %d", ids, bufs[i].bufnr)
		end

		local _, err = pcall(function()
			vim.cmd("bwipeout! " .. ids)
		end)

		if err then
			vim.notify("Failed to wipeout buffers " .. err)
		end
		return
	end

	local idxs = U.space_numbers_to_array(args)
	local invalid = U.get_out_of_range(idxs, 1, bufs_len)

	-- indexes out of range
	if invalid and U.table_size(invalid) > 0 then
		local str_invalid = table.concat(invalid, " ")
		print(string.format("%s out of range [%d, %d]", str_invalid, 1, bufs_len))
		return
	end

	-- wipeout buffers
	local ids = ""
	for _, i in ipairs(idxs) do
		ids = string.format("%s %d", ids, bufs[i].bufnr)
	end

	local _, err = pcall(function()
		vim.cmd("bwipeout! " .. ids)
	end)

	if err then
		vim.notify("Failed to wipeout buffers " .. err)
	end
end

vim.api.nvim_create_user_command("Wipeout", function(opts)
	wipeout_buffers(opts.args)
end, {nargs = "*"})

local function print_buffers(bufs)
	-- Get a list of all listed buffers

	-- Check if there are any buffers
	if U.table_size(bufs) == 0 then
		print("No buffers exist.")
		return
	end

	-- Print the header
	print(string.format("%-5s %-30s %s", "Num", "Name", "Status"))

	-- Iterate through the buffers and print their details
	for _, buf in ipairs(bufs) do
		local buf_num = buf.bufnr
		local buf_name = buf.name
		local buf_status = buf.changed == 1 and "Modified" or "Unmodified"

		-- Print buffer details
		print(string.format("%-5d %-30s %s", buf_num, buf_name, buf_status))
		print_table_keys(buf)
	end
end
