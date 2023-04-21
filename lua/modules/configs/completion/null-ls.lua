return function()
	local null_ls = require("null-ls")
	local mason_null_ls = require("mason-null-ls")
	local btns = null_ls.builtins

	-- Please set additional flags for the supported servers here
	-- Don't specify any config here if you are using the default one.
	local sources = {
		btns.formatting.clang_format.with({
			filetypes = { "c", "cpp" },
			extra_args = require("completion.formatters.clang_format"),
		}),
		btns.formatting.prettier.with({
			filetypes = {
				"vue",
				"typescript",
				"javascript",
				"typescriptreact",
				"javascriptreact",
				"html",
				"css",
				"scss",
				"sh",
				"markdown",
			},
		}),
		btns.diagnostics.markdownlint.with({
			extra_args = { "--disable MD033" },
		}),
		-- example for changing diagnostics_format
		btns.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{s} #{c}]" }),
	}

	null_ls.setup({
		border = "rounded",
		debug = false,
		log_level = "warn",
		update_in_insert = false,
		diagnostics_format = "[#{s} #{c}] #{m}",
		sources = sources,
	})

	mason_null_ls.setup({
		ensure_installed = require("core.settings").null_ls_deps,
		automatic_installation = false,
		automatic_setup = true,
		handlers = {},
	})

	require("completion.formatting").configure_format_on_save()
end
