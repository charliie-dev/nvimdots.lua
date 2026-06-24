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
	lint.linters["markdownlint-cli2"].args = {
		"--config",
		vim.fn.stdpath("config") .. "/.markdownlint.yml",
	}
	lint.linters["markdownlint-cli2"].stream = "stderr"
	lint.linters["markdownlint-cli2"].parser = require("lint.parser").from_pattern(
		"[^:]+:(%d+):(%d+) (%a+) (.+)",
		{ "lnum", "col", "severity", "message" },
		{ ["error"] = vim.diagnostic.severity.ERROR, ["warning"] = vim.diagnostic.severity.WARN },
		{ source = "markdownlint" }
	)

	-- shuck: lints shell embedded in GitHub Actions workflows (the `run:` blocks).
	-- Complements actionlint, which validates workflow syntax/expressions but not
	-- the embedded shell. Standalone sh/bash/zsh diagnostics already come from the
	-- shuck LSP server (see servers/shuck.lua), so shuck is only added to
	-- `yaml.github` here, not to `sh`/`zsh`. `shuck check` has no working stdin
	-- mode (it needs a project root), so run file-based and parse JSON output.
	lint.linters.shuck = {
		name = "shuck",
		cmd = "shuck",
		stdin = false,
		append_fname = true,
		args = { "check", "--output-format", "json" },
		stream = "stdout",
		ignore_exitcode = true, -- exit code 1 means violations were found
		parser = function(output, _)
			local diagnostics = {}
			if output == nil or output == "" then
				return diagnostics
			end
			local ok, decoded = pcall(vim.json.decode, output)
			if not ok or type(decoded) ~= "table" then
				return diagnostics
			end
			local severities = {
				error = vim.diagnostic.severity.ERROR,
				warning = vim.diagnostic.severity.WARN,
				info = vim.diagnostic.severity.INFO,
				hint = vim.diagnostic.severity.HINT,
			}
			for _, item in ipairs(decoded) do
				local loc = item.location or {}
				local endloc = item.end_location or {}
				table.insert(diagnostics, {
					lnum = (loc.row or 1) - 1,
					col = (loc.column or 1) - 1,
					end_lnum = (endloc.row or loc.row or 1) - 1,
					end_col = (endloc.column or loc.column or 1) - 1,
					severity = severities[item.severity] or vim.diagnostic.severity.WARN,
					code = item.code,
					message = item.message,
					source = "shuck",
				})
			end
			return diagnostics
		end,
	}

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
		["yaml.github"] = { "actionlint", "shuck" },
		zsh = { "zsh" },
	}

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
		callback = function()
			lint.try_lint(nil, { ignore_errors = true })
		end,
	})
end
