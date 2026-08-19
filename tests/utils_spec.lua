local root = vim.fn.getcwd()
package.path = table.concat({
	root .. "/lua/?.lua",
	root .. "/lua/?/init.lua",
	package.path,
}, ";")

local utils = require("modules.utils")
local failures = {}
local tests_run = 0

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

local function reset_module(name)
	package.loaded[name] = nil
	package.preload[name] = nil
end

local function assert_contains(value, expected)
	assert(type(value) == "string", "expected a string error")
	assert(value:find(expected, 1, true), string.format("expected %q to contain %q", value, expected))
end

test("extend_config ignores an absent optional module", function()
	local module = "audit.absent.settings"
	reset_module(module)
	local defaults = { enabled = true }
	assert(utils.extend_config(defaults, module) == defaults, "expected an absent override to preserve defaults")
end)

test("extend_config loads an override from the runtime path", function()
	local module = "audit.runtime_path.settings"
	local runtime = vim.fn.tempname()
	vim.fn.mkdir(runtime .. "/lua/audit/runtime_path", "p")
	vim.fn.writefile({ "return { enabled = false }" }, runtime .. "/lua/audit/runtime_path/settings.lua")
	vim.opt.runtimepath:prepend(runtime)
	reset_module(module)

	local ok, config = pcall(utils.extend_config, { enabled = true }, module)
	reset_module(module)
	vim.opt.runtimepath:remove(runtime)
	vim.fn.delete(runtime, "rf")
	assert(ok, config)
	assert(config.enabled == false, "expected the runtime-path override to load")
end)

test("extend_config propagates a missing transitive dependency", function()
	local module = "audit.transitive.settings"
	reset_module(module)
	package.preload[module] = function()
		require("audit.missing.transitive")
	end

	local ok, err = pcall(utils.extend_config, {}, module)
	reset_module(module)
	assert(not ok, "expected the transitive require error to propagate")
	assert_contains(err, "audit.missing.transitive")
end)

test("extend_config propagates an override runtime error", function()
	local module = "audit.runtime.settings"
	reset_module(module)
	package.preload[module] = function()
		error("settings override exploded")
	end

	local ok, err = pcall(utils.extend_config, {}, module)
	reset_module(module)
	assert(not ok, "expected the override runtime error to propagate")
	assert_contains(err, "settings override exploded")
end)

test("extend_config propagates a target-like runtime error", function()
	local module = "audit.runtime.target_like"
	reset_module(module)
	package.preload[module] = function()
		error("module '" .. module .. "' not found:\n\toverride exploded", 0)
	end

	local ok, err = pcall(utils.extend_config, {}, module)
	reset_module(module)
	assert(not ok, "expected the target-like runtime error to propagate")
	assert_contains(err, "override exploded")
end)

test("load_plugin falls back only when its override is absent", function()
	local module = "user.configs.utils_spec"
	reset_module(module)
	local opts = { enabled = true }
	local received

	utils.load_plugin("audit-plugin", opts, false, function(value)
		received = value
	end)

	assert(received == opts, "expected default setup when no override exists")
end)

test("load_plugin propagates a missing transitive dependency", function()
	local module = "user.configs.utils_spec"
	reset_module(module)
	package.preload[module] = function()
		require("audit.missing.plugin_dependency")
	end
	local setup_calls = 0

	local ok, err = pcall(function()
		utils.load_plugin("audit-plugin", {}, false, function()
			setup_calls = setup_calls + 1
		end)
	end)
	reset_module(module)
	assert(not ok, "expected the transitive require error to propagate")
	assert(setup_calls == 0, "default setup must not run after an override load error")
	assert_contains(err, "audit.missing.plugin_dependency")
end)

test("load_plugin propagates a target-like runtime error", function()
	local module = "user.configs.utils_spec"
	reset_module(module)
	package.preload[module] = function()
		error("module '" .. module .. "' not found:\n\toverride exploded", 0)
	end
	local setup_calls = 0

	local ok, err = pcall(function()
		utils.load_plugin("audit-plugin", {}, false, function()
			setup_calls = setup_calls + 1
		end)
	end)
	reset_module(module)
	assert(not ok, "expected the target-like runtime error to propagate")
	assert(setup_calls == 0, "default setup must not run after an override load error")
	assert_contains(err, "override exploded")
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end

print(string.format("utils_spec: %d tests passed", tests_run))
