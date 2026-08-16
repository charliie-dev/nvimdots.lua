local M = {}
local has_setup = false

M.setup = function()
	if has_setup then
		return
	end
	local mason_registry = require("mason-registry")
	local server = require("completion.lsp-server")
	local lsp_entries = {}
	for _, entry in ipairs(require("core.settings").lsp_deps) do
		local name = type(entry) == "table" and entry.name or entry
		lsp_entries[name] = entry
	end

	local package_to_lspconfig = {}
	local registered_aliases = {}
	local function rebuild_mappings()
		local ok, specs = pcall(mason_registry.get_all_package_specs)
		if not ok or type(specs) ~= "table" or not vim.islist(specs) then
			return false
		end

		local mappings = {}
		local aliases = {}
		for _, spec in ipairs(specs) do
			local lspconfig = vim.tbl_get(spec, "neovim", "lspconfig")
			if type(spec.name) == "string" and type(lspconfig) == "string" then
				mappings[spec.name] = lspconfig
				if registered_aliases[spec.name] ~= lspconfig then
					aliases[spec.name] = { lspconfig }
				end
			end
		end
		package_to_lspconfig = mappings
		if type(mason_registry.register_package_aliases) == "function" and next(aliases) then
			local registered = pcall(mason_registry.register_package_aliases, aliases)
			if registered then
				for package_name, package_aliases in pairs(aliases) do
					registered_aliases[package_name] = package_aliases[1]
				end
			end
		end
		return true
	end

	---Enable a declared language server provided by a Mason package.
	---@param pkg string|{name: string}
	local function setup_lsp_for_package(pkg)
		local package_name = type(pkg) == "string" and pkg or pkg.name
		local entry = lsp_entries[package_to_lspconfig[package_name]]
		if entry then
			server.enable(entry)
		end
	end

	local function setup_installed_packages()
		for _, package_name in ipairs(mason_registry.get_installed_package_names()) do
			setup_lsp_for_package(package_name)
		end
	end

	rebuild_mappings()
	setup_installed_packages()

	local setup_after_update = vim.schedule_wrap(function()
		if rebuild_mappings() then
			setup_installed_packages()
		end
	end)
	mason_registry:on("update:success", setup_after_update)
	mason_registry:on("package:install:success", vim.schedule_wrap(setup_lsp_for_package))
	has_setup = true

	vim.defer_fn(function()
		pcall(mason_registry.refresh, function() end)
	end, 100)
end

return M
