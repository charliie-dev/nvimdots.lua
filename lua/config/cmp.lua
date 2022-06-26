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

require("luasnip/loaders/from_vscode").lazy_load()

local icons = require("icons")
local kind_icons = icons.kind

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

vim.cmd([[highlight! default link CmpItemKind CmpItemMenuDefault]])

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		-- ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-e>"] = cmp.mapping({
			-- i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expandable() then
				luasnip.expand()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif check_backspace() then
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
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
	sources = cmp.config.sources({
		-- { name = 'buffer'},
		{ name = "copilot" },
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "path" },
		-- { name = 'spell'},
	}),
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			if entry.source.name == "copilot" then
				vim_item.kind = string.format("%s", kind_icons.Copilot)
				vim_item.menu = "[Copilot]"
				vim_item.kind_hl_group = "CmpItemKindCopilot"
				return vim_item
			end
			-- Kind icons
			vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
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
