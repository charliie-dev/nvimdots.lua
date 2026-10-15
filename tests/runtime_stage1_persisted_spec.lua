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

				test("session load does not re-read a buffer switched to after the load", function()
					local file_a, file_b = directory .. "/a.txt", directory .. "/b.txt"
					vim.fn.writefile({ "a" }, file_a)
					vim.fn.writefile({ "b" }, file_b)
					vim.cmd.edit(file_a)
					local restore = directory .. "/restore.vim"
					persisted.save({ session = restore, force = true })
					local reads = {}
					local group = vim.api.nvim_create_augroup("PersistedSpecReads", { clear = true })
					vim.api.nvim_create_autocmd("BufReadPost", {
						group = group,
						callback = function(args)
							reads[#reads + 1] = vim.fs.basename(vim.api.nvim_buf_get_name(args.buf))
						end,
					})
					-- Another LoadPost handler moves to B right after the session is restored. `nested` lets
					-- that switch fire BufReadPost, so a later re-read of B shows up as a second read.
					vim.api.nvim_create_autocmd("User", {
						group = group,
						pattern = "PersistedLoadPost",
						nested = true,
						callback = function()
							vim.cmd.edit(file_b)
						end,
					})
					persisted.load({ session = restore })
					vim.wait(50)
					vim.api.nvim_del_augroup_by_id(group)
					local b_reads = #vim.tbl_filter(function(name)
						return name == "b.txt"
					end, reads)
					assert(b_reads == 1, "b.txt was read " .. b_reads .. " times: " .. vim.inspect(reads))
				end)

				test("the session picker loads the selected branch's session", function()
					local repo = assert(vim.uv.fs_realpath((function()
						local dir = vim.fn.tempname()
						vim.fn.mkdir(dir, "p")
						return dir
					end)()))
					local cwd, select = vim.uv.cwd(), vim.ui.select
					local function git(...)
						local cmd =
							{ "git", "-C", repo, "-c", "core.hooksPath=/dev/null", "-c", "commit.gpgsign=false" }
						vim.list_extend(cmd, { "-c", "user.name=t", "-c", "user.email=t@t", ... })
						local result = vim.system(cmd, { text = true }):wait()
						assert(result.code == 0, table.concat({ ... }, " ") .. ": " .. result.stderr)
					end
					local ok, err = pcall(function()
						git("init", "-q", "-b", "one")
						git("commit", "-q", "--allow-empty", "--no-verify", "-m", "x")
						vim.fn.chdir(repo)
						for _, branch in ipairs({ "one", "two" }) do
							if branch == "two" then
								git("checkout", "-q", "-b", "two")
							end
							vim.fn.writefile({ branch }, repo .. "/" .. branch .. ".txt")
							vim.cmd("silent! %bwipeout!")
							vim.cmd.edit(repo .. "/" .. branch .. ".txt")
							persisted.save({ force = true })
						end
						-- Still on branch two: choose the session saved on branch one
						vim.ui.select = function(items, _, on_choice)
							for _, item in ipairs(items) do
								if item.branch == "one" then
									return on_choice(item)
								end
							end
							error("no session for branch one: " .. vim.inspect(items))
						end
						local pick = vim.fn.maparg(",so", "n", false, true)
						assert(pick.callback, "no session picker on ,so")
						-- Persisted sources the session from vim.schedule; wait for LoadPost in short steps
						local loaded = false
						vim.api.nvim_create_autocmd("User", {
							pattern = "PersistedLoadPost",
							once = true,
							callback = function()
								loaded = true
							end,
						})
						pick.callback()
						local deadline = vim.uv.now() + 1000
						while not loaded and vim.uv.now() < deadline do
							vim.wait(20)
						end
						assert(loaded, "the chosen session was not loaded")
						assert(vim.fn.expand("%:t") == "one.txt", "loaded the session with " .. vim.fn.expand("%:t"))
					end)
					vim.ui.select = select
					vim.fn.chdir(cwd)
					vim.fn.delete(repo, "rf")
					assert(ok, err)
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
