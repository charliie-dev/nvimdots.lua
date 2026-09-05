local set = vim.keymap.set
local helpers = require("keymap.helpers")

-- Plugin: trouble.nvim
set("n", "gt", "<Cmd>Trouble diagnostics toggle<CR>", { silent = true, desc = "lsp: Toggle trouble list" })
set("n", "<leader>lw", "<Cmd>Trouble diagnostics toggle<CR>", { silent = true, desc = "lsp: Workspace diagnostics" })
set(
	"n",
	"<leader>lp",
	"<Cmd>Trouble project_diagnostics toggle<CR>",
	{ silent = true, desc = "lsp: Project diagnostics" }
)
set(
	"n",
	"<leader>ld",
	"<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
	{ silent = true, desc = "lsp: Document diagnostics" }
)

-- Plugin: conform.nvim
set("n", "<A-f>", "<Cmd>FormatToggle<CR>", { silent = true, desc = "formatter: Toggle format on save" })
set("n", "<A-S-f>", "<Cmd>Format<CR>", { silent = true, desc = "formatter: Format buffer manually" })

local M = {}

---@param buf integer
function M.lsp(buf)
	-- LSP navigation
	set("n", "gd", "<Cmd>Lspsaga peek_definition<CR>", { silent = true, buf = buf, desc = "lsp: Peek definition" })
	set("n", "gD", "<Cmd>Lspsaga goto_definition<CR>", { silent = true, buf = buf, desc = "lsp: Goto definition" })
	set("n", "gC", function()
		vim.lsp.buf.declaration()
	end, { buf = buf, desc = "lsp: Goto declaration" })
	set("n", "gT", function()
		vim.lsp.buf.type_definition()
	end, { buf = buf, desc = "lsp: Goto type definition" })
	set("n", "gh", function()
		require("snacks").picker.lsp_references()
	end, { silent = true, buf = buf, desc = "lsp: Show references" })
	set("n", "gm", function()
		require("snacks").picker.lsp_implementations()
	end, { silent = true, buf = buf, desc = "lsp: Show implementations" })
	set("n", "gs", function()
		vim.lsp.buf.signature_help()
	end, { buf = buf, desc = "lsp: Signature help" })
	set(
		"n",
		"go",
		"<Cmd>Trouble symbols toggle win.position=right<CR>",
		{ silent = true, buf = buf, desc = "lsp: Toggle outline" }
	)
	set("n", "g[", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, buf = buf, desc = "lsp: Prev diagnostic" })
	set("n", "g]", "<Cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, buf = buf, desc = "lsp: Next diagnostic" })
	local custom_hover = false
	for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
		if map.lhs == "K" and map.callback ~= vim.lsp.buf.hover then
			custom_hover = true
			break
		end
	end
	if not custom_hover then
		set("n", "K", helpers.lsp_hover_or_dap, { silent = true, buf = buf, desc = "lsp: Show doc / debug: Evaluate" })
	end

	-- LSP actions
	set({ "n", "v" }, "gra", "<Cmd>Lspsaga code_action<CR>", { silent = true, buf = buf, desc = "lsp: Code action" })
	set(
		"n",
		"grn",
		"<Cmd>Lspsaga rename<CR>",
		{ silent = true, nowait = true, buf = buf, desc = "lsp: Rename in file range" }
	)
	set(
		"n",
		"grN",
		"<Cmd>Lspsaga rename ++project<CR>",
		{ silent = true, buf = buf, desc = "lsp: Rename in project range" }
	)
	set("n", "gci", "<Cmd>Lspsaga incoming_calls<CR>", { silent = true, buf = buf, desc = "lsp: Incoming calls" })
	set("n", "gco", "<Cmd>Lspsaga outgoing_calls<CR>", { silent = true, buf = buf, desc = "lsp: Outgoing calls" })

	-- LSP settings
	set("n", "<leader>li", "<Cmd>checkhealth vim.lsp<CR>", { silent = true, buf = buf, desc = "lsp: Info" })
	local restart = vim.fn.exists(":lsp") == 2 and "<Cmd>lsp restart<CR>" or "<Cmd>LspRestart<CR>"
	set("n", "<leader>lr", restart, { silent = true, nowait = true, buf = buf, desc = "lsp: Restart" })
	set(
		"n",
		"<leader>lx",
		"<Cmd>Lspsaga show_line_diagnostics ++unfocus<CR>",
		{ silent = true, buf = buf, desc = "lsp: Line diagnostic" }
	)
	set("n", "<leader>lv", function()
		helpers.toggle_virtuallines()
	end, { silent = true, buf = buf, desc = "lsp: Toggle virtual lines" })
	set("n", "<leader>lh", function()
		helpers.toggle_inlayhint()
	end, { silent = true, buf = buf, desc = "lsp: Toggle inlay hints" })

	-- User overrides
	local ok, user_mappings = pcall(require, "user.keymap.lsp")
	if ok and type(user_mappings.lsp) == "function" then
		require("modules.utils.keymap").replace(user_mappings.lsp(buf))
	end
end

return M
