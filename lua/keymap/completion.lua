local set = vim.keymap.set
local helpers = require("keymap.helpers")

-- Formatter keymaps
set("n", "<A-f>", "<Cmd>FormatToggle<CR>", { silent = true, desc = "formatter: Toggle format on save" })
set("n", "<A-S-f>", "<Cmd>Format<CR>", { silent = true, desc = "formatter: Format buffer manually" })

--- The following code allows this file to be exported ---
---    for use with LSP lazy-loaded keymap bindings    ---

local M = {}

---@param buf integer
function M.lsp(buf)
	-- LSP-related keymaps, ONLY effective in buffers with LSP(s) attached
	set("n", "<leader>li", "<Cmd>LspInfo<CR>", { silent = true, buffer = buf, desc = "lsp: Info" })
	set("n", "<leader>lr", "<Cmd>LspRestart<CR>", { silent = true, nowait = true, buffer = buf, desc = "lsp: Restart" })
	set(
		"n",
		"go",
		"<Cmd>Trouble symbols toggle win.position=right<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Toggle outline" }
	)
	set("n", "gto", function()
		if require("core.settings").search_backend == "fzf" then
			local prompt_position = require("telescope.config").values.layout_config.horizontal.prompt_position
			require("fzf-lua").lsp_document_symbols({
				fzf_opts = { ["--layout"] = prompt_position == "top" and "reverse" or "default" },
			})
		else
			require("telescope.builtin").lsp_document_symbols()
		end
	end, { silent = true, buffer = buf, desc = "lsp: Toggle outline in Telescope" })
	set(
		"n",
		"g[",
		"<Cmd>Lspsaga diagnostic_jump_prev<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Prev diagnostic" }
	)
	set(
		"n",
		"g]",
		"<Cmd>Lspsaga diagnostic_jump_next<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Next diagnostic" }
	)
	set(
		"n",
		"<leader>lx",
		"<Cmd>Lspsaga show_line_diagnostics ++unfocus<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Line diagnostic" }
	)
	set("n", "gs", function()
		vim.lsp.buf.signature_help()
	end, { buffer = buf, desc = "lsp: Signature help" })
	set("n", "gDC", function()
		vim.lsp.buf.declaration()
	end, { buffer = buf, desc = "lsp: Goto declaration" })
	set("n", "gI", function()
		vim.lsp.buf.implementation()
	end, { buffer = buf, desc = "lsp: Goto implementation" })
	set("n", "gT", function()
		vim.lsp.buf.type_definition()
	end, { buffer = buf, desc = "lsp: Goto type_definition" })
	set(
		"n",
		"grn",
		"<Cmd>Lspsaga rename<CR>",
		{ silent = true, nowait = true, buffer = buf, desc = "lsp: Rename in file range" }
	)
	set(
		"n",
		"grN",
		"<Cmd>Lspsaga rename ++project<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Rename in project range" }
	)
	set("n", "K", "<Cmd>Lspsaga hover_doc<CR>", { silent = true, buffer = buf, desc = "lsp: Show doc" })
	set({ "n", "v" }, "gra", function()
		require("tiny-code-action").code_action({})
	end, { silent = true, buffer = buf, desc = "lsp: Code action for cursor" })
	set("n", "gd", "<Cmd>Glance definitions<CR>", { silent = true, buffer = buf, desc = "lsp: Preview definition" })
	set("n", "gD", "<Cmd>Lspsaga goto_definition<CR>", { silent = true, buffer = buf, desc = "lsp: Goto definition" })
	set("n", "gh", "<Cmd>Glance references<CR>", { silent = true, buffer = buf, desc = "lsp: Show reference" })
	set(
		"n",
		"gci",
		"<Cmd>Lspsaga incoming_calls<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Show incoming calls" }
	)
	set(
		"n",
		"gco",
		"<Cmd>Lspsaga outgoing_calls<CR>",
		{ silent = true, buffer = buf, desc = "lsp: Show outgoing calls" }
	)
	set("n", "<leader>lv", function()
		helpers.toggle_virtuallines()
	end, { silent = true, buffer = buf, desc = "lsp: Toggle virtual lines" })
	set("n", "<leader>lh", function()
		helpers.toggle_inlayhint()
	end, { silent = true, buffer = buf, desc = "lsp: Toggle inlay hints" })

	local ok, user_mappings = pcall(require, "user.keymap.completion")
	if ok and type(user_mappings.lsp) == "function" then
		require("modules.utils.keymap").replace(user_mappings.lsp(buf))
	end
end

return M
