local M = {}

local conform = require("conform")
local format_opts = require("core.settings").format_opts
local disabled_workspaces = format_opts.format_disabled_dirs
local format_on_save = format_opts.format_on_save
local format_notify = format_opts.format_notify
local format_modifications_only = format_opts.format_modifications_only
local server_format_block_list = format_opts.server_format_block_list
local ft_format_block_list = format_opts.formatter_block_list

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
		return false
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
		return false
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
			return false
		end
	end
	-- Limit certain LSPs from autoformatting

	-- local bufnr =


	-- return true if none of the above conditions are met
	return true
end
