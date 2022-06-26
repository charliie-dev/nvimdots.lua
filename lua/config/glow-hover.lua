local status, glow_hover = pcall(require, "glow-hover")
if not status then
	return
end

glow_hover.setup({
	max_width = 50,
	padding = 10,
	border = "shadow",
	glow_path = "glow",
})

vim.cmd([[highlight! HoverFloatBorder ctermbg=None ctermfg=255]])
