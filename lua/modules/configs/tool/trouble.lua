return function()
	local icons = {
		ui = require("modules.utils.icons").get("ui", true),
	}

	require("modules.utils").load_plugin("trouble", {
		auto_open = false,
		auto_close = false,
		auto_jump = false,
		auto_preview = true,
		auto_refresh = true,
		focus = false,
		follow = true,
		restore = true,
		indent_guides = true,
		multiline = true,
		max_items = 200,
		preview = {
			type = "main",
			scratch = true,
		},
		icons = {
			indent = {
				fold_open = icons.ui.ArrowOpen,
				fold_closed = icons.ui.ArrowClosed,
			},
			folder_closed = icons.ui.Folder,
			folder_open = icons.ui.FolderOpen,
		},
		modes = {
			project_diagnostics = {
				mode = "diagnostics",
				filter = {
					any = {
						{
							-- Keep files under the cwd: compare whole path components, then retry with
							-- symlinks resolved. Unnamed buffers ("[buffer:N]") are relative and never match;
							-- relpath() would otherwise anchor them to the cwd.
							function(item)
								local cwd = vim.uv.cwd()
								if not cwd or vim.fn.isabsolutepath(item.filename) == 0 then
									return false
								end
								if vim.fs.relpath(cwd, item.filename) then
									return true
								end
								local real = vim.uv.fs_realpath(item.filename)
								return real ~= nil and vim.fs.relpath(vim.uv.fs_realpath(cwd) or cwd, real) ~= nil
							end,
						},
					},
				},
			},
			symbols = {
				desc = "document symbols",
				mode = "lsp_document_symbols",
				focus = false,
				win = { position = "right" },
			},
			incoming_calls = {
				desc = "incoming calls",
				mode = "lsp_incoming_calls",
			},
			outgoing_calls = {
				desc = "outgoing calls",
				mode = "lsp_outgoing_calls",
			},
		},
	})
end
