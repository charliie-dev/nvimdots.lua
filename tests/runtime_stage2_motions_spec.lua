local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local site = vim.fn.stdpath("data") .. "/site"
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(site)
vim.opt.runtimepath:append(site .. "/lazy/nvim-treesitter-textobjects")
vim.opt.runtimepath:append(root .. "/after")
vim.cmd("filetype plugin indent on")
require("keymap.edit")
require("modules.configs.editor.ts-textobjects")()
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
local fixtures = {
	python = {
		"# motions",
		"def first():",
		"    return 1",
		"",
		"class First:",
		"    pass",
		"",
		"def second():",
		"    return 2",
		"",
		"class Second:",
		"    pass",
		"# end",
	},
	go = {
		"package main",
		"",
		"type Example struct {",
		"    value int",
		"}",
		"",
		"func first() {",
		"    println(1)",
		"}",
		"",
		"func second() {",
		"    println(2)",
		"}",
		"// end",
	},
}
local targets = {
	python = { ["]["] = 2, ["]]"] = 3, ["]m"] = 5, ["]M"] = 6, ["[["] = 8, ["[]"] = 9, ["[m"] = 11, ["[M"] = 12 },
	go = { ["]["] = 7, ["]]"] = 9, ["[["] = 11, ["[]"] = 13 },
}
local global_maps = {}
for _, mode in ipairs({ "n", "x", "o" }) do
	global_maps[mode] = {}
	for lhs in pairs(targets.python) do
		global_maps[mode][lhs] = vim.fn.maparg(lhs, mode, false, true).callback
	end
end
for _, ft in ipairs({ "python", "go" }) do
	vim.cmd.enew({ bang = true })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, fixtures[ft])
	vim.bo.filetype = ft
	test(ft .. " native ftplugins run without shadowing configured motions", function()
		assert(vim.b.did_ftplugin, "native ftplugin did not run")
		assert(vim.g.no_plugin_maps == nil and vim.g["no_" .. ft .. "_maps"] == nil, "native maps disabled")
		for _, mode in ipairs({ "n", "x", "o" }) do
			for lhs in pairs(targets[ft]) do
				local mapping = vim.fn.maparg(lhs, mode, false, true)
				assert(mapping.callback == global_maps[mode][lhs], mode .. " " .. lhs .. " still shadowed")
			end
		end
	end)
	test(ft .. " existing normal keys move to Treesitter function/class boundaries", function()
		for lhs, row in pairs(targets[ft]) do
			vim.api.nvim_win_set_cursor(0, { lhs:sub(1, 1) == "]" and 1 or #fixtures[ft], 0 })
			keys(lhs)
			assert(vim.api.nvim_win_get_cursor(0)[1] == row, lhs .. " expected row " .. row)
		end
	end)
	test(ft .. " visual and operator motions preserve Treesitter selection", function()
		local lhs, row = ft == "python" and "]m" or "][", ft == "python" and 5 or 7
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		keys("v" .. lhs)
		assert(vim.api.nvim_win_get_cursor(0)[1] == row, "visual motion reached wrong node")
		keys("<Esc>")
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		keys("y" .. lhs)
		assert(vim.fn.getreg('"'):find(fixtures[ft][row - 2], 1, true), "operator did not span preceding code")
		assert(not vim.fn.getreg('"'):find(fixtures[ft][row], 1, true), "operator included the target node")
	end)
end

test("unrelated native mappings and user motion overrides survive", function()
	vim.cmd.enew({ bang = true })
	vim.bo.filetype = "go"
	assert(vim.fn.exists(":GoKeywordPrg") == 2, "Go documentation command was disabled")
	vim.keymap.set("n", "gQ", "<Nop>", { buffer = true, desc = "unrelated buffer map" })
	local called = false
	vim.keymap.set("n", "][", function()
		called = true
	end)
	vim.cmd("runtime! after/ftplugin/go.lua")
	assert(vim.fn.maparg("gQ", "n", false, true).desc == "unrelated buffer map", "unrelated map removed")
	keys("][")
	assert(called, "user's global motion override was shadowed")
end)
if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end
print(string.format("runtime_stage2_motions_spec: %d tests passed", tests_run))
