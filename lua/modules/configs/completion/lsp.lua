return function()
	local nvim_lsp = require("lspconfig")
	local mason = require("mason")
	local mason_lspconfig = require("mason-lspconfig")

	require("lspconfig.ui.windows").default_options.border = "single"

	local icons = {
		ui = require("modules.utils.icons").get("ui", true),
		misc = require("modules.utils.icons").get("misc", true),
	}

	mason.setup({
		ui = {
			border = "rounded",
			icons = {
				package_pending = icons.ui.Modified_alt,
				package_installed = icons.ui.Check,
				package_uninstalled = icons.misc.Ghost,
			},
		},
		keymaps = {
			toggle_server_expand = "<CR>",
			install_server = "i",
			update_server = "u",
			check_server_version = "c",
			update_all_servers = "U",
			check_outdated_servers = "C",
			uninstall_server = "X",
			cancel_installation = "<C-c>",
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
			"lua_ls",
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
		on_attach = function()
			require("lsp_signature").on_attach({
				bind = true,
				use_lspsaga = false,
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
		function(server)
			require("lspconfig")[server].setup({
				capabilities = opts.capabilities,
				on_attach = opts.on_attach,
			})
		end,

		bashls = function()
			local _opts = require("completion.servers.bashls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.bashls.setup(final_opts)
		end,

		clangd = function()
			local _capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, capabilities)
			local _opts = require("completion.servers.clangd")
			local final_opts =
				vim.tbl_deep_extend("keep", _opts, { on_attach = opts.on_attach, capabilities = _capabilities })
			nvim_lsp.clangd.setup(final_opts)
		end,

		emmet_ls = function()
			local _opts = require("completion.servers.emmet_ls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.emmet_ls.setup(final_opts)
		end,

		gopls = function()
			local _opts = require("completion.servers.gopls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.gopls.setup(final_opts)
		end,

		jsonls = function()
			local _opts = require("completion.servers.jsonls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.jsonls.setup(final_opts)
		end,

		ltex = function()
			local ltex_attach = function()
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
			local _opts = require("completion.servers.ltex")
			local final_opts =
				vim.tbl_deep_extend("keep", _opts, { on_attach = ltex_attach, capabilities = opts.capabilities })
			nvim_lsp.ltex.setup(final_opts)
		end,

		marksman = function()
			local _opts = require("completion.servers.marksman")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.marksman.setup(final_opts)
		end,

		pyright = function()
			local _opts = require("completion.servers.pyright")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.pyright.setup(final_opts)
		end,

		lua_ls = function()
			-- require("lua-dev").setup()
			local _opts = require("completion.servers.lua_ls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.lua_ls.setup(final_opts)
		end,

		taplo = function()
			local _opts = require("completion.servers.taplo")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.taplo.setup(final_opts)
		end,

		texlab = function()
			local _opts = require("completion.servers.texlab")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.texlab.setup(final_opts)
		end,

		vimls = function()
			local _opts = require("completion.servers.vimls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.vimls.setup(final_opts)
		end,

		yamlls = function()
			local _opts = require("completion.servers.yamlls")
			local final_opts = vim.tbl_deep_extend("keep", _opts, opts)
			nvim_lsp.yamlls.setup(final_opts)
		end,
	})
end
