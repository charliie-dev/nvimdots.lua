vim.api.nvim_command([[packadd lsp_signature.nvim]])
vim.api.nvim_command([[packadd lspsaga.nvim]])
vim.api.nvim_command([[packadd cmp-nvim-lsp]])

-- Custom vertual text highlight groups to make error hint looks cool
local util = require("utils")
local c = require("kanagawa.colors").setup().diag
local bg = require("kanagawa.colors").setup().bg
local alpha = 0.4
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = c.error, bg = util.blend(c.error, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = c.warning, bg = util.blend(c.warning, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = c.info, bg = util.blend(c.info, bg, alpha) })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = c.hint, bg = util.blend(c.hint, bg, alpha) })

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

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local keymap = vim.keymap.set
    keymap("n", "gf", "<cmd>Lspsaga lsp_finder<cr>", opts)
    keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
    keymap("n", "gd", "<cmd>Lspsaga peek_definition<cr>", opts)
    keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
    keymap("n", "gT", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
    keymap("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
    keymap("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<cr>", opts)
    keymap("n", "<leader>o", "<cmd>LSoutlineToggle<cr>", opts)
    keymap("n", "<C-n>", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
    keymap("n", "<C-p>", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
    keymap("n", "ca", "<cmd>Lspsaga code_action<cr>", opts)
    keymap("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
    keymap("n", "<F2>", "<cmd>Lspsaga rename<cr>", opts)
    -- NOTE: lsp rename can only be used if the it's recongnized by lsp; otherwise use Spectre.nvim
    -- keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<cr>", opts)
    -- keymap("n", "<leader>lwa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", opts)
    -- keymap("n", "<leader>lwr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", opts)
    -- keymap("n", "<leader>lwl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", opts)
end

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
        local extra_opts = vim.tbl_deep_extend(
            "force",
            clangd_opts,
            { on_attach = opts.on_attach, capabilities = clangd_capabilities }
        )
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

    if server == "ltex" then
        local ltex_attach = function(client, bufnr)
            lsp_keymaps(bufnr)
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
                log_level = "info",
            })
        end
        local ltex_opts = require("modules.completion.server-settings.ltex")
        local extra_opts =
        vim.tbl_deep_extend("force", ltex_opts, { on_attach = ltex_attach, capabilities = opts.capabilities })
        lspconfig.ltex.setup(extra_opts)
    end

    if server == "marksman" then
        local marksman_opts = require("modules.completion.server-settings.marksman")
        local extra_opts = vim.tbl_deep_extend("force", marksman_opts, opts)
        lspconfig.marksman.setup(extra_opts)
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

    if server == "texlab" then
        local texlab_opts = require("modules.completion.server-settings.texlab")
        local extra_opts = vim.tbl_deep_extend("force", texlab_opts, opts)
        lspconfig.texlab.setup(extra_opts)
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
