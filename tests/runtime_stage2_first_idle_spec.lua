-- Runs from a startup command, before the first CursorHold can load the idle-loaded plugins.
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
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "xt", false)
	vim.bo.modified = false
end

local function keys(input)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "xt", false)
end

local plugins = require("lazy.core.config").plugins
local function loaded(name)
	return plugins[name]._.loaded ~= nil
end

local function lines()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function buffer(content)
	vim.cmd.enew({ bang = true })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

test("idle-loaded plugins are not loaded before the first idle", function()
	for _, name in ipairs({ "mini.align", "dial.nvim", "smart-paste.nvim" }) do
		assert(not loaded(name), name .. " loaded at startup")
	end
end)

test("the first alignment key loads mini.align and aligns", function()
	buffer({ "a = 1", "bb = 2" })
	keys("geaip=")
	assert(loaded("mini.align"), "gea did not load mini.align")
	assert(vim.deep_equal(lines(), { "a  = 1", "bb = 2" }), vim.inspect(lines()))
end)

test("the first normal increment loads dial and keeps its count", function()
	buffer({ "x 1" })
	keys("3,=")
	assert(loaded("dial.nvim"), "the increment did not load dial")
	assert(vim.deep_equal(lines(), { "x 4" }), vim.inspect(lines()))
end)

test("the first yank loads smart-paste before the first paste", function()
	buffer({ "line" })
	keys('"ayy')
	assert(loaded("smart-paste.nvim"), "yank did not load smart-paste")
	keys('2"ap')
	assert(vim.deep_equal(lines(), { "line", "line", "line" }), vim.inspect(lines()))
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("runtime_stage2_first_idle_spec: %d tests passed", tests_run))
vim.cmd.qa({ bang = true })
