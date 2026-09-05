local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local source_file = vim.fn.argv(0)
local overrides = vim.env.NVIM_TEST_OVERRIDES == "1"
local failures, tests_run = {}, 0

local function test(name, callback)
	tests_run = tests_run + 1
	local ok, err = xpcall(callback, debug.traceback)
	if ok then
		print("PASS " .. name)
	else
		failures[#failures + 1] = name .. ": " .. err
		print("FAIL " .. name)
	end
end

local function keys(input)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
end

assert(package.loaded.core == nil, "startup_spec must run before init.lua")
if overrides then
	package.preload["hm-generated"] = function()
		vim.g.startup_test_hm = true
	end
	package.preload["user.settings"] = function()
		assert(vim.loader.enabled, "core settings loaded before the bytecode cache was enabled")
		return { transparent_background = false }
	end
	package.preload["user.options"] = function()
		return { scrolloff = 7 }
	end
	package.preload["user.keymap.init"] = function()
		return {
			{
				"n",
				"<leader>zt",
				function()
					vim.g.startup_test_keymap = true
				end,
			},
		}
	end
	package.preload["user.configs.align"] = function()
		return { mappings = { start = "gza" } }
	end
end

local function run_tests()
	local plugins = require("lazy.core.config").plugins
	test("actual init resolves configuration and callbacks to this checkout", function()
		assert(vim.fn.stdpath("config") == root, "stdpath resolved a different checkout")
		assert(require("core.global").vim_path == vim.uv.fs_realpath(root), "core resolved a different checkout")
		assert(vim.tbl_contains(vim.opt.rtp:get(), root), "checkout missing from runtimepath")
		assert(vim.loader.enabled, "native bytecode loader is disabled")
		for _, group in ipairs({ "completion", "editor", "lang", "tool", "ui" }) do
			for name, spec in pairs(require("modules.plugins." .. group)) do
				for _, field in ipairs({ "config", "init" }) do
					if type(spec[field]) == "function" then
						local source = debug.getinfo(spec[field], "S").source
						if name == "nvim-treesitter/nvim-treesitter" and field == "config" then
							assert(
								spec[field] == require("modules.configs.editor.treesitter"),
								"wrong Treesitter callback"
							)
						else
							assert(source:sub(1, #root + 1) == "@" .. root, name .. ": " .. source)
						end
					end
				end
			end
		end
		assert(package.loaded["modules.configs.completion.blink"], "config bypassed the runtime module loader")
		assert(package.loaded["modules.configs.editor.align"], "config was deferred instead of cached")
	end)

	test("leader options colors and initial buffer are preserved", function()
		assert(vim.g.mapleader == ",", "leader changed")
		assert(
			vim.o.termguicolors and vim.o.updatetime == 200 and vim.o.clipboard == "unnamedplus",
			"core options changed"
		)
		assert(vim.o.scrolloff == (overrides and 7 or 3), "option override was ignored")
		assert(vim.g.colors_name == "catppuccin-mocha", tostring(vim.g.colors_name))
		if source_file ~= "" then
			assert(vim.api.nvim_buf_get_name(0) == vim.fn.fnamemodify(source_file, ":p"), "wrong initial buffer")
			assert(
				vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), vim.fn.readfile(source_file)),
				"file contents changed"
			)
			assert(vim.bo.filetype == "lua", "initial filetype missing")
			assert(
				vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()],
				"initial-file highlighting missing"
			)
			assert(plugins["nvim-lspconfig"]._.loaded, "first-file LSP trigger did not run")
			assert(vim.lsp.config.lua_ls.settings.Lua.runtime.version == "LuaJIT", "Lua server configuration missing")
		else
			assert(vim.api.nvim_buf_get_name(0) == "", "unexpected named buffer")
			assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "" }), "initial buffer is not empty")
		end
		if overrides then
			assert(vim.g.startup_test_hm, "Home Manager hook did not run")
			assert(vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg, "theme override was ignored")
			keys(",zt")
			assert(vim.g.startup_test_keymap, "user keymap was not installed")
		end
	end)

	test("CursorHold loads configured alignment and dial behavior", function()
		assert(
			not plugins["mini.align"]._.loaded and not plugins["dial.nvim"]._.loaded,
			"plugins loaded before CursorHold"
		)
		vim.api.nvim_exec_autocmds("CursorHold", { modeline = false })
		assert(plugins["mini.align"]._.loaded and plugins["dial.nvim"]._.loaded, "CursorHold did not load plugins")
		local align_key = overrides and "gza" or "gea"
		assert(require("mini.align").config.mappings.start == align_key, "alignment configuration missing")
		assert(vim.fn.maparg(align_key, "x") ~= "", "alignment mapping missing")
		vim.cmd.enew()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "and" })
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		keys(",=")
		assert(vim.api.nvim_get_current_line() == "or", "configured word increment did not run")
		keys(",-")
		assert(vim.api.nvim_get_current_line() == "and", "configured word decrement did not run")
		vim.bo.modified = false
	end)

	test("command loads Overseer and opens its task list", function()
		assert(not plugins["overseer.nvim"]._.loaded, "Overseer loaded before command")
		vim.cmd.OverseerOpen()
		assert(plugins["overseer.nvim"]._.loaded, "Overseer command did not load plugin")
		assert(
			vim.iter(vim.api.nvim_list_wins()):any(function(win)
				return vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "OverseerList"
			end),
			"Overseer task list missing"
		)
		vim.cmd.OverseerClose()
	end)

	test("first quickfix window loads language config and opens its entry", function()
		assert(not plugins["nvim-bqf"]._.loaded, "bqf loaded before quickfix FileType")
		local file = root .. "/lua/core/options.lua"
		vim.fn.setqflist({ { filename = file, lnum = 1, text = "startup fixture" } })
		vim.cmd.copen()
		assert(vim.bo.filetype == "qf" and plugins["nvim-bqf"]._.loaded, "quickfix did not load bqf")
		local preview = require("bqf.config").preview
		assert(preview.border == "single" and preview.wrap and preview.winblend == 0, "bqf configuration missing")
		keys("<CR>")
		assert(vim.api.nvim_buf_get_name(0) == file, "quickfix entry did not open its file")
		assert(vim.api.nvim_win_get_cursor(0)[1] == 1, "quickfix entry opened at the wrong line")
		vim.cmd.cclose()
	end)

	test("search keymap loads grug-far and opens its editor", function()
		assert(not plugins["grug-far.nvim"]._.loaded, "grug-far loaded before keymap")
		keys(",Ss")
		assert(plugins["grug-far.nvim"]._.loaded, "search keymap did not load plugin")
		assert(vim.bo.filetype == "grug-far", "search mapping did not open grug-far")
	end)

	test("startup and first use emit no errors", function()
		vim.wait(100)
		local messages = vim.api.nvim_exec2("messages", { output = true }).output
		for _, pattern in ipairs({ "Error detected", "Failed to source", "Failed to run", "Failed to load" }) do
			assert(not messages:find(pattern, 1, true), messages)
		end
		for _, notification in ipairs(require("snacks.notifier").get_history()) do
			assert(
				notification.level ~= "error" and notification.level ~= vim.log.levels.ERROR,
				vim.inspect(notification)
			)
		end
	end)
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			local ok, err = xpcall(run_tests, debug.traceback)
			if not ok then
				failures[#failures + 1] = err
			end
			if #failures > 0 then
				vim.api.nvim_err_writeln(table.concat(failures, "\n"))
				vim.cmd.cquit(1)
			end
			print(
				string.format(
					"startup_spec: %d tests passed (file=%s, overrides=%s)",
					tests_run,
					source_file,
					overrides
				)
			)
			vim.cmd("qa!")
		end, 300)
	end,
})
