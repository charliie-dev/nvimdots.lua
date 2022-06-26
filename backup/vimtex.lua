local status, _ = pcall(require, "vimtex")
if not status then
	return
end

vim.g.tex_flavor = "latexmk --shell-escape"
vim.g.vimtex_view_general_viewer = "xdg-open"
vim.g.vimtex_view_method = "xdg-open"
vim.g.vimtex_view_general_viewer = "okular"
vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
vim.g.vimtex_view_general_options_latexmk = "--unique"
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_quickfix_autoclose_after_keystrokes = 3
vim.g.vimtex_complete_enabled = 1
vim.g.vimtex_compiler_progname = "nvr"
vim.g.vimtex_compiler_engine = "latexmk"
-- vim.g.vimtex_compiler_engine = 'xelatex'
vim.g.vimtex_view_general_automatic = 0
