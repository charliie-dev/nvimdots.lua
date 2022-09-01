local status, npairs = pcall(require, "nvim-autopairs")
if not status then
	return
end

npairs.setup({
	disable_filetype = { "TelescopePrompt", "spectre_panel" },
	enable_check_bracket_line = true,
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'", "<" },
		-- pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
		end_key = "$",
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		check_comma = true,
		highlight = "PmenuSel",
		-- highlight = "Search",
		highlight_grey = "LineNr",
		-- highlight_grey = "Comment",
	},
	check_ts = true,
	ts_config = {
		lua = { "string", "source" }, -- it will not add a pair on that treesitter node
		javascript = { "string", "template_string" },
	},
  map_cr = false,  -- set autopairs completion with cmp
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local handlers = require("nvim-autopairs.completion.handlers")
local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
	return
end

cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done({
    filetypes = {
      -- "*" is an alias to all filetypes
      ["*"] = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method,
          },
          handler = handlers["*"],
        },
      },
      -- Disable for tex
      tex = false,
    },
  })
)
