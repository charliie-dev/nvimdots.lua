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

require("lazy.core.loader").load("nvim-dap", { cmd = "test" }, { force = true })
local dap = require("dap")
local custom = {
	type = "go",
	name = "Debug (Arguments & Build Flags)",
	request = "launch",
	program = "custom.go",
	buildFlags = function()
		return "-tags=custom"
	end,
}
dap.configurations.go = { custom }
require("lazy.core.loader").load("nvim-dap-go", { cmd = "test" }, { force = true })
local preset = assert(dap.configurations.go[4], "dap-go did not register the build flags preset")
assert(preset.name == custom.name, "upstream preset order changed")
local original_input = vim.ui.input
local prompts = {}
vim.ui.input = function(opts, callback)
	prompts[#prompts + 1] = opts.prompt
	vim.schedule(function()
		callback(opts.prompt == "Build Flags: " and "-tags=integration -race" or "one two")
	end)
end

test("generated buildFlags callback resumes with zero arguments", function()
	local flags
	local consumer = coroutine.create(function()
		flags = coroutine.yield()
	end)
	assert(coroutine.resume(consumer))
	local generated = preset.buildFlags()
	assert(type(generated) == "thread", "preset did not generate a coroutine")
	local ok, err = coroutine.resume(generated, consumer)
	assert(ok, err)
	assert(
		vim.wait(1000, function()
			return flags ~= nil
		end),
		"buildFlags coroutine never resumed its consumer"
	)
	assert(vim.deep_equal(flags, { "-tags=integration", "-race" }), vim.inspect(flags))
end)

test("real DAP configuration expansion resolves arguments and build flags", function()
	local expanded
	local co = coroutine.create(function()
		expanded = dap.listeners.on_config["dap.expand_variable"](preset)
	end)
	assert(coroutine.resume(co))
	assert(
		vim.wait(1000, function()
			return expanded ~= nil
		end),
		"DAP expansion stalled waiting for the preset coroutine"
	)
	assert(vim.deep_equal(expanded.args, { "one", "two" }), vim.inspect(expanded.args))
	assert(vim.deep_equal(expanded.buildFlags, { "-tags=integration", "-race" }), vim.inspect(expanded.buildFlags))
	assert(vim.tbl_contains(prompts, "Build Flags: "), "build flags prompt was not shown")
end)

test("only the generated broken preset is patched and setup stays idempotent", function()
	assert(dap.configurations.go[1] == custom, "user configuration was replaced")
	assert(custom.buildFlags() == "-tags=custom", "matching user preset was modified")
	assert(#dap.configurations.go == 8, "upstream configurations were removed or duplicated")
	local expected =
		{ "Debug", "Debug (Arguments)", custom.name, "Debug Package", "Attach", "Debug test", "Debug test (go.mod)" }
	for i, name in ipairs(expected) do
		local config = dap.configurations.go[i + 1]
		assert(config.name == name, "upstream preset changed")
		if name ~= custom.name then
			assert(config.buildFlags == "", name .. " buildFlags changed")
		end
	end
	local before = vim.deepcopy(dap.configurations.go)
	require("modules.configs.tool.dap.dap-go")()
	assert(vim.deep_equal(before, dap.configurations.go), "repeated local setup changed presets")
end)

test("Go adapter retains trusted executable and loopback checks", function()
	local actual
	dap.adapters.go(function(adapter)
		actual = adapter
	end, preset)
	assert(actual.executable.command == vim.uv.fs_realpath(vim.fn.exepath("dlv")), "adapter bypassed trusted dlv")
	assert(vim.deep_equal(actual.executable.args, { "dap", "-l", "127.0.0.1:${port}" }), "adapter is not loopback-only")
	assert(not pcall(dap.adapters.go, function() end, { host = "remote" }), "host override was accepted")
	assert(not pcall(dap.adapters.go, function() end, { port = "1234" }), "port override was accepted")
end)

vim.ui.input = original_input
if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("runtime_stage3_dap_go_spec: %d tests passed", tests_run))
vim.cmd.qa({ bang = true })
