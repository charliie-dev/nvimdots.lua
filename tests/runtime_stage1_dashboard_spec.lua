local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

if not vim.g.runtime_stage1_ui_child then
	local stderr = {}
	local child = vim.fn.jobstart({
		vim.v.progpath,
		"--embed",
		"-u",
		root .. "/init.lua",
		"-i",
		"NONE",
		"--cmd",
		"luafile " .. root .. "/tests/bootstrap.lua",
		"--cmd",
		"lua vim.g.runtime_stage1_ui_child = true",
		"--cmd",
		"luafile " .. root .. "/tests/runtime_stage1_dashboard_spec.lua",
	}, {
		rpc = true,
		on_stderr = function(_, data)
			vim.list_extend(stderr, data)
		end,
	})
	assert(child > 0, "could not start embedded Neovim")
	local ok, result = xpcall(function()
		vim.rpcrequest(child, "nvim_ui_attach", 120, 40, { rgb = true })
		local results
		assert(
			vim.wait(10000, function()
				results = vim.rpcrequest(child, "nvim_get_var", "runtime_stage1_results")
				return results.done
			end, 20),
			"dashboard tests timed out"
		)
		return results
	end, debug.traceback)
	vim.fn.jobstop(child)
	vim.fn.jobwait({ child }, 1000)
	assert(ok, tostring(result) .. "\n" .. table.concat(stderr, "\n"))
	for _, message in ipairs(result.messages) do
		print(message)
	end
	assert(#result.failures == 0, table.concat(result.failures, "\n"))
	print("runtime_stage1_dashboard_spec: " .. #result.messages .. " tests passed (attached UI)")
	return
end

assert(package.loaded.core == nil, "dashboard_spec must be sourced before init.lua")
vim.g.runtime_stage1_results = { done = false }
local results = { done = false, messages = {}, failures = {} }
local function test(name, callback)
	local ok, err = xpcall(callback, debug.traceback)
	results.messages[#results.messages + 1] = (ok and "PASS " or "FAIL ") .. name
	if not ok then
		results.failures[#results.failures + 1] = name .. ": " .. err
	end
end

local function keys(input)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
end

vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		local options = { showtabline = vim.o.showtabline, laststatus = vim.o.laststatus }
		vim.defer_fn(function()
			test("startup dashboard hides global chrome with a real attached UI", function()
				assert(vim.fn.stdpath("config") == root, "wrong configuration checkout")
				assert(#vim.api.nvim_list_uis() == 1, "UI was not attached")
				assert(require("snacks.dashboard").status.opened, "startup dashboard did not open")
				assert(vim.bo.filetype == "snacks_dashboard", "wrong startup buffer")
				assert(options.showtabline == 2 and options.laststatus == 3, vim.inspect(options))
				assert(vim.o.showtabline == 0 and vim.o.laststatus == 0, "startup chrome was not hidden")
			end)

			test("dashboard FileType does not write window-scoped global options", function()
				vim.v.errmsg = ""
				vim.api.nvim_exec_autocmds("FileType", { pattern = "snacks_dashboard", modeline = false })
				assert(vim.v.errmsg == "", vim.v.errmsg)
				assert(vim.o.showtabline == 0, "FileType changed startup tabline")
			end)

			test("leaving startup dashboard restores tabline", function()
				keys("e")
				assert(vim.bo.filetype ~= "snacks_dashboard", "new-file dashboard action did not leave")
				assert(
					vim.wait(1000, function()
						return vim.o.showtabline == options.showtabline
					end),
					"startup tabline was not restored"
				)
			end)

			for _, floating in ipairs({ true, false }) do
				test("manual dashboard preserves tabline (floating=" .. tostring(floating) .. ")", function()
					local tabline, laststatus = vim.o.showtabline, vim.o.laststatus
					assert(tabline == options.showtabline, "tabline was already hidden")
					vim.v.errmsg = ""
					local dashboard = require("snacks.dashboard").open(floating and {} or { win = 0 })
					assert(vim.bo.filetype == "snacks_dashboard", "manual dashboard did not open")
					assert(vim.o.showtabline == tabline, "manual dashboard changed tabline")
					assert(vim.o.laststatus == laststatus, "manual dashboard changed statusline")
					vim.api.nvim_buf_delete(dashboard.buf, { force = true })
					vim.wait(50)
					assert(not vim.api.nvim_buf_is_valid(dashboard.buf), "manual dashboard was not wiped")
					assert(vim.o.showtabline == tabline, "closing manual dashboard changed tabline")
					assert(vim.o.laststatus == laststatus, "closing manual dashboard changed statusline")
					assert(vim.v.errmsg == "", vim.v.errmsg)
				end)
			end

			test("dashboard lifecycle emits no runtime errors", function()
				local messages = vim.api.nvim_exec2("messages", { output = true }).output
				for _, pattern in ipairs({ "Error detected", "Lua callback:", "Failed to load", "Failed to run" }) do
					assert(not messages:find(pattern, 1, true), messages)
				end
				for _, notification in ipairs(require("snacks.notifier").get_history()) do
					assert(
						notification.level ~= "error" and notification.level ~= vim.log.levels.ERROR,
						vim.inspect(notification)
					)
				end
			end)
			results.done = true
			vim.g.runtime_stage1_results = results
		end, 300)
	end,
})
