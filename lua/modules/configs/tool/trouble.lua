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
							function(item)
								return item.filename:find(vim.uv.cwd(), 1, true)
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
