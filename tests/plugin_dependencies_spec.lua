local modules = { "completion", "editor", "lang", "tool", "ui" }
local failures, specs, lazy_plugins, tests_run = {}, nil, nil, 0

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

local function normalize_realpath(path)
	return vim.fs.normalize(assert(vim.uv.fs_realpath(path), "unresolved path: " .. path)):gsub("\\", "/")
end

local config_root, runtime_root
local function source_identity(callback)
	if not config_root then
		config_root = normalize_realpath(require("core.global").vim_path)
		runtime_root = normalize_realpath(vim.env.VIMRUNTIME)
	end
	local source = assert(debug.getinfo(callback, "S")).source:gsub("^@", ""):gsub("\\", "/")
	source = vim.uv.fs_realpath(source) and normalize_realpath(source) or source
	if source:sub(1, #config_root + 1) == config_root .. "/" then
		source = "repo/" .. source:sub(#config_root + 2)
	elseif source:sub(1, #runtime_root + 1) == runtime_root .. "/" then
		source = "runtime/" .. source:sub(#runtime_root + 2)
	elseif source:sub(1, 4) == "vim/" then
		source = "runtime/" .. source
	end
	return "function(" .. source .. ")"
end
local function canonical(value)
	if type(value) == "function" then
		return source_identity(value)
	elseif type(value) == "string" then
		return string.format("%q", value)
	elseif type(value) ~= "table" then
		return tostring(value)
	end
	local entries = {}
	for key, item in pairs(value) do
		entries[#entries + 1] = canonical(key) .. "=" .. canonical(item)
	end
	table.sort(entries)
	return "{" .. table.concat(entries, ",") .. "}"
end
local function dependency_spec(dependency)
	return type(dependency) == "table" and dependency or { dependency }
end
local function dependency_names(spec)
	local names = {}
	for _, dependency in ipairs(spec.dependencies or {}) do
		names[#names + 1] = dependency_spec(dependency)[1]
	end
	return names
end

local function manifest_row(path, spec)
	local reviewed = {}
	for key, value in pairs(spec) do
		if key ~= "dependencies" then
			reviewed[key] = value
		end
	end
	if path == "ray-x/go.nvim>ray-x/guihua.lua" then
		reviewed.build = "<platform-build>"
	end
	local dependencies = dependency_names(spec)
	table.sort(dependencies)
	return string.format("%s|dependencies={%s}|spec=%s", path, table.concat(dependencies, ","), canonical(reviewed))
end

local function collect_dependencies(rows, parent, spec)
	if spec.dependencies == nil then
		return
	end
	assert(vim.islist(spec.dependencies), parent .. " dependencies must be a list")
	for _, item in ipairs(spec.dependencies) do
		local child = dependency_spec(item)
		local path = parent .. ">" .. child[1]
		rows[#rows + 1] = manifest_row(path, child)
		collect_dependencies(rows, path, child)
	end
end

local function collect_manifest()
	local collected, top_level, nested = {}, {}, {}
	for _, module in ipairs(modules) do
		local module_specs = require("modules.plugins." .. module)
		local names = vim.tbl_keys(module_specs)
		table.sort(names)
		for _, name in ipairs(names) do
			local spec = module_specs[name]
			collected[name] = spec
			top_level[#top_level + 1] = manifest_row(name, spec)
			collect_dependencies(nested, name, spec)
		end
	end
	return collected, top_level, nested, require("lazy.core.config").plugins
end

local function assert_manifest(label, rows, count, hash)
	local actual = table.concat(rows, "\n")
	assert(#rows == count, string.format("%s count: expected %d, got %d\n%s", label, count, #rows, actual))
	local actual_hash = vim.fn.sha256(actual)
	assert(actual_hash == hash, string.format("%s SHA-256: expected %s, got %s\n%s", label, hash, actual_hash, actual))
end

test("complete raw plugin manifest", function()
	local top_level, nested
	specs, top_level, nested, lazy_plugins = collect_manifest()
	assert_manifest(
		"top-level manifest",
		top_level,
		58,
		"ee918d56015c30b014a476db585fc433c9fde21dd511a21a97fc27303205ba31"
	)
	assert_manifest("nested manifest", nested, 33, "5ed59063d68276fb264b8d34a01572bb7cd866d77df40e1283177f2d92844530")
end)

local function dependency(spec, name)
	for _, item in ipairs(spec.dependencies or {}) do
		if dependency_spec(item)[1] == name then
			return dependency_spec(item)
		end
	end
	error("missing dependency: " .. name)
end

local function assert_dependencies(spec, expected)
	local actual = dependency_names(spec)
	assert(vim.deep_equal(actual, expected), "dependencies: " .. table.concat(actual, ","))
end

test("approved dependency relationships are explicit", function()
	assert(specs, "manifest collection failed")
	assert_dependencies(specs["sindrets/diffview.nvim"], { "nvim-tree/nvim-web-devicons" })
	assert_dependencies(specs["bezhermoso/tree-sitter-ghostty"], {})
	assert_dependencies(specs["danymat/neogen"], {})
	assert_dependencies(specs["jmbuhr/otter.nvim"], { "nvim-treesitter/nvim-treesitter" })
	assert_dependencies(specs["charliie-dev/hmts.nvim"], { "nvim-treesitter/nvim-treesitter" })
	assert_dependencies(specs["nvim-treesitter/nvim-treesitter"], { "Hdoc1509/gh-actions.nvim" })
	local moved = {
		["nvim-mini/mini.ai"] = { config = require("modules.configs.editor.ai_textobj"), version = "*" },
		["nvim-treesitter/nvim-treesitter-textobjects"] = {
			config = require("modules.configs.editor.ts-textobjects"),
			branch = "main",
		},
		["windwp/nvim-ts-autotag"] = { config = require("modules.configs.editor.ts-autotag") },
		["HiPhish/rainbow-delimiters.nvim"] = { config = require("modules.configs.editor.rainbow_delims") },
		["nvim-treesitter/nvim-treesitter-context"] = { config = require("modules.configs.editor.ts-context") },
	}
	for name, contract in pairs(moved) do
		assert(specs[name].lazy == false, name .. " move")
		for field, expected in pairs(contract) do
			assert(specs[name][field] == expected, name .. " " .. field)
		end
	end
	local bqf = specs["kevinhwang91/nvim-bqf"]
	assert_dependencies(bqf, { "junegunn/fzf" })
	assert(dependency(bqf, "junegunn/fzf").build == ":call fzf#install()", "FZF build")
	local quicker = specs["stevearc/quicker.nvim"]
	assert(
		quicker.lazy == true and quicker.ft == "qf" and type(quicker.opts) == "table" and next(quicker.opts) == nil,
		"Quicker contract"
	)
	local guihua = dependency(specs["ray-x/go.nvim"], "ray-x/guihua.lua")
	local expected_build
	if require("core.global").is_windows then
		expected_build = false
	else
		expected_build = "cd lua/fzy && make"
	end
	assert(guihua.build == expected_build, "Guihua platform build: " .. vim.inspect(guihua.build))
	local dap = specs["mfussenegger/nvim-dap"]
	assert_dependencies(dap, { "rcarriga/nvim-dap-ui" })
	assert_dependencies(dependency(dap, "rcarriga/nvim-dap-ui"), { "nvim-neotest/nvim-nio" })
end)

test("gh-actions parser registration runs exactly once", function()
	assert(specs, "manifest collection failed")
	local config = dependency(specs["nvim-treesitter/nvim-treesitter"], "Hdoc1509/gh-actions.nvim").config
	local name, previous, calls = "gh-actions.tree-sitter", package.loaded["gh-actions.tree-sitter"], 0
	package.loaded[name] = {
		setup = function()
			calls = calls + 1
		end,
	}
	local ok, err = xpcall(config, debug.traceback)
	package.loaded[name] = previous
	assert(ok, err)
	assert(calls == 1, "setup calls: " .. calls)
end)

test("startup recorded no errors", function()
	vim.wait(200)
	local messages = vim.api.nvim_exec2("messages", { output = true }).output
	local patterns = { "Error detected while processing", "Failed to source", "Failed to run", "Failed to load" }
	for _, pattern in ipairs(patterns) do
		assert(not messages:find(pattern, 1, true), pattern .. " in :messages:\n" .. messages)
	end
	for _, notification in ipairs(require("snacks.notifier").get_history()) do
		local level = tostring(notification.level):lower()
		local is_error = notification.level == vim.log.levels.ERROR or level == "error"
		assert(not is_error, "ERROR notification: " .. vim.inspect(notification))
	end
end)

test("startup-loaded set is preserved", function()
	assert(lazy_plugins, "manifest collection failed")
	local loaded = {}
	for name, plugin in pairs(lazy_plugins) do
		if plugin._ and plugin._.loaded then
			loaded[#loaded + 1] = name
		end
	end
	table.sort(loaded)
	local expected =
		"catppuccin,dropbar.nvim,gh-actions.nvim,lazy.nvim,mini.ai,nvim-treesitter,nvim-treesitter-context,nvim-treesitter-textobjects,nvim-ts-autotag,nvim-web-devicons,oil.nvim,rainbow-delimiters.nvim,snacks.nvim,sops.nvim"
	assert(table.concat(loaded, ",") == expected, "loaded: " .. table.concat(loaded, ","))
end)

test("complete resolved lazy graph is acyclic", function()
	assert(lazy_plugins, "manifest collection failed")
	local state = {}
	local function visit(name, path)
		if state[name] == "visiting" then
			error("dependency cycle: " .. table.concat(path, " -> ") .. " -> " .. name)
		elseif state[name] == "done" then
			return
		end
		state[name] = "visiting"
		local plugin = assert(lazy_plugins[name], "missing resolved dependency: " .. name)
		for _, item in ipairs(plugin.dependencies or {}) do
			visit(type(item) == "table" and item.name or item, vim.list_extend(vim.deepcopy(path), { name }))
		end
		state[name] = "done"
	end
	for name in pairs(lazy_plugins) do
		visit(name, {})
	end
end)

test("codelldb is registered without Mason", function()
	assert(specs["mason-org/mason.nvim"] == nil, "mason.nvim remains in the plugin manifest")
	assert(specs["jay-babu/mason-nvim-dap.nvim"] == nil, "mason-nvim-dap remains in the plugin manifest")
	require("lazy.core.loader").load("nvim-dap", { cmd = "test" }, { force = true })
	local adapter = assert(require("dap").adapters.codelldb, "codelldb adapter was not registered")
	assert(adapter.executable.command == "codelldb", "unexpected codelldb command")
end)

test("codelldb runs attached only on Windows", function()
	local global = require("core.global")
	local register = require("tool.dap.clients.codelldb")
	local original = global.is_windows
	local ok, err = pcall(function()
		for _, is_windows in ipairs({ true, false }) do
			global.is_windows = is_windows
			register()
			local detached = require("dap").adapters.codelldb.executable.detached
			assert(detached == not is_windows, ("is_windows=%s gave detached=%s"):format(is_windows, detached))
		end
	end)
	global.is_windows = original
	register()
	assert(ok, err)
end)

test("custom highlights survive a colorscheme reload", function()
	require("lazy.core.loader").load(
		{ "flash.nvim", "mini.cursorword", "nvim-dap" },
		{ cmd = "test" },
		{ force = true }
	)
	local groups = { "FlashLabel", "DapStopped", "MiniCursorword", "MiniCursorwordCurrent" }
	local function snapshot()
		local hl = {}
		for _, name in ipairs(groups) do
			hl[name] = vim.api.nvim_get_hl(0, { name = name, link = true })
		end
		return hl
	end
	local before = snapshot()
	assert(before.FlashLabel.fg == 0xFFA500 and before.FlashLabel.underline, vim.inspect(before.FlashLabel))
	vim.cmd.colorscheme(vim.g.colors_name)
	local after = snapshot()
	for _, name in ipairs(groups) do
		assert(
			vim.deep_equal(before[name], after[name]),
			("%s: %s -> %s"):format(name, vim.inspect(before[name]), vim.inspect(after[name]))
		)
	end
end)

test("Saga hover links fall back to the configured external browser", function()
	require("lazy.core.loader").load("lspsaga.nvim", { cmd = "test" }, { force = true })
	local hover = require("lspsaga.hover")
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "[docs](https://example.com/a)" })
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_win_set_cursor(0, { 1, 1 })
	vim.treesitter.get_parser(buf, "markdown"):parse(true)
	local fn, executed = { has = vim.fn.has, executable = vim.fn.executable, execute = vim.fn.execute }, nil
	vim.fn.has = function(feature)
		return (feature == "mac" or feature == "win32") and 0 or fn.has(feature)
	end
	vim.fn.executable = function(name)
		return (name == "wslview" or name == "xdg-open") and 0 or fn.executable(name)
	end
	vim.fn.execute = function(cmd)
		executed = cmd
	end
	hover.bufnr = buf
	local ok, err = pcall(hover.open_link, hover)
	hover.bufnr = nil
	vim.fn.has, vim.fn.executable, vim.fn.execute = fn.has, fn.executable, fn.execute
	vim.api.nvim_buf_delete(buf, { force = true })
	assert(ok, err)
	local expected = "silent !" .. require("core.settings").lspsaga_browser .. " https://example.com/a"
	assert(executed == expected, vim.inspect(executed))
end)

test("yamlls maps unclaimed Kubernetes manifests to the kubernetes schema", function()
	local config = require("completion.servers.yamlls")
	local function fake_client(claimed)
		local client = { settings = { yaml = { schemas = {} } }, requests = 0, notified = 0 }
		function client:request(method, params, handler)
			assert(method == "yaml/get/jsonSchema", method)
			assert(type(params) == "string", "schema lookup expects the document URI")
			self.requests = self.requests + 1
			handler(nil, claimed and { { uri = "https://example.com/other.json" } } or {})
			return true
		end
		function client:notify(method, params)
			assert(method == "workspace/didChangeConfiguration", method)
			assert(params.settings == self.settings, "notification did not carry the client settings")
			self.notified = self.notified + 1
		end
		function client:is_stopped()
			return false
		end
		return client
	end
	local buffers = {}
	local function buffer(lines)
		local buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. ".yaml")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		buffers[#buffers + 1] = buf
		return buf
	end
	local manifest = { "apiVersion: apps/v1", "kind: Deployment", "metadata:", "  name: web" }
	local ok, err = pcall(function()
		local client, buf = fake_client(false), buffer(manifest)
		config.on_attach(client, buf)
		local mapped = client.settings.yaml.schemas.kubernetes
		assert(vim.deep_equal(mapped, { vim.uri_from_bufnr(buf) }), vim.inspect(client.settings.yaml.schemas))
		assert(client.notified == 1, "schema change was not sent")
		vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf })
		assert(client.requests == 1 and client.notified == 1, "an already mapped buffer was looked up again")

		local claimed = fake_client(true)
		config.on_attach(claimed, buffer({ "apiVersion: kustomize.config.k8s.io/v1beta1", "kind: Kustomization" }))
		assert(claimed.requests == 1, "claimed manifest was not looked up")
		assert(claimed.settings.yaml.schemas.kubernetes == nil and claimed.notified == 0, "claimed file was remapped")

		local plain, later = fake_client(false), buffer({ "name: ci", "on: push" })
		config.on_attach(plain, later)
		assert(plain.requests == 0, "plain YAML was looked up")
		vim.api.nvim_buf_set_lines(later, 0, -1, false, manifest)
		vim.api.nvim_exec_autocmds("InsertLeave", { buffer = later })
		assert(
			vim.deep_equal(plain.settings.yaml.schemas.kubernetes, { vim.uri_from_bufnr(later) }),
			"edit to a manifest was missed"
		)
	end)
	for _, buf in ipairs(buffers) do
		vim.api.nvim_buf_delete(buf, { force = true })
	end
	assert(ok, err)
end)

test("Helm chart files get helm filetypes only inside a chart", function()
	local dir = vim.fn.tempname()
	for _, sub in ipairs({ "chart/templates/sub", "other/templates" }) do
		vim.fn.mkdir(dir .. "/" .. sub, "p")
	end
	vim.fn.writefile({ "apiVersion: v2", "name: chart" }, dir .. "/chart/Chart.yaml")
	local expected = {
		["chart/templates/deploy.yaml"] = "helm",
		["chart/templates/sub/svc.yml"] = "helm",
		["chart/templates/_helpers.tpl"] = "helm",
		["chart/templates/NOTES.txt"] = "helm",
		["chart/values.yaml"] = "yaml.helm-values",
		["chart/values-prod.yaml"] = "yaml.helm-values",
		["chart/Chart.yaml"] = "yaml",
		["other/templates/x.yaml"] = "yaml",
		["other/values.yaml"] = "yaml",
	}
	local ok, err = pcall(function()
		for name, ft in pairs(expected) do
			vim.cmd.edit(dir .. "/" .. name)
			assert(vim.bo.filetype == ft, ("%s: filetype=%q, expected %q"):format(name, vim.bo.filetype, ft))
			vim.cmd("bwipeout!")
		end
	end)
	vim.fn.delete(dir, "rf")
	assert(ok, err)
end)

test("helm_ls serves Helm charts and yamlls stays off templates", function()
	assert(vim.tbl_contains(require("core.settings").lsp_deps, "helm_ls"), "helm_ls is not in lsp_deps")
	assert(require("core.settings").treesitter_deps.helm, "helm parser is not installed")
	-- Servers are enabled only when their executable exists; Muster reports missing ones.
	local installed = require("completion.lsp-server").is_executable("helm_ls")
	assert(vim.lsp.is_enabled("helm_ls") == installed, "helm_ls enablement does not follow its executable")
	assert(vim.tbl_contains(vim.lsp.config.helm_ls.filetypes, "helm"), "helm_ls does not cover templates")
	assert(not vim.tbl_contains(vim.lsp.config.yamlls.filetypes, "helm"), "yamlls would parse Go templates")
end)

test("local snippet manifest entries point to valid snippet files", function()
	local root = vim.fn.stdpath("config") .. "/snips"
	local manifest = vim.json.decode(table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
	for _, entry in ipairs(manifest.contributes.snippets) do
		local path = vim.fs.normalize(root .. "/" .. entry.path)
		assert(vim.uv.fs_stat(path), "missing snippet file: " .. entry.path)
		local ok, snippets = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
		assert(ok and type(snippets) == "table" and next(snippets), "invalid snippet file: " .. entry.path)
	end
end)

test("VimResized equalizes every tab without leaving the current one", function()
	local base = vim.fn.tempname()
	local dir_a, dir_b = base .. "/a", base .. "/b"
	vim.fn.mkdir(dir_a, "p")
	vim.fn.mkdir(dir_b, "p")
	local start_tab, events = vim.api.nvim_get_current_tabpage(), {}
	local group = vim.api.nvim_create_augroup("VimResizedSpec", { clear = true })
	local ok, err = pcall(function()
		vim.cmd.tabnew()
		vim.cmd.tcd(dir_a)
		local tab_a = vim.api.nvim_get_current_tabpage()
		vim.cmd.tabnew()
		vim.cmd.tcd(dir_b)
		vim.cmd.vsplit()
		vim.cmd("vertical resize 10")
		local wins_b = vim.api.nvim_tabpage_list_wins(0)
		vim.api.nvim_set_current_tabpage(tab_a)
		vim.api.nvim_create_autocmd({ "TabEnter", "DirChanged" }, {
			group = group,
			callback = function(args)
				events[#events + 1] = args.event
			end,
		})
		vim.api.nvim_exec_autocmds("VimResized", {})
		assert(vim.api.nvim_get_current_tabpage() == tab_a, "resize switched the current tab")
		assert(vim.fn.getcwd() == vim.uv.fs_realpath(dir_a), "resize changed the cwd to " .. vim.fn.getcwd())
		assert(#events == 0, "resize fired " .. table.concat(events, ", "))
		local w1, w2 = vim.api.nvim_win_get_width(wins_b[1]), vim.api.nvim_win_get_width(wins_b[2])
		assert(math.abs(w1 - w2) <= 1, ("other tab not equalized: %d vs %d"):format(w1, w2))
	end)
	vim.api.nvim_del_augroup_by_id(group)
	vim.api.nvim_set_current_tabpage(start_tab)
	vim.cmd("silent! tabonly!")
	vim.fn.delete(base, "rf")
	assert(ok, err)
end)

test("BufReadPost handlers act on the event buffer, not the current one", function()
	require("lazy.core.loader").load("nvim-lint", { cmd = "test" }, { force = true })
	local lint = require("lint")
	local try_lint, linted = lint.try_lint, {}
	lint.try_lint = function()
		linted[#linted + 1] = vim.api.nvim_get_current_buf()
	end
	local lines = vim.tbl_map(tostring, vim.fn.range(1, 10))
	local function buffer()
		local buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_name(buf, vim.fn.tempname())
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modified = false
		return buf
	end
	local a, b = buffer(), buffer()
	vim.api.nvim_buf_set_mark(a, '"', 5, 0, {})
	vim.api.nvim_buf_set_mark(b, '"', 8, 0, {})
	local ok, err = pcall(function()
		vim.cmd("silent! only")
		local current = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(current, b)
		vim.api.nvim_win_set_cursor(current, { 1, 0 })
		-- An async loader (e.g. sops.nvim) finishes A while the user is on B.
		vim.api.nvim_exec_autocmds("BufReadPost", { buffer = a, modeline = false })
		assert(vim.api.nvim_win_get_cursor(current)[1] == 1, "B's cursor followed A's last-edit mark")
		assert(vim.deep_equal(linted, { a }), "lint ran for buffer " .. vim.inspect(linted))
		-- A visible in another window jumps there; the current window stays put.
		vim.cmd("vsplit")
		local other = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(other, a)
		vim.api.nvim_win_set_cursor(other, { 1, 0 })
		vim.api.nvim_set_current_win(current)
		vim.api.nvim_exec_autocmds("BufReadPost", { buffer = a, modeline = false })
		assert(vim.api.nvim_win_get_cursor(other)[1] == 5, "A's window did not jump to the last edit")
		assert(vim.api.nvim_win_get_cursor(current)[1] == 1, "current window moved")
		-- Ordinary reads into the current window still jump.
		vim.api.nvim_set_current_win(other)
		vim.api.nvim_win_set_cursor(other, { 1, 0 })
		vim.api.nvim_exec_autocmds("BufReadPost", { buffer = a, modeline = false })
		assert(vim.api.nvim_win_get_cursor(other)[1] == 5, "current window did not jump to the last edit")
	end)
	lint.try_lint = try_lint
	vim.cmd("silent! only")
	vim.api.nvim_buf_delete(a, { force = true })
	vim.api.nvim_buf_delete(b, { force = true })
	assert(ok, err)
end)

test("InsertLeave runs only stdin linters; reads and writes run every linter", function()
	require("lazy.core.loader").load("nvim-lint", { cmd = "test" }, { force = true })
	local lint = require("lint")
	local run, ran = lint.lint, {}
	lint.lint = function(linter)
		ran[#ran + 1] = linter.name
	end
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. "/Dockerfile")
	local ok, err = pcall(function()
		vim.api.nvim_set_current_buf(buf)
		vim.bo[buf].filetype = "dockerfile"
		local expected = {
			InsertLeave = { "hadolint" },
			BufWritePost = { "droast", "hadolint" },
			BufReadPost = { "droast", "hadolint" },
		}
		for event, names in pairs(expected) do
			ran = {}
			vim.api.nvim_exec_autocmds(event, { buffer = buf, modeline = false })
			table.sort(ran)
			assert(vim.deep_equal(ran, names), event .. " ran " .. vim.inspect(ran))
		end
	end)
	lint.lint = run
	vim.api.nvim_buf_delete(buf, { force = true })
	assert(ok, err)
end)

test("terraform_validate leaves other files' diagnostics out of the buffer", function()
	require("lazy.core.loader").load("nvim-lint", { cmd = "test" }, { force = true })
	local linter = require("lint").linters.terraform_validate
	linter = type(linter) == "function" and linter() or linter
	-- Diagnostics taken from real `terraform validate -json` runs (Terraform 1.16.5): an error in
	-- other.tf, an error and a warning in main.tf, and a module-wide error without a range.
	local fixture = vim.fn.stdpath("config") .. "/tests/fixtures/terraform_validate.json"
	local output = table.concat(vim.fn.readfile(fixture), "\n")
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. "/main.tf")
	local ok, err = pcall(function()
		local severity = vim.diagnostic.severity
		local diagnostics = linter.parser(output, buf)
		local got = vim.tbl_map(function(d)
			assert(d.source == "terraform validate", "unexpected source " .. tostring(d.source))
			local summary = vim.split(d.message, " - ", { plain = true })[1]
			return { d.lnum, d.col, d.end_lnum, d.end_col, d.severity, summary }
		end, diagnostics)
		local expected = {
			{ 1, 10, 1, 21, severity.ERROR, "Reference to undeclared input variable" },
			{ 0, 0, nil, nil, severity.ERROR, "Missing required provider" },
			{ 1, 12, 1, 20, severity.WARN, "Version constraints inside provider configuration blocks are deprecated" },
		}
		assert(vim.deep_equal(got, expected), vim.inspect(got))
		-- Malformed output and unknown severities do not raise and stay visible as warnings.
		assert(vim.deep_equal(linter.parser('{"diagnostics": null}', buf), {}), "null diagnostics raised")
		local unknown = linter.parser('{"diagnostics": [{"severity": "fatal", "summary": "x"}]}', buf)
		assert(#unknown == 1 and unknown[1].severity == severity.WARN, vim.inspect(unknown))
	end)
	vim.api.nvim_buf_delete(buf, { force = true })
	assert(ok, err)
end)

test("otter picks up embedded languages added after the buffer opened", function()
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. ".md")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# notes" })
	local ok, err = pcall(function()
		vim.api.nvim_set_current_buf(buf)
		vim.bo[buf].filetype = "markdown"
		local function languages()
			local raft = require("otter.keeper").rafts[buf]
			local langs = raft and vim.deepcopy(raft.languages) or {}
			table.sort(langs)
			return langs
		end
		local function edit(lines)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
			vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf, modeline = false })
		end
		assert(vim.deep_equal(languages(), {}), "otter activated without code: " .. vim.inspect(languages()))
		edit({ "```lua", "local x = 1", "```" })
		assert(vim.deep_equal(languages(), { "lua" }), "first language missed: " .. vim.inspect(languages()))
		edit({ "```python", "y = 2", "```" })
		assert(vim.deep_equal(languages(), { "lua", "python" }), "second language missed: " .. vim.inspect(languages()))
		local lua_otter = require("otter.keeper").rafts[buf].buffers.lua
		-- Remove the lua fence (lines 2-4): its language and otter buffer go away.
		vim.api.nvim_buf_set_lines(buf, 1, 4, false, {})
		vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf, modeline = false })
		assert(vim.deep_equal(languages(), { "python" }), "removed language kept: " .. vim.inspect(languages()))
		assert(not vim.api.nvim_buf_is_valid(lua_otter), "the removed language's otter buffer was left behind")
		local otterls = vim.lsp.get_clients({ name = "otter-ls[" .. buf .. "]" })
		assert(#otterls == 1, "otter-ls clients for the buffer: " .. #otterls)
	end)
	vim.bo[buf].modified = false
	vim.api.nvim_buf_delete(buf, { force = true })
	-- nvim-ts-autotag detaches from every markdown buffer by deleting buffer maps it never set; the
	-- caught "E31: No such mapping" still lands in v:errmsg. Clear only that so the spec-level errmsg
	-- check keeps catching real errors.
	if vim.v.errmsg == "E31: No such mapping" then
		vim.v.errmsg = ""
	end
	assert(ok, err)
end)

test("treesitter installs missing parser files and starts buffers opened before", function()
	local ts = require("nvim-treesitter")
	local install, get_installed = ts.install, ts.get_installed
	local requested, options, finish
	-- toml's parser file is gone (its leftover queries must not count) and installs later.
	ts.get_installed = function(kind)
		assert(kind == "parsers", "installed set must come from parser files, got " .. tostring(kind))
		return vim.tbl_filter(function(lang)
			return lang ~= "toml"
		end, get_installed("parsers"))
	end
	ts.install = function(langs, opts)
		requested, options = langs, opts
		return {
			await = function(_, callback)
				finish = callback
			end,
		}
	end
	-- A filetype with no parser yet stands in for a buffer opened before its parser was installed;
	-- registering it to the toml parser stands in for the install finishing.
	local buf = vim.api.nvim_create_buf(true, false)
	local ok, err = pcall(function()
		require("modules.configs.editor.treesitter")()
		assert(
			vim.wait(1000, function()
				return requested ~= nil
			end),
			"install was not requested"
		)
		assert(vim.deep_equal(requested, { "toml" }), "requested " .. vim.inspect(requested))
		assert(options and options.force, "missing parsers are not forced past leftover queries")
		vim.api.nvim_set_current_buf(buf)
		vim.bo[buf].filetype = "c12probe"
		assert(not vim.treesitter.highlighter.active[buf], "started before a parser was available")
		vim.treesitter.language.register("toml", "c12probe")
		finish(nil, true)
		assert(
			vim.wait(1000, function()
				return vim.treesitter.highlighter.active[buf] ~= nil
			end),
			"buffer opened before the install did not start Treesitter"
		)
	end)
	ts.install, ts.get_installed = install, get_installed
	vim.api.nvim_buf_delete(buf, { force = true })
	assert(ok, err)
end)

test("new and existing .tf files are Terraform", function()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	vim.fn.writefile({ 'resource "null_resource" "x" {}' }, dir .. "/main.tf")
	local ok, err = pcall(function()
		for name, expected in pairs({
			["new.tf"] = "terraform",
			["main.tf"] = "terraform",
			["vars.tfvars"] = "terraform-vars",
		}) do
			vim.cmd.edit(dir .. "/" .. name)
			assert(vim.bo.filetype == expected, ("%s: filetype=%q"):format(name, vim.bo.filetype))
			vim.cmd("bwipeout!")
		end
	end)
	vim.fn.delete(dir, "rf")
	assert(ok, err)
end)

test("project diagnostics stay inside the cwd path boundary", function()
	require("lazy.core.loader").load("trouble.nvim", { cmd = "test" }, { force = true })
	local opts = require("trouble.config").get("project_diagnostics")
	local filter = require("trouble.filter")
	local function inside(name)
		return filter.is({ filename = name }, opts.filter, { opts = opts, main = {} })
	end
	local base = vim.fn.tempname()
	local real, link = base .. "/project", base .. "/link"
	vim.fn.mkdir(real .. "/lua", "p")
	vim.fn.writefile({}, real .. "/lua/x.lua")
	assert(vim.uv.fs_symlink(real, link))
	local previous = vim.fn.chdir(real)
	local ok, err = pcall(function()
		local cwd = vim.uv.cwd()
		assert(inside(cwd .. "/lua/x.lua"), "file under the cwd was dropped")
		assert(not inside(cwd .. "-other/x.lua"), "sibling directory sharing the cwd prefix was kept")
		assert(not inside("/elsewhere/x.lua"), "unrelated file was kept")
		assert(not inside("[buffer:1]"), "unnamed buffer was kept")
		assert(inside(link .. "/lua/x.lua"), "file reached through a symlink to the cwd was dropped")
	end)
	vim.fn.chdir(previous)
	vim.fn.delete(base, "rf")
	assert(ok, err)
end)

test("GitHub Actions LSP uses the npm executable", function()
	local config = require("completion.servers.gh_actions_ls")
	assert(vim.deep_equal(config.cmd, { "actions-languageserver", "--stdio" }), "unexpected gh_actions_ls command")
	local entry = vim.iter(require("core.settings").lsp_deps):find(function(item)
		return type(item) == "table" and item.name == "gh_actions_ls"
	end)
	assert(entry and entry.command == "actions-languageserver", "Muster executable mapping is missing")
end)

test("droast linter parses structured findings", function()
	require("lazy.core.loader").load("nvim-lint", { cmd = "test" }, { force = true })
	local lint = require("lint")
	assert(vim.tbl_contains(lint.linters_by_ft.dockerfile, "droast"), "droast is not enabled for Dockerfiles")
	assert(vim.tbl_contains(require("core.settings").linter_deps, "droast"), "Muster does not declare droast")
	local diagnostics = lint.linters.droast.parser(vim.json.encode({
		findings = {
			{
				rule = "DF001",
				severity = "WARN",
				line = 2,
				column = 3,
				end_line = 2,
				end_column = 8,
				message = "pin the image tag",
			},
			{
				rule = "DF036",
				severity = "INFO",
				line = 0,
				message = "declare CMD or ENTRYPOINT",
			},
		},
	}))
	assert(#diagnostics == 2, "unexpected droast diagnostic count")
	assert(
		diagnostics[1].lnum == 1 and diagnostics[1].col == 2 and diagnostics[1].end_col == 7,
		"unexpected droast diagnostic range"
	)
	assert(
		diagnostics[1].severity == vim.diagnostic.severity.WARN and diagnostics[1].code == "DF001",
		"unexpected droast warning mapping"
	)
	assert(diagnostics[2].lnum == 0 and diagnostics[2].col == 0, "unexpected global droast diagnostic range")
	assert(
		diagnostics[2].severity == vim.diagnostic.severity.INFO and diagnostics[2].source == "droast",
		"unexpected global droast diagnostic mapping"
	)
end)

test("GitHub Actions lint includes zizmor", function()
	local lint = require("lint")
	assert(vim.tbl_contains(lint.linters_by_ft["yaml.github"], "zizmor"), "zizmor is not enabled for workflows")
	assert(vim.tbl_contains(require("core.settings").linter_deps, "zizmor"), "Muster does not declare zizmor")
	local adapter = lint.linters.zizmor
	assert(adapter.cmd == "zizmor" and adapter.stdin == true, "unexpected zizmor command contract")
	assert(vim.deep_equal(adapter.args, { "--format", "json-v1", "-" }), "unexpected zizmor arguments")
end)

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end
print(string.format("plugin_dependencies_spec: %d tests passed", tests_run))
