assert(package.loaded.core == nil, "sniprun_spec must be sourced before init.lua")
local failures, tests_run = {}, 0
local function test(name, callback)
	tests_run = tests_run + 1
	local ok, err = xpcall(callback, debug.traceback)
	print((ok and "PASS " or "FAIL ") .. name)
	if not ok then
		failures[#failures + 1] = name .. ": " .. err
	end
end

local function keys(input)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			local jobstart, rpcnotify = vim.fn.jobstart, vim.rpcnotify
			local calls, starts = {}, 0
			local channel = 424242
			-- Exercise the real launcher and range logic without starting an interpreter.
			vim.fn.jobstart = function(argv, opts)
				assert(argv[1]:match("/sniprun/target/release/sniprun$"), vim.inspect(argv))
				assert(opts.rpc, "Sniprun did not request RPC")
				starts = starts + 1
				return channel
			end
			vim.rpcnotify = function(id, method, first, last)
				assert(id == channel and method == "run", "unexpected RPC request")
				calls[#calls + 1] = { first, last }
			end

			local ok, err = xpcall(function()
				local plugins = require("lazy.core.config").plugins
				assert(not plugins.sniprun._.loaded, "Sniprun loaded before first mapping")
				vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "second", "third", "fourth", "fifth" })
				for _, case in ipairs({
					{
						name = "first visual invocation loads plugin with selected lines",
						row = 2,
						keys = "V2j",
						range = { 2, 4 },
					},
					{ name = "backward linewise selection", row = 4, keys = "V2k", range = { 2, 4 } },
					{ name = "characterwise selection", row = 2, keys = "vj", range = { 2, 3 } },
					{ name = "blockwise selection", row = 2, keys = "<C-v>2j", range = { 2, 4 } },
					{ name = "single-line selection", row = 3, keys = "V", range = { 3, 3 } },
					{ name = "whole-buffer selection", row = 1, keys = "VG", range = { 1, 5 } },
					{ name = "normal mapping still runs whole file", row = 3, keys = "", range = { 1, 5 } },
				}) do
					test(case.name, function()
						keys("<Esc>")
						vim.api.nvim_win_set_cursor(0, { case.row, 0 })
						local before = #calls
						keys(case.keys .. ",r")
						assert(plugins.sniprun._.loaded, "mapping did not load Sniprun")
						assert(#calls == before + 1, "mapping did not send exactly one run request")
						assert(
							vim.deep_equal(calls[#calls], case.range),
							"expected " .. vim.inspect(case.range) .. ", got " .. vim.inspect(calls[#calls])
						)
					end)
				end
				assert(starts == 1, "backend start interception was not exercised")
			end, debug.traceback)
			vim.fn.jobstart, vim.rpcnotify = jobstart, rpcnotify
			if package.loaded.sniprun then
				require("sniprun").job_id = nil
			end
			if not ok then
				failures[#failures + 1] = err
			end
			if #failures > 0 then
				vim.api.nvim_err_writeln(table.concat(failures, "\n"))
				vim.cmd.cquit(1)
			end
			print("runtime_stage1_sniprun_spec: " .. tests_run .. " tests passed (RPC intercepted)")
			vim.cmd("qa!")
		end, 300)
	end,
})
