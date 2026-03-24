return function()
	local lint = require("lint")

	lint.linters_by_ft = {
		dockerfile = { "hadolint" },
		javascript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		nix = { "deadnix", "statix" },
		sh = { "shellcheck" },
		typescript = { "eslint_d" },
		typescriptreact = { "eslint_d" },
		yaml = { "ansiblelint" },
		["yaml.github"] = { "actionlint" },
		zsh = { "zsh" },
	}

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
		callback = function()
			lint.try_lint(nil, { ignore_errors = true })
		end,
	})
end
