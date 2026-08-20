local modules = { "completion", "editor", "lang", "tool", "ui" }
local failures, specs, lazy_plugins = {}, nil, nil

local function test(name, callback)
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
		59,
		"2ddaf3f5eb1a05821ba6694a6a64316c54b64026f830899f1119c3c6c05335bf"
	)
	assert_manifest("nested manifest", nested, 36, "6799ed5d32cbf0b04c487fd95d990173b91c30d42b4828ba15c64c5c681693ac")
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
		["nvim-mini/mini.ai"] = { config = require("editor.ai_textobj"), version = "*" },
		["nvim-treesitter/nvim-treesitter-textobjects"] = { config = require("editor.ts-textobjects"), branch = "main" },
		["windwp/nvim-ts-autotag"] = { config = require("editor.ts-autotag") },
		["HiPhish/rainbow-delimiters.nvim"] = { config = require("editor.rainbow_delims") },
		["nvim-treesitter/nvim-treesitter-context"] = { config = require("editor.ts-context") },
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
	assert_dependencies(dap, { "jay-babu/mason-nvim-dap.nvim", "rcarriga/nvim-dap-ui" })
	assert_dependencies(dependency(dap, "jay-babu/mason-nvim-dap.nvim"), { "mason-org/mason.nvim" })
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

if #failures > 0 then
	vim.api.nvim_err_writeln(table.concat(failures, "\n"))
	vim.cmd.cquit(1)
end
print("plugin_dependencies_spec: 6 tests passed")
