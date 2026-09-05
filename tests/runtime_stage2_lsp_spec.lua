local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/lazy/nvim-lspconfig")
vim.g.mapleader = ","
vim.cmd("runtime plugin/lspconfig.lua")
require("core.event")
require("modules.configs.completion.servers.clangd")({ capabilities = vim.lsp.protocol.make_client_capabilities() })
local config = vim.lsp.config.clangd
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
local dir = vim.env.NVIM_STAGE2_ARTIFACTS and (vim.env.NVIM_STAGE2_ARTIFACTS .. "/lsp%fixtures")
	or (vim.fn.tempname() .. "%fixtures")
vim.fn.mkdir(dir, "p")
local sources = { dir .. "/stage2.c", dir .. "/stage2.cpp" }
local header = dir .. "/stage2.h"
vim.fn.writefile({ "int stage2(void);" }, header)
for _, source in ipairs(sources) do
	vim.fn.writefile({ '#include "stage2.h"', "int stage2(void) { return 1; }" }, source)
end
local function open(source, ft)
	vim.cmd.edit({ args = { source }, magic = { file = false } })
	vim.bo.filetype = ft
	return vim.api.nvim_get_current_buf()
end
local function start(buf, name, project)
	local opts = vim.tbl_deep_extend("force", {}, config, { name = name, root_dir = project or dir })
	local id = assert(vim.lsp.start(opts, { bufnr = buf }))
	assert(
		vim.wait(10000, function()
			local client = vim.lsp.get_client_by_id(id)
			return client and client.initialized and vim.lsp.buf_is_attached(buf, id)
		end, 20),
		"clangd did not initialize"
	)
	return id
end

test("configured clangd argv explicitly enables placeholders and is accepted", function()
	local command = vim.list_extend(vim.deepcopy(config.cmd), { "--check=" .. sources[1] })
	local result = vim.system(command, { text = true }):wait(15000)
	if vim.env.NVIM_STAGE2_ARTIFACTS then
		vim.fn.writefile(
			{ vim.json.encode({ command = command, result = result }) },
			vim.env.NVIM_STAGE2_ARTIFACTS .. "/clangd-check.json"
		)
	end
	assert(result.code == 0, result.stderr)
	assert(not result.stderr:find("Value specified by --function-arg-placeholders is invalid", 1, true), result.stderr)
	assert(vim.tbl_contains(config.cmd, "--function-arg-placeholders=1"), "placeholder enable intent is implicit")
	assert(vim.tbl_contains(config.cmd, "--header-insertion-decorators"), "adjacent argv was lost")
end)

local buf = open(sources[1], "c")
local client_id = start(buf, "stage2_current")
for i, ft in ipairs({ "c", "cpp" }) do
	test(ft .. " FileType mapping switches source/header through the attached clangd command", function()
		local source_buf = open(sources[i], ft)
		vim.lsp.buf_attach_client(source_buf, client_id)
		assert(
			vim.wait(2000, function()
				return vim.fn.exists(":LspClangdSwitchSourceHeader") == 2
			end),
			"clangd command missing"
		)
		keys(",h")
		assert(
			vim.wait(5000, function()
				return vim.api.nvim_buf_get_name(0) == header
			end),
			"source/header mapping did not open the corresponding header"
		)
	end)
end

vim.api.nvim_set_current_buf(buf)
test("LSP info mapping opens the native health report", function()
	assert(vim.fn.exists(":LspInfo") == 0 and vim.fn.exists(":lsp") == 2, "expected native command API")
	keys(",li")
	assert(
		vim.wait(5000, function()
			return vim.bo.filetype == "checkhealth"
		end),
		"LSP info mapping did not open checkhealth"
	)
	assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("vim.lsp", 1, true), "wrong report")
end)
vim.api.nvim_set_current_buf(buf)
local original_mapping = vim.fn.maparg(",lr", "n", false, true)
local active = { { buf = buf, id = client_id, name = "stage2_current", root_dir = dir } }
for _, entry in ipairs({
	{ project = "other", name = "stage2_other" },
	{ project = "same_name", name = "stage2_current" },
	{ project = "late", name = 'stage2_late%#|quoted"' },
}) do
	local project = dir .. "/" .. entry.project
	vim.fn.mkdir(project, "p")
	local source = project .. "/main.c"
	vim.fn.writefile({ "int main(void) { return 0; }" }, source)
	local project_buf = vim.fn.bufadd(source)
	vim.fn.bufload(project_buf)
	vim.bo[project_buf].filetype = "c"
	active[#active + 1] = {
		buf = project_buf,
		id = start(project_buf, entry.name, project),
		name = entry.name,
		root_dir = project,
	}
end

local function restart_commands()
	local commands = {}
	local nvim_cmd = vim.api.nvim_cmd
	-- Observe command dispatch while still executing the real native/legacy command.
	vim.api.nvim_cmd = function(command, opts)
		if command.cmd == "lsp" or command.cmd == "LspRestart" then
			commands[#commands + 1] = vim.deepcopy(command)
		end
		return nvim_cmd(command, opts)
	end
	vim.v.errmsg = ""
	local ok, err = pcall(keys, ",lr")
	vim.api.nvim_cmd = nvim_cmd
	assert(ok, err)
	assert(vim.v.errmsg == "", vim.v.errmsg)
	return commands
end

local commands
test("native restart covers all projects and clients added after mapping installation", function()
	assert(vim.deep_equal(original_mapping, vim.fn.maparg(",lr", "n", false, true)), "mapping was reinstalled")
	assert(#vim.lsp.get_clients() == #active, "expected four distinct clients")
	commands = restart_commands()
	for _, entry in ipairs(active) do
		assert(
			vim.wait(10000, function()
				local clients = vim.lsp.get_clients({ bufnr = entry.buf, name = entry.name })
				return #clients == 1
					and clients[1].id ~= entry.id
					and clients[1].initialized
					and clients[1].config.root_dir == entry.root_dir
			end, 20),
			"client was not restarted: " .. entry.name .. " in " .. entry.root_dir
		)
	end
	assert(#vim.lsp.get_clients() == #active, "restart changed the number of clients")
end)

test("native restart sends deduplicated literal names in one structured command", function()
	assert(commands and #commands == 1, "expected one structured restart command")
	assert(
		vim.deep_equal(commands[1].args, { "restart", "stage2_current", 'stage2_late%#|quoted"', "stage2_other" }),
		vim.inspect(commands[1])
	)
	assert(commands[1].magic.file == false and commands[1].magic.bar == false, "names are not literal")
end)

for _, client in ipairs(vim.lsp.get_clients()) do
	client:stop()
end
assert(
	vim.wait(2000, function()
		return #vim.lsp.get_clients() == 0
	end),
	"test clients did not stop"
)

test("restart with no active clients is a no-op", function()
	assert(#restart_commands() == 0, "empty client list dispatched a restart command")
	assert(#vim.lsp.get_clients() == 0, "restart unexpectedly started a client")
end)

test("legacy restart command executes when the native command is unavailable", function()
	local exists = vim.fn.exists
	vim.fn.exists = function(name)
		return name == ":lsp" and 0 or exists(name)
	end
	local ok, err = xpcall(function()
		vim.g.lspconfig = nil
		vim.cmd("runtime plugin/lspconfig.lua")
		assert(exists(":LspRestart") == 2, "upstream legacy command was not registered")
		require("keymap.lsp").lsp(buf)
		local legacy = restart_commands()
		assert(#legacy == 1 and legacy[1].cmd == "LspRestart", "legacy fallback was not dispatched")
	end, debug.traceback)
	vim.fn.exists = exists
	require("keymap.lsp").lsp(buf)
	assert(ok, err)
end)
vim.fn.delete(dir, "rf")
if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end
print(string.format("runtime_stage2_lsp_spec: %d tests passed", tests_run))
