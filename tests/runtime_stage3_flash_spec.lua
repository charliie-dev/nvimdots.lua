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

require("lazy.core.loader").load("flash.nvim", { cmd = "test" }, { force = true })
local char = require("flash.plugins.char")
vim.cmd.enew()
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "x one x two x three x", "x four x five" })
vim.o.hlsearch = true

local function search()
	keys("/x<CR>")
	assert(vim.v.hlsearch == 1, "search highlight was not enabled")
end

test("Esc clears ordinary search before any Flash motion", function()
	assert(char.state == nil, "test requires a fresh Flash state")
	search()
	keys("<Esc>")
	assert(vim.v.hlsearch == 0, "ordinary search highlight remained")
end)

test("Esc inside the real Flash label loop hides Flash without clearing search", function()
	search()
	keys("fx<Esc>")
	assert(char.state and not char.visible(), "Flash label loop did not hide its state")
	assert(vim.v.hlsearch == 1, "Flash cancellation cleared ordinary search")
	keys("<Esc>")
	assert(vim.v.hlsearch == 0, "the next normal Esc did not clear search")
end)

test("ordinary search clears after a completed Flash motion", function()
	keys("fx<CR>")
	assert(char.state and not char.visible(), "Flash motion did not retain a hidden state")
	search()
	keys("<Esc>")
	assert(vim.v.hlsearch == 0, "hidden Flash state swallowed normal search Esc")
end)

test("mapped Esc sees real visible Flash before hiding it, then clears search on the next Esc", function()
	local config = require("flash.config").get()
	config.modes.char.jump_labels = false
	require("flash").setup(config)
	search()
	keys("fx")
	assert(char.visible(), "real character motion did not leave visible highlights")
	local observed
	local ns = vim.api.nvim_create_namespace("runtime_stage3_flash_order")
	vim.on_key(function(key, typed)
		if typed == "\27" then
			observed = { key = key, visible = char.visible() }
		end
	end, ns)
	keys("<Esc>")
	vim.on_key(nil, ns)
	assert(observed and observed.key ~= "\27", "mapped Esc was not expanded before on_key")
	assert(observed.visible, "upstream on_key hid Flash before the mapping")
	assert(not char.visible(), "Esc failed to hide Flash")
	assert(vim.v.hlsearch == 1, "first Esc cleared search instead of only hiding Flash")
	keys("<Esc>")
	assert(vim.v.hlsearch == 0, "second Esc did not clear normal search")
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("runtime_stage3_flash_spec: %d tests passed", tests_run))
vim.cmd.qa({ bang = true })
