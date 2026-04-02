return function()
	local lint = require("lint")

	-- selene: stdin mode uses process CWD to find selene.toml, which may not be the nvim
	-- config dir. Pass --config explicitly so vim.yml is always found.
	lint.linters.selene.args = {
		"--display-style",
		"json",
		"--config",
		vim.fn.stdpath("config") .. "/selene.toml",
		"-",
	}

	-- markdownlint-cli2: stdin broken under bun's node shim (for-await yields empty).
	-- Override to file-based mode and update parser for "path:line:col severity message" format.
	lint.linters["markdownlint-cli2"].stdin = false
	lint.linters["markdownlint-cli2"].args = {}
	lint.linters["markdownlint-cli2"].stream = "stderr"
	lint.linters["markdownlint-cli2"].parser = require("lint.parser").from_pattern(
		"[^:]+:(%d+):(%d+) (%a+) (.+)",
		{ "lnum", "col", "severity", "message" },
		{ ["error"] = vim.diagnostic.severity.ERROR, ["warning"] = vim.diagnostic.severity.WARN },
		{ source = "markdownlint" }
	)

	lint.linters_by_ft = {
		dockerfile = { "hadolint" },
		go = { "golangcilint" },
		lua = { "selene" },
		markdown = { "markdownlint-cli2" },
		javascript = { "oxlint" },
		javascriptreact = { "oxlint" },
		nix = { "deadnix", "statix" },
		sh = { "shellcheck" },
		typescript = { "oxlint" },
		typescriptreact = { "oxlint" },
		systemd = { "systemdlint" },
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
