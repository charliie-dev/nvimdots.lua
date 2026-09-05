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

local function buffer()
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "expression", "second", "third" })
	return buf
end

local function attach(buf)
	vim.api.nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = -1 } })
end

local function map(buf, mode)
	return vim.api.nvim_buf_call(buf, function()
		return vim.fn.maparg("K", mode or "n", false, true)
	end)
end

local function global_map(mode)
	for _, mapping in ipairs(vim.api.nvim_get_keymap(mode)) do
		if mapping.lhs == "K" then
			return mapping
		end
	end
end

local first, second = buffer(), buffer()
attach(first)
attach(second)
local custom_buf = buffer()
local custom_calls = 0
local function custom_hover()
	custom_calls = custom_calls + 1
end
vim.keymap.set("n", "K", custom_hover, { buffer = custom_buf, desc = "user hover" })
local plain = buffer()
vim.bo[plain].keywordprg = ":Stage3Keyword"
local keyword_calls, hover_calls, evaluations = {}, {}, {}
vim.api.nvim_create_user_command("Stage3Keyword", function()
	keyword_calls[#keyword_calls + 1] = vim.api.nvim_get_current_buf()
end, { nargs = "*" })
vim.api.nvim_create_user_command("Lspsaga", function(opts)
	assert(opts.args == "hover_doc", "unexpected Lspsaga command")
	hover_calls[#hover_calls + 1] = vim.api.nvim_get_current_buf()
end, { nargs = "*", force = true })

require("lazy.core.loader").load("nvim-dap", { cmd = "test" }, { force = true })
local dap, dapui = require("dap"), require("dapui")
local originals = { eval = dapui.eval, open = dapui.open, close = dapui.close }
local closes = 0
-- UI and adapter transport are boundaries; keymaps, events, and session listeners are real.
dapui.eval = function()
	evaluations[#evaluations + 1] = { buf = vim.api.nvim_get_current_buf(), mode = vim.fn.mode() }
end
dapui.open = function() end
dapui.close = function()
	closes = closes + 1
end
local before = { n = global_map("n"), x = global_map("x"), s = global_map("s") }
local session_id = 0
local function start(buf)
	vim.api.nvim_set_current_buf(buf)
	session_id = session_id + 1
	local session = { id = session_id, parent = {}, config = { name = "stage3" } }
	dap.set_session(session)
	dap.listeners.after.event_initialized.dapui_config(session)
end
local function stop()
	dap.set_session(nil)
	assert(
		vim.wait(1000, function()
			return not _G._debugging
		end),
		"session teardown did not reset debugging"
	)
end
local function evaluate(buf, visual)
	vim.api.nvim_set_current_buf(buf)
	local count = #evaluations
	keys(visual and "viwK<Esc>" or "K")
	assert(#evaluations == count + 1, "K did not evaluate in buffer " .. buf)
	assert(evaluations[#evaluations].buf == buf, "evaluation used the wrong buffer")
	if visual then
		assert(evaluations[#evaluations].mode == "v", "visual selection was lost")
	end
end
local function hover(buf)
	vim.api.nvim_set_current_buf(buf)
	local count = #hover_calls
	keys("K")
	assert(#hover_calls == count + 1 and hover_calls[#hover_calls] == buf, "K did not restore this buffer's hover")
end

start(first)
test("debug K evaluates in the first existing LSP buffer", function()
	evaluate(first)
end)
test("debug K evaluates in every other existing LSP buffer", function()
	evaluate(second)
end)
local fresh = buffer()
attach(fresh)
test("LspAttach during debugging installs a lasting buffer hover dispatcher", function()
	assert(map(fresh).buffer == 1, "new LSP buffer has no buffer-local K")
	evaluate(fresh)
end)
local native = buffer()
vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = native })
attach(native)
test("Neovim's default buffer hover is replaced by the LSP dispatcher", function()
	evaluate(native)
end)
test("non-LSP and visual K evaluate during debugging", function()
	evaluate(plain)
	evaluate(second, true)
end)
test("custom buffer K keeps precedence, including another LspAttach", function()
	attach(custom_buf)
	vim.api.nvim_set_current_buf(custom_buf)
	keys("K")
	assert(custom_calls == 1, "LspAttach replaced custom K")
	assert(map(custom_buf).callback == custom_hover, "custom callback was overwritten")
end)
test("repeated initialization does not overwrite a mid-session user mapping", function()
	vim.keymap.set("n", "K", custom_hover, { buffer = second })
	dap.listeners.after.event_initialized.dapui_config(dap.session())
	vim.api.nvim_set_current_buf(second)
	keys("K")
	assert(map(second).callback == custom_hover, "initialization replaced user's K")
end)
stop()
test("teardown restores old and newly attached LSP hover", function()
	hover(first)
	hover(fresh)
	hover(native)
end)
test("idle reattachment leaves a buffer's custom K unchanged", function()
	attach(custom_buf)
	assert(map(custom_buf).callback == custom_hover, "idle reattachment erased custom K")
end)
test("non-LSP fallback is native K, not the first LSP buffer's hover", function()
	vim.api.nvim_set_current_buf(plain)
	keys("K")
	assert(keyword_calls[#keyword_calls] == plain, "native keywordprg fallback was lost")
end)
test("teardown restores global normal, visual, and select mapping options and behavior", function()
	for _, mode in ipairs({ "n", "x", "s" }) do
		local current, original = global_map(mode), vim.deepcopy(before[mode])
		-- A restored v mapping may be represented as separate x and s entries.
		if current and original then
			current.mode, current.mode_bits = nil, nil
			original.mode, original.mode_bits = nil, nil
		end
		assert(vim.deep_equal(current, original), mode .. " global K was not restored")
	end
	assert(map(second).callback == custom_hover, "teardown erased a user mapping")
	assert(closes == 1, "DAP UI teardown did not run exactly once")
	vim.api.nvim_set_current_buf(plain)
	vim.api.nvim_win_set_cursor(0, { 2, 0 })
	keys("VK<Esc>")
	assert(vim.api.nvim_buf_get_lines(plain, 0, 1, false)[1] == "second", "visual K did not restore line movement")
end)
test("global custom fallback is saved without leaking buffer-local fallback", function()
	local calls = 0
	local function global_custom()
		calls = calls + 1
	end
	vim.keymap.set("n", "K", global_custom, { expr = false, nowait = true, desc = "global user K" })
	local saved = global_map("n")
	start(first)
	evaluate(plain)
	stop()
	assert(vim.deep_equal(global_map("n"), saved), "global custom mapping was not restored")
	vim.api.nvim_set_current_buf(plain)
	keys("K")
	assert(calls == 1, "restored global callback was not invoked")
	vim.keymap.del("n", "K")
end)
test("teardown leaves global mappings replaced by the user during a session", function()
	start(first)
	vim.keymap.set("n", "K", custom_hover, { desc = "new global user K" })
	stop()
	assert(global_map("n").callback == custom_hover, "teardown overwrote a newer global mapping")
	vim.keymap.del("n", "K")
end)
test("visual and select restoration do not overwrite each other's user mappings", function()
	vim.keymap.set("s", "K", custom_hover, { desc = "select user K" })
	start(first)
	vim.keymap.set("x", "K", custom_hover, { desc = "new visual user K" })
	stop()
	assert(global_map("x").desc == "new visual user K", "select restoration overwrote visual user K")
	assert(global_map("s").desc == "select user K", "select user K was not restored")
	vim.keymap.del("x", "K")
	vim.keymap.del("s", "K")
end)
test("deleted LSP buffers do not obstruct session teardown", function()
	local transient = buffer()
	attach(transient)
	start(transient)
	evaluate(transient)
	vim.api.nvim_set_current_buf(first)
	vim.api.nvim_buf_delete(transient, { force = true })
	stop()
	hover(first)
end)
test("rapid session replacement does not tear down an active session", function()
	start(first)
	dap.set_session(nil)
	start(first)
	vim.wait(20, function()
		return false
	end)
	assert(_G._debugging, "scheduled old-session teardown cleared active debugging")
	evaluate(first)
	stop()
end)

test("real dapui evaluation receives normal and visual expressions from different buffers", function()
	dapui.eval = originals.eval
	start(first)
	local session = dap.session()
	session.seq = 0
	session.current_frame = { id = 1 }
	local requests = {}
	session.request = function(_, command, args, callback)
		assert(command == "evaluate", "unexpected adapter request: " .. command)
		requests[#requests + 1] = args
		vim.schedule(function()
			callback(nil, { result = "42", type = "int", variablesReference = 0 })
		end)
	end
	keys("K")
	assert(
		vim.wait(1000, function()
			return #requests > 0
		end),
		"real dapui did not request normal evaluation"
	)
	assert(requests[#requests].expression == "expression", vim.inspect(requests))
	local count = #requests
	vim.api.nvim_set_current_buf(fresh)
	vim.api.nvim_buf_set_lines(fresh, 0, -1, false, { "visual_expression" })
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	keys("viwK<Esc>")
	assert(
		vim.wait(1000, function()
			return #requests > count and requests[#requests].expression == "visual_expression"
		end),
		"real dapui did not receive the visual selection in the second buffer"
	)
	local rendered = false
	assert(
		vim.wait(1000, function()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_config(win).relative ~= "" then
					local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
					if table.concat(lines, "\n"):find("visual_expression int = 42", 1, true) then
						rendered = true
					end
				end
			end
			return rendered
		end),
		"real dapui did not render the adapter response"
	)
	stop()
end)

for key, value in pairs(originals) do
	dapui[key] = value
end
if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("runtime_stage3_dap_keys_spec: %d tests passed", tests_run))
vim.cmd.qa({ bang = true })
