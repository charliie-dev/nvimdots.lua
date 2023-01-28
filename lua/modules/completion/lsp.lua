local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

require("lspconfig.ui.windows").default_options.border = "single"

mason.setup({
	ui = {
		border = "rounded",
	},
})
mason_lspconfig.setup({
	ensure_installed = {
		"bashls",
		"clangd",
		"emmet_ls",
		"gopls",
		"jsonls",
		"ltex",
		"marksman",
		"pyright",
		"sumneko_lua",
		"taplo",
		"texlab",
		"vimls",
		"yamlls",
	},
	automatic_installation = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local opts = {
	on_attach = function(client, bufnr)
		require("lsp_signature").on_attach({
			bind = true,
			use_lspsaga = true,
			floating_window = true,
			fix_pos = true,
			hint_enable = true,
			hi_parameter = "Search",
			handler_opts = {
				border = "rounded",
			},
		})
	end,
	capabilities = capabilities,
}

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = opts.capabilities,
			on_attach = opts.on_attach,
		})
	end,

	["bashls"] = function()
		local bashls_opts = require("modules.completion.server-settings.bashls")
		local extra_opts = vim.tbl_deep_extend("keep", bashls_opts, opts)
		lspconfig.bashls.setup(extra_opts)
	end,

	["clangd"] = function()
		local clangd_capabilities = capabilities
		clangd_capabilities.offsetEncoding = { "utf-16", "utf-8" }
		local clangd_opts = require("modules.completion.server-settings.clangd")
		local extra_opts =
			vim.tbl_deep_extend("keep", clangd_opts, { on_attach = opts.on_attach, capabilities = clangd_capabilities })
		lspconfig.clangd.setup(extra_opts)
	end,

	["emmet_ls"] = function()
		local emmetls_opts = require("modules.completion.server-settings.emmet_ls")
		local extra_opts = vim.tbl_deep_extend("keep", emmetls_opts, opts)
		lspconfig.emmet_ls.setup(extra_opts)
	end,

	["gopls"] = function()
		local gopls_opts = require("modules.completion.server-settings.gopls")
		local extra_opts = vim.tbl_deep_extend("keep", gopls_opts, opts)
		lspconfig.gopls.setup(extra_opts)
	end,

	["jsonls"] = function()
		local jsonls_opts = require("modules.completion.server-settings.jsonls")
		local extra_opts = vim.tbl_deep_extend("keep", jsonls_opts, opts)
		lspconfig.jsonls.setup(extra_opts)
	end,

	["ltex"] = function()
		local ltex_attach = function(client, bufnr)
			require("lsp_signature").on_attach({
				bind = true,
				use_lspsaga = true,
				floating_window = true,
				fix_pos = true,
				hint_enable = true,
				hi_parameter = "Search",
				handler_opts = { "double" },
			})
			require("ltex_extra").setup({
				load_langs = { "en-US" },
				init_check = true,
				path = "./spell",
				log_level = "error",
			})
		end
		local ltex_opts = require("modules.completion.server-settings.ltex")
		local extra_opts =
			vim.tbl_deep_extend("keep", ltex_opts, { on_attach = ltex_attach, capabilities = opts.capabilities })
		lspconfig.ltex.setup(extra_opts)
	end,

	["marksman"] = function()
		local marksman_opts = require("modules.completion.server-settings.marksman")
		local extra_opts = vim.tbl_deep_extend("keep", marksman_opts, opts)
		lspconfig.marksman.setup(extra_opts)
	end,

	["pyright"] = function()
		local pyright_opts = require("modules.completion.server-settings.pyright")
		local extra_opts = vim.tbl_deep_extend("keep", pyright_opts, opts)
		lspconfig.pyright.setup(extra_opts)
	end,

	["sumneko_lua"] = function()
		-- require("lua-dev").setup()
		local sumneko_opts = require("modules.completion.server-settings.sumneko_lua")
		local extra_opts = vim.tbl_deep_extend("keep", sumneko_opts, opts)
		-- print(vim.inspect(extra_opts))
		lspconfig.sumneko_lua.setup(extra_opts)
	end,

	["taplo"] = function()
		local taplo_opts = require("modules.completion.server-settings.taplo")
		local extra_opts = vim.tbl_deep_extend("keep", taplo_opts, opts)
		lspconfig.taplo.setup(extra_opts)
	end,

	["texlab"] = function()
		local texlab_opts = require("modules.completion.server-settings.texlab")
		local extra_opts = vim.tbl_deep_extend("keep", texlab_opts, opts)
		lspconfig.texlab.setup(extra_opts)
	end,

	["vimls"] = function()
		local vimls_opts = require("modules.completion.server-settings.vimls")
		local extra_opts = vim.tbl_deep_extend("keep", vimls_opts, opts)
		lspconfig.vimls.setup(extra_opts)
	end,

	["yamlls"] = function()
		local yamlls_opts = require("modules.completion.server-settings.yamlls")
		local extra_opts = vim.tbl_deep_extend("keep", yamlls_opts, opts)
		lspconfig.yamlls.setup(extra_opts)
	end,
})
