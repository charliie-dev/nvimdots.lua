assert(package.loaded.core == nil, "persisted_spec must be sourced before init.lua")
local directory = vim.fn.tempname()
vim.fn.mkdir(directory, "p")
package.preload["user.configs.persisted"] = function()
	return { save_dir = directory .. "/", autostart = false }
end

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
			local ok, err = xpcall(function()
				local plugins = require("lazy.core.config").plugins
				assert(not plugins["persisted.nvim"]._.loaded, "Persisted loaded before its command")
				vim.cmd("Persisted stop")
				local persisted = require("persisted")
				local config = require("persisted.config")
				assert(config.save_dir == directory .. "/", "session writes escaped test directory")
				local session = persisted.current()
				local sentinel = { "existing session must survive dashboard autosave" }

				for _, filetype in ipairs({ "snacks_dashboard", "text", "" }) do
					test("should_save gates filetype=" .. filetype, function()
						vim.bo.filetype = filetype
						assert(config.should_save() == (filetype ~= "snacks_dashboard"), "wrong save decision")
					end)
				end

				test("unforced dashboard save leaves existing session untouched", function()
					vim.bo.filetype = "snacks_dashboard"
					vim.fn.writefile(sentinel, session)
					persisted.save()
					assert(vim.deep_equal(vim.fn.readfile(session), sentinel), "dashboard overwrote session")
				end)

				test("dashboard exit autosave leaves existing session untouched", function()
					vim.bo.filetype = "snacks_dashboard"
					vim.fn.writefile(sentinel, session)
					persisted.start()
					vim.api.nvim_exec_autocmds("VimLeavePre", { group = "Persisted", modeline = false })
					persisted.stop()
					assert(vim.deep_equal(vim.fn.readfile(session), sentinel), "dashboard autosave overwrote session")
				end)

				test("ordinary buffer exit autosave still writes a session", function()
					vim.bo.filetype = "text"
					vim.fn.writefile(sentinel, session)
					persisted.start()
					vim.api.nvim_exec_autocmds("VimLeavePre", { group = "Persisted", modeline = false })
					persisted.stop()
					local contents = table.concat(vim.fn.readfile(session), "\n")
					assert(contents:find("SessionLoad", 1, true), "ordinary autosave did not write a session")
				end)

				test("manual save mapping still forces dashboard session save", function()
					vim.bo.filetype = "snacks_dashboard"
					vim.fn.writefile(sentinel, session)
					keys(",ss")
					local contents = table.concat(vim.fn.readfile(session), "\n")
					assert(contents:find("SessionLoad", 1, true), "manual save no longer overrides dashboard exclusion")
				end)
				persisted.stop()
			end, debug.traceback)
			if not ok then
				failures[#failures + 1] = err
			end
			if package.loaded.persisted then
				require("persisted").stop()
			end
			vim.fn.delete(directory, "rf")
			if #failures > 0 then
				vim.api.nvim_err_writeln(table.concat(failures, "\n"))
				vim.cmd.cquit(1)
			end
			print("runtime_stage1_persisted_spec: " .. tests_run .. " tests passed")
			vim.cmd("qa!")
		end, 300)
	end,
})
