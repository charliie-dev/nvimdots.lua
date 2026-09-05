local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/lazy/nvim-treesitter")
local failures, tests_run = {}, 0
local function test(name, callback)
	tests_run = tests_run + 1
	local ok, err = xpcall(callback, debug.traceback)
	print((ok and "PASS " or "FAIL ") .. name)
	if not ok then
		failures[#failures + 1] = name .. ": " .. err
	end
end

local ts = require("nvim-treesitter")
local installed, install_calls = {}, 0
-- Installation is the only I/O boundary replaced; parsers and queries are real.
ts.install = function(parsers)
	installed = parsers
	install_calls = install_calls + 1
end
local notifications = {}
vim.notify = function(message, level)
	notifications[#notifications + 1] = { message = message, level = level }
end
local indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
local function buffer(ft)
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "[test]", "values = [", "1,", "]" })
	vim.v.errmsg = ""
	vim.bo[buf].filetype = ft
	assert(vim.v.errmsg == "", vim.v.errmsg)
	return buf
end
local existing = { buffer("toml"), buffer("toml") }
require("modules.configs.editor.treesitter")()

test("FileType registration and loaded-buffer catch-up are synchronous", function()
	assert(install_calls == 0, "parser installation ran synchronously")
	for _, buf in ipairs(existing) do
		assert(vim.treesitter.highlighter.active[buf], "existing buffer highlighting missing")
		assert(vim.bo[buf].indentexpr == indentexpr, "existing buffer indentation missing")
	end
	local buf = buffer("toml")
	assert(vim.treesitter.highlighter.active[buf], "immediate FileType was missed")
	assert(vim.bo[buf].indentexpr == indentexpr, "immediate FileType indentation missing")
end)

vim.wait(100)
test("parser installation remains deferred with the configured sorted list", function()
	local expected = vim.tbl_keys(require("core.settings").treesitter_deps)
	table.sort(expected)
	assert(install_calls == 1 and vim.deep_equal(installed, expected), "installation contract changed")
end)

test("a missing parser with a stale query is quietly skipped", function()
	local lang = "stage2_missing_parser"
	local ok, added = pcall(vim.treesitter.language.add, lang)
	assert(ok and not added, "test language unexpectedly has a parser")
	vim.treesitter.query.set(lang, "highlights", "(_) @string")
	local count = #notifications
	local buf = buffer(lang)
	assert(not vim.treesitter.highlighter.active[buf], "missing parser was highlighted")
	assert(vim.bo[buf].indentexpr == "", "missing parser received an indentexpr")
	assert(#notifications == count, "missing optional parser emitted a warning")
end)

for _, name in ipairs({ "highlights", "indents" }) do
	test("invalid " .. name .. " query is diagnosed without disabling the other feature", function()
		vim.treesitter.query.set("toml", name, "(stage2_invalid_node) @string")
		local count = #notifications
		local ok, result = pcall(buffer, "toml")
		vim.treesitter.query.set("toml", name, nil)
		assert(ok, result)
		assert(#notifications > count, "invalid query was not diagnosed")
		local warning = notifications[#notifications]
		assert(warning.level == vim.log.levels.WARN, "query failure should be a warning")
		assert(warning.message:find("toml", 1, true) and warning.message:find(name, 1, true), warning.message)
		if name == "indents" then
			assert(vim.treesitter.highlighter.active[result], "invalid indents disabled highlighting")
		else
			assert(vim.bo[result].indentexpr == indentexpr, "invalid highlights disabled indentation")
		end
	end)
end

test("installed parsers outside the installation list remain enabled", function()
	vim.treesitter.language.register("lua", "stage2_external")
	local buf = buffer("stage2_external")
	assert(vim.treesitter.highlighter.active[buf], "installed external language was disabled")
	assert(vim.bo[buf].indentexpr == indentexpr, "external language indentation missing")
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end
print(string.format("runtime_stage2_syntax_spec: %d tests passed", tests_run))
