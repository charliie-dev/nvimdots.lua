return function()
	require("modules.utils").gen_lspkind_hl()

	local icons = {
		cmp = require("modules.utils.icons").get("cmp", true),
		diagnostics = require("modules.utils.icons").get("diagnostics", true),
		kind = require("modules.utils.icons").get("kind", true),
		type = require("modules.utils.icons").get("type", true),
		ui = require("modules.utils.icons").get("ui", true),
	}

	local function set_sidebar_icons()
		-- Set icons for sidebar
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = icons.diagnostics.Error_alt,
					[vim.diagnostic.severity.WARN] = icons.diagnostics.Warning_alt,
					[vim.diagnostic.severity.INFO] = icons.diagnostics.Information_alt,
					[vim.diagnostic.severity.HINT] = icons.diagnostics.Hint_alt,
				},
			},
		})
	end

	set_sidebar_icons()

	require("modules.utils").load_plugin("lspsaga", {
		-- Breadcrumbs: https://nvimdev.github.io/lspsaga/breadcrumbs/
		symbol_in_winbar = {
			enable = false,
			separator = " " .. icons.ui.DoubleSeparator,
			hide_keyword = false,
			show_file = false,
			folder_level = 1,
			color_mode = true,
			delay = 100,
		},
		-- Callhierarchy: https://nvimdev.github.io/lspsaga/callhierarchy/
		callhierarchy = {
			layout = "float",
			keys = {
				edit = "e",
				vsplit = "v",
				split = "s",
				tabe = "t",
				quit = "q",
				shuttle = "[]",
				toggle_or_req = "u",
				close = "<Esc>",
			},
		},
		-- Finder: https://nvimdev.github.io/lspsaga/finder/
		finder = {
			max_height = 0.5,
			left_width = 0.3,
			default = "ref+imp",
			layout = "float",
			silent = false,
			keys = {
				shuttle = "[]",
				toggle_or_open = "<CR>",
				vsplit = "v",
				split = "s",
				tabe = "t",
				tabnew = "T",
				quit = "q",
				close = "<Esc>",
			},
		},
		-- Code Action: https://nvimdev.github.io/lspsaga/codeaction/
		code_action = {
			num_shortcut = true,
			only_in_cursor = false,
			show_server_name = true,
			extend_gitsigns = false,
			keys = {
				quit = "q",
				exec = "<CR>",
			},
		},
		-- Diagnostics: https://nvimdev.github.io/lspsaga/diagnostic/
		diagnostic = {
			jump_num_shortcut = true,
			max_width = 0.5,
			max_height = 0.6,
			extend_relatedInformation = true,
			show_layout = "float",
			show_normal_height = 10,
			max_show_width = 0.9,
			max_show_height = 0.6,
			diagnostic_only_current = false,
			keys = {
				exec_action = "r",
				quit = "q",
				toggle_or_jump = "<CR>",
				quit_in_show = { "q", "<Esc>" },
			},
		},
		-- Hover: https://nvimdev.github.io/lspsaga/hover/
		hover = {
			max_width = 0.45,
			max_height = 0.7,
			open_link = "gl",
			-- Undocumented: read only when none of open/explorer/wslview/xdg-open is available
			open_browser = "silent !" .. require("core.settings").lspsaga_browser,
		},
		-- Impl: https://nvimdev.github.io/lspsaga/implement/
		implement = {
			enable = true,
			sign = true,
			virtual_text = false,
			priority = 100,
		},
		-- LightBulb: https://nvimdev.github.io/lspsaga/lightbulb/
		lightbulb = {
			enable = false,
			sign = true,
			virtual_text = false,
			debounce = 10,
			sign_priority = 20,
		},
		-- Rename: https://nvimdev.github.io/lspsaga/rename/
		rename = {
			in_select = false,
			auto_save = false,
			project_max_width = 0.5,
			project_max_height = 0.5,
			keys = {
				quit = "<C-c>",
				exec = "<CR>",
				select = "x",
			},
		},
		-- Beacon: https://nvimdev.github.io/lspsaga/misc/#beacon
		beacon = {
			enable = true,
			frequency = 12,
		},
		-- Generic UI Options: https://nvimdev.github.io/lspsaga/misc/#generic-ui-options
		ui = {
			border = "single", -- Can be single, double, rounded, solid, shadow.
			devicon = true,
			title = true,
			expand = icons.ui.ArrowClosed,
			collapse = icons.ui.ArrowOpen,
			code_action = icons.ui.CodeAction,
			lines = { "┗", "┣", "┃", "━", "┏" },
			imp_sign = icons.kind.Implementation,
			kind = {
				-- Kind
				Class = { icons.kind.Class, "LspKindClass" },
				Constant = { icons.kind.Constant, "LspKindConstant" },
				Constructor = { icons.kind.Constructor, "LspKindConstructor" },
				Enum = { icons.kind.Enum, "LspKindEnum" },
				EnumMember = { icons.kind.EnumMember, "LspKindEnumMember" },
				Event = { icons.kind.Event, "LspKindEvent" },
				Field = { icons.kind.Field, "LspKindField" },
				File = { icons.kind.File, "LspKindFile" },
				Function = { icons.kind.Function, "LspKindFunction" },
				Interface = { icons.kind.Interface, "LspKindInterface" },
				Key = { icons.kind.Keyword, "LspKindKey" },
				Method = { icons.kind.Method, "LspKindMethod" },
				Module = { icons.kind.Module, "LspKindModule" },
				Namespace = { icons.kind.Namespace, "LspKindNamespace" },
				Operator = { icons.kind.Operator, "LspKindOperator" },
				Package = { icons.kind.Package, "LspKindPackage" },
				Property = { icons.kind.Property, "LspKindProperty" },
				Struct = { icons.kind.Struct, "LspKindStruct" },
				TypeParameter = { icons.kind.TypeParameter, "LspKindTypeParameter" },
				Variable = { icons.kind.Variable, "LspKindVariable" },
				-- Type
				Array = { icons.type.Array, "LspKindArray" },
				Boolean = { icons.type.Boolean, "LspKindBoolean" },
				Null = { icons.type.Null, "LspKindNull" },
				Number = { icons.type.Number, "LspKindNumber" },
				Object = { icons.type.Object, "LspKindObject" },
				String = { icons.type.String, "LspKindString" },
				-- ccls-specific icons.
				TypeAlias = { icons.kind.TypeAlias, "LspKindTypeAlias" },
				Parameter = { icons.kind.Parameter, "LspKindParameter" },
				StaticMethod = { icons.kind.StaticMethod, "LspKindStaticMethod" },
				-- Microsoft-specific icons.
				Text = { icons.kind.Text, "LspKindText" },
				Snippet = { icons.kind.Snippet, "LspKindSnippet" },
				Folder = { icons.kind.Folder, "LspKindFolder" },
				Unit = { icons.kind.Unit, "LspKindUnit" },
				Value = { icons.kind.Value, "LspKindValue" },
			},
		},
		-- Scrolling Keymaps: https://nvimdev.github.io/lspsaga/misc/#scrolling-keymaps
		scroll_preview = {
			scroll_down = "<C-d>",
			scroll_up = "<C-u>",
		},
		request_timeout = 3000,
	})

	-- While a hover or diagnostic float is open, Saga maps the scroll keys on the source buffer and
	-- deletes them on close, which loses a buffer-local mapping the keys had before. Remember that
	-- mapping when Saga maps the keys and put it back after Saga deletes its own.
	local util = require("lspsaga.util")
	local scroll = require("lspsaga").config.scroll_preview
	local scroll_keys = { [scroll.scroll_down] = true, [scroll.scroll_up] = true }
	local map_keys, delete_scroll_map = util.map_keys, util.delete_scroll_map
	-- active[buf][lhs]: the buffer's own mapping while Saga's is in place, or false if it had none
	local active = {}
	util.map_keys = function(buf, keys, rhs, modes, opts)
		if vim.tbl_contains(util.as_table(modes or "n"), "n") then
			for _, lhs in ipairs(util.as_table(keys)) do
				if scroll_keys[lhs] and (active[buf] or {})[lhs] == nil then
					local previous = vim.api.nvim_buf_call(buf, function()
						return vim.fn.maparg(lhs, "n", false, true)
					end)
					active[buf] = active[buf] or {}
					active[buf][lhs] = previous.buffer == 1 and previous or false
				end
			end
		end
		return map_keys(buf, keys, rhs, modes, opts)
	end
	util.delete_scroll_map = function(buf)
		local previous = active[buf]
		if not previous then
			-- Already cleaned up: deleting again would remove the restored mapping
			return
		end
		active[buf] = nil
		pcall(delete_scroll_map, buf)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		for _, map in pairs(previous) do
			if map then
				vim.api.nvim_buf_call(buf, function()
					vim.fn.mapset("n", false, map)
				end)
			end
		end
	end
end
