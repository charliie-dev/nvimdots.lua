return function()
	local null_ls = require("null-ls")
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
				"yaml",
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

	require("modules.utils").load_plugin("null-ls", {
		border = "rounded",
		debug = false,
		log_level = "warn",
		update_in_insert = false,
		diagnostics_format = "[#{s} #{c}] #{m}",
		sources = sources,
	})

	require("completion.mason-null-ls").setup()

	-- Setup usercmd to register/deregister available source(s)
	local function _gen_completion()
		local sources_cont = null_ls.get_source({
			filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" }),
		})
		local completion_items = {}
		for _, server in pairs(sources_cont) do
			table.insert(completion_items, server.name)
		end
		return completion_items
	end
	vim.api.nvim_create_user_command("NullLsToggle", function(opts)
		if vim.tbl_contains(_gen_completion(), opts.args) then
			null_ls.toggle({ name = opts.args })
		else
			vim.notify(
				string.format("[Null-ls] Unable to find any registered source named [%s].", opts.args),
				vim.log.levels.ERROR,
				{ title = "Null-ls Internal Error" }
			)
		end
	end, {
		nargs = 1,
		complete = _gen_completion,
	})

	-- auto stop bashls, shellcheck and shfmt when editing docker-related files
	vim.api.nvim_create_autocmd("LspAttach", {
		pattern = {
			".env",
		},
		callback = function()
			vim.api.nvim_command([[LspStop bashls]])
			vim.api.nvim_command([[NullLsToggle shellcheck]])
			vim.api.nvim_command([[NullLsToggle shfmt]])
		end,
	})

	require("completion.formatting").configure_format_on_save()
end
