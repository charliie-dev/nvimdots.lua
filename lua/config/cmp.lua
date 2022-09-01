local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
	return
end

-- local cmp_dap_status, cmp_dap = pcall(require, "cmp_dap")
-- if not cmp_dap_status then
--   return
-- end

local snip_status, luasnip = pcall(require, "luasnip")
if not snip_status then
	return
end

local buffer_fts = {
  "markdown",
  "toml",
  "yaml",
  "json",
}

local function contains(t, value)
  for _, v in pairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

local compare = require "cmp.config.compare"

require("luasnip/loaders/from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()

-- local check_backspace = function()
-- 	local col = vim.fn.col(".") - 1
-- 	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
-- end

local check_backspace = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local icons = require("icons")
local kind_icons = icons.kind

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

vim.cmd([[highlight! default link CmpItemKind CmpItemMenuDefault]])

vim.g.cmp_active = true

cmp.setup({
  enabled = function()
    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
    if buftype == "prompt" then
      return false
    end
    return vim.g.cmp_active
  end,
  preselect = cmp.PreselectMode.None,
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-c>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm { select = false },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.jumpable(1) then
        luasnip.jump(1)
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif check_backspace() then
        -- cmp.complete()
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  }),
	sources = cmp.config.sources({
		{ name = "copilot",
      max_item_count = 3,
      trigger_characters = {
        {
          ".",
          ":",
          "(",
          "'",
          '"',
          "[",
          ",",
          "#",
          "*",
          "@",
          "|",
          "=",
          "-",
          "{",
          "/",
          "\\",
          "+",
          "?",
          " ",
          -- "\t",
          -- "\n",
        },
      },
    },
		{ name = "nvim_lsp",
      filter = function(entry, ctx)
        local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
        if kind == "Snippet" and ctx.prev_context.filetype == "java" then
          return true
        end

        if kind == "Text" then
          return true
        end
      end,
    },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "path" },
  	{ name = 'buffer',
      filter = function(entry, ctx)
        if not contains(buffer_fts, ctx.prev_context.filetype) then
          return true
        end
      end,
    },
		-- { name = 'spell'},
	}),
	formatting = {
		fields = { "abbr", "kind", "menu" },
		format = function(entry, vim_item)
			if entry.source.name == "copilot" then
				vim_item.kind = string.format("%s Copilot", kind_icons.Copilot)
				vim_item.menu = "[Copilot]"
				vim_item.kind_hl_group = "CmpItemKindCopilot"
				return vim_item
			end
			-- Kind icons
			vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
			-- vim_item.kind = lspkind.presets.default[vim_item.kind]
			-- NOTE: order matters
			vim_item.menu = ({
				path = "[Path]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[api]",
				buffer = "[Buf]",
				dap = "[DAP]",
				luasnip = "[Snip]",
				spell = "[Lang]",
			})[entry.source.name]
			return vim_item
		end,
	},
  sorting = {
    priority_weight = 2,
    comparators = {
      -- require("copilot_cmp.comparators").prioritize,
      -- require("copilot_cmp.comparators").score,
      compare.offset,
      compare.exact,
      -- compare.scopes,
      compare.score,
      compare.recently_used,
      compare.locality,
      -- compare.kind,
      compare.sort_text,
      compare.length,
      compare.order,
      -- require("copilot_cmp.comparators").prioritize,
      -- require("copilot_cmp.comparators").score,
    },
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
	window = {
		-- documentation = "native",
		documentation = {
			border = "rounded",
			-- winhighlight = "Normal:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
      winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
		},
		completion = {
			border = "rounded",
			-- winhighlight = "Normal:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
      winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
		},
	},
	experimental = {
		ghost_text = true,
	},
})

-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' },
--   }
-- })
