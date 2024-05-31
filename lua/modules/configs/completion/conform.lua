return function()
	---Return formatter args required by `prepend_args`
	---@param formatter_name string
	---@return table|nil
	local function formatter_args(formatter_name)
		local ok, args = pcall(require, "user.configs.formatters." .. formatter_name)
		if not ok then
			args = require("completion.formatters." .. formatter_name)
		end
		return args
	end

	require("modules.utils").load_plugin("conform", {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			-- Use a sub-list to run only the first available formatter
			javascript = { { "prettierd", "prettier" } },
			markdown = { "markdownlint", "mdformat", "injected" },
			sh = { "shfmt", "shellcheck", "shellharden" },
			toml = { "taplo" },
			yaml = { "yamlfix", "yamlfmt" },
			nix = { "nixpkgs_fmt" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			objc = { "clang_format" },
			objcpp = { "clang_format" },
			cs = { "clang_format" },
			java = { "clang_format" },
			cuda = { "clang_format" },
			proto = { "clang_format" },
			-- Use the "*" filetype to run formatters on all filetypes.
			["*"] = { "codespell" },
			-- Use the "_" filetype to run formatters on filetypes that don't
			-- have other formatters configured.
			["_"] = { "trim_whitespace" },
		},
		formatters = {
			markdownlint = {
				prepend_args = { "--disable MD033" },
			},
			injected = {
				options = {
					ignore_errors = false,
					lang_to_ext = {
						bash = "sh",
						c_sharp = "cs",
						elixir = "exs",
						javascript = "js",
						julia = "jl",
						latex = "tex",
						markdown = "md",
						python = "py",
						ruby = "rb",
						rust = "rs",
						teal = "tl",
						typescript = "ts",
					},
				},
			},
			prettierd = {
				options = {
					ft_parsers = {
						javascript = "babel",
						javascriptreact = "babel",
						typescript = "typescript",
						typescriptreact = "typescript",
						vue = "vue",
						css = "css",
						scss = "scss",
						less = "less",
						html = "html",
						json = "json",
						jsonc = "json",
						yaml = "yaml",
						-- markdown = "markdown",
						["markdown.mdx"] = "mdx",
						graphql = "graphql",
						handlebars = "glimmer",
					},
				},
			},
			clang_format = {
				prepend_args = formatter_args("clang_format"),
			},
		},
		-- Set the log level. Use `:ConformInfo` to see the location of the log file.
		log_level = vim.log.levels.ERROR,
		-- Conform will notify you when a formatter errors
		notify_on_error = true,

		format_on_save = require("modules.configs.completion.conform_util").format_on_save,
	})
end
