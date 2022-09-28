local status, comment = pcall(require, "Comment")
if not status then
	return
end

local lspinlay_status, _ = pcall(require, "lsp-inlayhints")
if not lspinlay_status then
	return
end

comment.setup({
	---Add a space b/w comment and the line
	padding = true,
	---Whether the cursor should stay at its position
	sticky = true,
	---Lines to be ignored while (un)comment
	ignore = function()
    -- Only ignore empty lines for lua files
    if vim.bo.filetype == 'lua' then
      return '^$'
    end
  end,
	---LHS of toggle mappings in NORMAL mode
	toggler = {
		---Line-comment toggle keymap
		line = "gcc",
		---Block-comment toggle keymap
		block = "gbc",
	},
	---LHS of operator-pending mappings in NORMAL and VISUAL mode
	opleader = {
		---Line-comment keymap
		line = "gc",
		---Block-comment keymap
		block = "gb",
	},
	---LHS of extra mappings
	extra = {
		---Add comment on the line above
		above = "gcO",
		---Add comment on the line below
		below = "gco",
		---Add comment at the end of line
		eol = "gcA",
	},
	---Enable keybindings
	---NOTE: If given `false` then the plugin won't create any mappings
	mappings = {
		---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
		basic = true,
		---Extra mapping; `gco`, `gcO`, `gcA`
		extra = true,
		---Extended mapping; `g>` `g<` `g>[count]{motion}` `g<[count]{motion}`
		extended = false,
	},
	pre_hook = function(ctx)
		-- For inlay hints
		local line_start = (ctx.srow or ctx.range.srow) - 1
		local line_end = ctx.erow or ctx.range.erow
		require("lsp-inlayhints.core").clear(0, line_start, line_end)

		require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()

		if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
			local U = require("Comment.utils")

			-- Determine whether to use linewise or blockwise commentstring
			local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

			-- Determine the location where to calculate commentstring from
			local location = nil
			if ctx.ctype == U.ctype.blockwise then
				location = require("ts_context_commentstring.utils").get_cursor_location()
			elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
				location = require("ts_context_commentstring.utils").get_visual_start_location()
			end

			return require("ts_context_commentstring.internal").calculate_commentstring({
				key = type,
				location = location,
			})
		end
	end,
})
