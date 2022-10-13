local formatting = require("modules.completion.formatting")

vim.api.nvim_command([[packadd lsp_signature.nvim]])
vim.api.nvim_command([[packadd lspsaga.nvim]])
vim.api.nvim_command([[packadd cmp-nvim-lsp]])

local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup()
mason_lspconfig.setup({
	ensure_installed = {
		"bashls",
		"clangd",
		"emmet_ls",
		"gopls",
		"jsonls",
		"pyright",
		"sumneko_lua",
		"taplo",
		"vimls",
		"yamlls",
	},
	automatic_installation = true,
})

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local buf_keymap = vim.api.nvim_buf_set_keymap
	buf_keymap(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
	buf_keymap(bufnr, "n", "gT", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	-- NOTE: many servers do not support the Declaration
	buf_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	-- replace by Lspsaga's hover_doc
	-- buf_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_keymap(bufnr, "n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
	-- NOTE: like Lspsaga's lsp_finder
	buf_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
	-- replace by Lspsaga's diagnostics
	-- buf_keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	-- buf_keymap(bufnr, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	-- NOTE: nvim 0.8 use vim.lsp.buf.format
	vim.api.nvim_command([[ command! Format execute 'lua vim.lsp.buf.format({ async = true })' ]])
	buf_keymap(bufnr, "n", "<leader>f", "<cmd>Format<cr>", opts)
	buf_keymap(bufnr, "n", "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	-- NOTE: lsp rename can only be used if the it's recongnized by lsp; otherwise use Spectre.nvim
	buf_keymap(bufnr, "n", "rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	-- buf_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	-- buf_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
	-- buf_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	-- buf_keymap(bufnr, 'n', '<leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	-- buf_keymap(bufnr, 'n', '<leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	-- buf_keymap(bufnr, 'n', '<leader>lwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local opts = {
	on_attach = function(client, bufnr)
		require("lsp_signature").on_attach({
			bind = true,
			use_lspsaga = true,
			floating_window = true,
			fix_pos = true,
			hint_enable = true,
			hi_parameter = "Search",
			handler_opts = { "double" },
		})
		lsp_keymaps(bufnr)
	end,
	capabilities = capabilities,
}

-- Override server settings
for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
	if server == "bashls" then
		local bashls_opts = require("modules.completion.server-settings.bashls")
		local extra_opts = vim.tbl_deep_extend("force", bashls_opts, opts)
		lspconfig.bashls.setup(extra_opts)
	end

	if server == "clangd" then
		local clangd_capabilities = capabilities
		-- Workaround for clangd warning: multiple different client offset_encodings detected for buffer, this is not supported yet
		clangd_capabilities.offsetEncoding = { "utf-16" }
		local clangd_opts = require("modules.completion.server-settings.clangd")
		local extra_opts =
			vim.tbl_deep_extend("force", clangd_opts, { on_attach = opts.on_attach, capabilities = clangd_capabilities })
		lspconfig.clangd.setup(extra_opts)
	end

	if server == "emmet_ls" then
		local emmetls_opts = require("modules.completion.server-settings.emmet_ls")
		local extra_opts = vim.tbl_deep_extend("force", emmetls_opts, opts)
		lspconfig.emmet_ls.setup(extra_opts)
	end

	if server == "gopls" then
		local gopls_opts = require("modules.completion.server-settings.gopls")
		local extra_opts = vim.tbl_deep_extend("force", gopls_opts, opts)
		lspconfig.gopls.setup(extra_opts)
	end

	if server == "jsonls" then
		local jsonls_opts = require("modules.completion.server-settings.jsonls")
		local extra_opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
		lspconfig.jsonls.setup(extra_opts)
	end

	if server == "pyright" then
		local pyright_opts = require("modules.completion.server-settings.pyright")
		local extra_opts = vim.tbl_deep_extend("force", pyright_opts, opts)
		lspconfig.pyright.setup(extra_opts)
	end

	if server == "sumneko_lua" then
		-- require("lua-dev").setup()
		local sumneko_opts = require("modules.completion.server-settings.sumneko_lua")
		local extra_opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
		-- print(vim.inspect(extra_opts))
		lspconfig.sumneko_lua.setup(extra_opts)
	end

	if server == "taplo" then
		local taplo_opts = require("modules.completion.server-settings.taplo")
		local extra_opts = vim.tbl_deep_extend("force", taplo_opts, opts)
		lspconfig.taplo.setup(extra_opts)
	end

	if server == "vimls" then
		local vimls_opts = require("modules.completion.server-settings.vimls")
		local extra_opts = vim.tbl_deep_extend("force", vimls_opts, opts)
		lspconfig.vimls.setup(extra_opts)
	end

	if server == "yamlls" then
		local yamlls_opts = require("modules.completion.server-settings.yamlls")
		local extra_opts = vim.tbl_deep_extend("force", yamlls_opts, opts)
		lspconfig.yamlls.setup(extra_opts)
	end
end

formatting.configure_format_on_save()
