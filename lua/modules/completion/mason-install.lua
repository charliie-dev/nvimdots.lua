require("mason-tool-installer").setup({
    -- a list of all tools you want to ensure are installed upon
    -- start; they should be the names Mason uses for each tool
    ensure_installed = {

        -- you can pin a tool to a particular version
        -- { 'golangci-lint', version = '1.47.0' },

        -- you can turn off/on auto_update per tool
        -- { "bash-language-server", auto_update = true },

        -- LSP
        "bash-language-server",
        "clangd",
        "emmet-ls", -- HTML lsp
        "json-lsp",
        "ltex-ls",
        "lua-language-server", -- equals sumneko_lua
        "marksman",
        "pyright", -- Static type checker for Python
        "texlab",
        "vim-language-server",
        "yaml-language-server",

        -- Formatter
        "stylua", -- An opinionated Lua code formatter.
        "prettierd",
        "black",
        "shfmt", -- A shell parser, formatter, and interpreter with bash support.
        "flake8", -- for catching errors & check some PEP8 violations
        "isort", -- Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.
        "misspell", -- Correct commonly misspelled English words in source files.
        "markdownlint", -- A Node.js style checker and lint tool for Markdown/CommonMark files.
        "cbfmt", -- A rust cli tool to format codeblocks in markdown/org. Remember to use `.cbfmt.toml` to set foramtters for each lang.

        -- Linter
        "shellcheck", -- ShellCheck, a static analysis tool for shell scripts.
        "eslint_d", -- Javascript Linter, but faster
    },

    -- if set to true this will check each tool for updates. If updates
    -- are available the tool will be updated. This setting does not
    -- affect :MasonToolsUpdate or :MasonToolsInstall.
    -- Default: false
    auto_update = false,

    -- automatically install / update on startup. If set to false nothing
    -- will happen on startup. You can use :MasonToolsInstall or
    -- :MasonToolsUpdate to install tools and check for updates.
    -- Default: true
    run_on_start = true,

    -- set a delay (in ms) before the installation starts. This is only
    -- effective if run_on_start is set to true.
    -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
    -- Default: 0
    start_delay = 3000, -- 3 second delay
})

vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    callback = function()
        vim.schedule(function()
            print("mason-tool-installer has finished")
            vim.notify("mason-tool-installer has finished!", vim.log.levels.INFO, { title = "MasonToolsInstaller" })
        end)
    end,
})
