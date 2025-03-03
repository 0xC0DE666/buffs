local U = require("buffs.utils")
-- local BUFFERS = {}

local function get_buffers(type)
	assert(type == "named" or type == "unamed", string.format("Invalid type: %s. Valid values: ['named', 'unamed']", type))

	local buffers = vim.fn.getbufinfo({ buflisted = 1 })
	local filtered = {}
	local idx = 1
	for _, buf in ipairs(buffers) do
		if type == "named" and buf.name ~= "" then
			filtered[idx] = buf
			idx = idx + 1
		end

		if type == "unamed" and buf.name == "" then
			filtered[idx] = buf
			idx = idx + 1
		end
	end

	return filtered
end

local function duplicate_buffer(arg_buf) 
	local buffers = get_buffers("named")
	for _, saved_buf in ipairs(buffers) do
		if saved_buf.name == arg_buf.name then
			return true
		end
	end

	return false
end

-- ####################
-- SYNC
-- ####################
-- function sync_buffers()
-- 	local buffers = get_buffers("named")
-- 	print("Init Buffers " .. U.table_size(buffers))
-- 	if U.table_size(buffers) == 0 then
-- 		print("No buffers exist.")
-- 		return
-- 	end
-- 
-- 	for i, buf in ipairs(buffers) do
-- 		-- local buf_name = vim.api.nvim_buf_get_name(buf.bufnr)
-- 		-- if buf.name ~= "" then
-- 		if buf.name ~= "" and not duplicate_buffer(buf) then
-- 			print(buf.bufnr .. " \"" .. buf.name .. """)
-- 			BUFFERS[i] = buf
-- 		end
-- 	end
-- end

-- vim.api.nvim_create_user_command("BufInit", sync_buffers, {})

-- ####################
-- AUTO
-- ####################
-- vim.api.nvim_create_autocmd({"VimEnter", "BufAdd", "BufModifiedSet", "BufDelete", "BufWipeout"}, {
-- vim.api.nvim_create_autocmd({"BufEnter"}, {
-- 	callback = function(args)
-- 		local event_name = args.event or "unknown event"
-- 		print("--> Event fired: " .. event_name)
-- 		sync_buffers()
-- 	end,
-- 	desc = "Init BUFFERS",
-- })

-- local timer = vim.loop.new_timer()
-- vim.api.nvim_create_autocmd("TextChanged", {
-- 	callback = function()
-- 		if timer:is_active() then
-- 			timer:stop()
-- 		end
-- 		timer:start(100, 0, vim.schedule_wrap(function()
-- 			print("Buffer content changed")
-- 			sync_buffers()
-- 		end))
-- 	end,
-- 	desc = "Debounce Init BUFFERS",
-- })

-- ####################
-- LIST
-- ####################
local function list_buffers()
 	local buffers = get_buffers("named")
	if U.table_size(buffers) == 0 then
		print("No buffers exist.")
		return
	end


	local cwd = vim.fn.getcwd()
	print(string.format("%-5s %-5s %-50s %s", "Index", "Id", "Name", "Status"))
	for i, buf in ipairs(buffers) do
		local buf_num = buf.bufnr
		local buf_name = U.remove_matching_chars(cwd, buf.name)
		local buf_status = buf.changed == 1 and "Modified" or "Unmodified"

		print(string.format("%-5d %-5d %-50s %s", i, buf_num, buf_name, buf_status))
	end
end

vim.api.nvim_create_user_command("List", list_buffers, {})

-- ####################
-- OPEN
-- ####################
local function open_buffer(index)
 	local buffers = get_buffers("named")
	local idx = tonumber(index)

	-- no buffers
	if U.table_size(buffers) == 0 then
		print("No buffers exist.")
		-- BUFFERS = {}
		return
	end

	-- idx out of range
	if idx < 1 or idx > U.table_size(buffers) then
		print(idx .. " out of range [" .. 1 .. ", " .. U.table_size(buffers) .. "]")
		return
	end

	-- open buffer
	vim.cmd("buffer " .. buffers[idx].bufnr)
	-- BUFFERS = buffers
end

vim.api.nvim_create_user_command("Open", function(opts)
	open_buffer(opts.args)
end, {nargs = 1})

-- ####################
-- SWAP
-- ####################
-- local function swap_buffers(args)
-- 	-- invalid args
-- 	-- if not string.match(args, U.regex.space_numbers) then
-- 	--	 print("Delete buffers failed, invalid input. \"" .. args .. "\"")
-- 	--	 return
-- 	-- end
-- 
-- 	-- no buffers
-- 	if U.table_size(BUFFERS) == 0 then
-- 		print("No buffers exist.")
-- 		return
-- 	end
-- 
-- 	local indexes = U.string_to_number_table(args)
-- 
-- 	-- idx out of range
-- 	local invalid = {}
-- 	for i, n in ipairs(indexes) do
-- 		print("==> " .. n)
-- 		if n < 1 or n > U.table_size(BUFFERS) then
-- 			invalid[i] = n
-- 		end
-- 	end
-- 
-- 	print("--> " .. U.table_size(invalid))
-- 	-- print out of range args
-- 	if U.table_size(invalid) > 0 then
-- 		local str_invalid = table.concat(indexes, " ")
-- 		print(str_invalid .. " out of range [" .. 1 .. ", " .. U.table_size(BUFFERS) .. "]")
-- 		return
-- 	end
-- 
-- 	-- swap buffers
-- 	local temp_buf = BUFFERS[indexes[2]]
-- 	BUFFERS[indexes[2]] = BUFFERS[indexes[1]]
-- 	BUFFERS[indexes[1]] = temp_buf
-- end
-- 
-- vim.api.nvim_create_user_command("Swap", function(opts)
-- 	swap_buffers(opts.args)
-- end, {nargs = "+"})

-- ####################
-- DELETE
-- ####################
local function delete_buffers(args)
	local type = 
		(string.match(args, U.regex.number_range) and "range")
    	or (string.match(args, U.regex.space_numbers) and "indexes")
    	or "invalid"

	-- invalid args
	if type == "invalid" then
	  print("Invalid input: \"" .. args .. "\"")
	  return
	end

 	local buffers = get_buffers("named")
	-- no buffers
	if U.table_size(buffers) == 0 then
		print("No buffers exist.")
		return
	end

	local indexes = U.string_to_number_table(args)

	-- idx out of range
	local invalid = {}
	for i, idx in ipairs(indexes) do
		if idx < 1 or idx > U.table_size(buffers) then
			invalid[i] = idx
		end
	end

	-- print out of range args
	if U.table_size(invalid) > 0 then
		local str_invalid = table.concat(indexes, " ")
		print(str_invalid .. " out of range [" .. 1 .. ", " .. U.table_size(buffers) .. "]")
		return
	end

	-- delete buffers
	local ids = ""
	for _, i in ipairs(indexes) do
		ids = ids .. buffers[i].bufnr .. " "
	end

	local ok, err = pcall(function()
		vim.cmd("bdelete! " .. ids)
	end)

	if err then
		vim.notify("Failed to delete buffers " .. err)
	end
	-- BUFFERS = get_buffers("named")
end

vim.api.nvim_create_user_command("Delete", function(opts)
	delete_buffers(opts.args)
end, {nargs = "+"})

local function wipe_buffers()
	local buffers = get_buffers("unamed")
	local ids = ""
	for _, buf in ipairs(buffers) do
		ids = ids .. string.format("%d ", buf.bufnr)
	end
	if ids ~= "" then
		vim.cmd(string.format("bwipeout! %s", ids))
	else
		print("No unamed buffers exist.")
	end
end

vim.api.nvim_create_user_command("Wipe", function()
	wipe_buffers()
end, {})

local function print_table_keys(tbl)
	for k, v in pairs(tbl) do
		print(k .. " - " .. " " .. v)
		print()
	end
end

local function print_buffers(buffers)
	-- Get a list of all listed buffers

	-- Check if there are any buffers
	if U.table_size(buffers) == 0 then
		print("No buffers exist.")
		return
	end

	-- Print the header
	print(string.format("%-5s %-30s %s", "Num", "Name", "Status"))

	-- Iterate through the buffers and print their details
	for _, buf in ipairs(buffers) do
		local buf_num = buf.bufnr
		local buf_name = buf.name
		local buf_status = buf.changed == 1 and "Modified" or "Unmodified"

		-- Print buffer details
		print(string.format("%-5d %-30s %s", buf_num, buf_name, buf_status))
		print_table_keys(buf)
	end
end
