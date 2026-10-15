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

test("a go.work opened first loads go.nvim and its workspace commands", function()
	assert(not loaded("go.nvim"), "go.nvim loaded at startup")
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	vim.fn.writefile({ "go 1.22", "", "use ." }, dir .. "/go.work")
	local ok, err = pcall(function()
		vim.cmd.edit(dir .. "/go.work")
		assert(vim.bo.filetype == "gowork", "filetype=" .. vim.bo.filetype)
		assert(loaded("go.nvim"), "go.work did not load go.nvim")
		assert(vim.fn.exists(":GoWork") == 2, ":GoWork is missing")
	end)
	vim.cmd("silent! bwipeout!")
	vim.fn.delete(dir, "rf")
	assert(ok, err)
end)

test("the first list buffers continue, renumber, indent and toggle bullets", function()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	local leader = vim.g.mapleader
	-- { file, lines, cursor, keys, expected lines }
	local cases = {
		{ "a.md", { "- item" }, { 1, 0 }, "A<CR>next<Esc>", { "- item", "- next" } },
		{ "b.md", { "1. one" }, { 1, 0 }, "A<CR>two<Esc>", { "1. one", "2. two" } },
		{ "c.md", { "- item" }, { 1, 0 }, "onext<Esc>", { "- item", "- next" } },
		{ "d.md", { "- item", "- " }, { 2, 0 }, "A<CR><Esc>", { "- item", "" } },
		{ "e.md", { "1. a", "5. b", "9. c" }, { 1, 0 }, "gN", { "1. a", "2. b", "3. c" } },
		{ "f.md", { "- a", "- b" }, { 2, 0 }, ">>", { "- a", "    * b" } },
		{ "g.md", { "1. a", "2. b", "3. c" }, { 2, 0 }, "Vj>", { "1. a", "    a. b", "    b. c" } },
		{ "h.md", { "1. a", "\ta. b", "\tb. c" }, { 2, 0 }, "Vj<", { "1. a", "2. b", "3. c" } },
		-- Visual changes in the middle of a list renumber the items after the selection too
		{ "g2.md", { "1. a", "2. b", "3. c", "4. d" }, { 2, 0 }, "Vj>", { "1. a", "    a. b", "    b. c", "2. d" } },
		{ "h2.md", { "1. a", "\ta. b", "\tb. c", "2. d" }, { 2, 0 }, "V<", { "1. a", "2. b", "\ta. c", "3. d" } },
		{ "i.md", { "- a", "- b" }, { 2, 0 }, "A<C-t><Esc>", { "- a", "    * b" } },
		{ "j.md", { "- [ ] task" }, { 1, 0 }, leader .. "x", { "- [X] task" } },
		{ "k.txt", { "- item" }, { 1, 0 }, "A<CR>next<Esc>", { "- item", "- next" } },
		{
			"COMMIT_EDITMSG",
			{ "subject", "", "- item" },
			{ 3, 0 },
			"A<CR>next<Esc>",
			{ "subject", "", "- item", "- next" },
		},
	}
	local ok, err = pcall(function()
		for _, case in ipairs(cases) do
			vim.cmd.edit(dir .. "/" .. case[1])
			vim.api.nvim_buf_set_lines(0, 0, -1, false, case[2])
			vim.api.nvim_win_set_cursor(0, case[3])
			keys(case[4])
			assert(vim.deep_equal(lines(), case[5]), ("%s %s: %s"):format(case[1], case[4], vim.inspect(lines())))
			vim.bo.modified = false
		end
	end)
	vim.cmd("silent! %bwipeout!")
	vim.fn.delete(dir, "rf")
	assert(ok, err)
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("runtime_stage2_first_idle_spec: %d tests passed", tests_run))
vim.cmd.qa({ bang = true })
