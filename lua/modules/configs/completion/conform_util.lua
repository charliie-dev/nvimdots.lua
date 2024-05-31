local M = {}

local conform = require("conform")
local settings = require("core.settings")
local disabled_workspaces = settings.format_disabled_dirs
local format_on_save = settings.format_on_save
local format_notify = settings.format_notify
local format_modifications_only = settings.format_modifications_only
local server_format_block_list = settings.server_format_block_list
local ft_format_block_list = settings.formatter_block_list

vim.api.nvim_create_user_command("FormatToggle", function()
	M.toggle_format_on_save()
end, {})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	conform.format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

function M.format_filter(clients)
	return vim.tbl_filter(function(client)
		local status_ok, formatting_supported = pcall(function()
			return client.supports_method("textDocument/formatting")
		end)
		if not server_format_block_list[client.name] and status_ok and formatting_supported then
			return client.name
		end
	end, clients)
end

function M.format_on_save(bufnr)
	if not format_on_save then
		return
	end
	-- Disable autoformat for files for certain filetypes
	if vim.tbl_contains(ft_format_block_list, vim.bo[bufnr].filetype) then
		if format_notify then
			vim.notify(
				string.format("[LSP] Formatting for [%s] has been disabled.", vim.bo[bufnr].filetype),
				vim.log.levels.WARN,
				{ title = "LSP Formatter Warning" }
			)
		end
		return
	end
	-- Disable autoformat for files in a certain path
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	for i = 1, #disabled_workspaces do
		if bufname:match(vim.fs.normalize(disabled_workspaces[i])) then
			if format_notify then
				vim.notify(
					string.format(
						"[LSP] Formatting for all files under [%s] has been disabled.",
						vim.fs.normalize(disabled_workspaces[i])
					),
					vim.log.levels.WARN,
					{ title = "LSP Formatter Warning" }
				)
			end
			return
		end
	end
	-- Limit certain LSPs from autoformatting

	-- local bufnr =
end
