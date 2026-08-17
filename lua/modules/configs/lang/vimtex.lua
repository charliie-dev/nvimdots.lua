return function()
	vim.g.vimtex_enabled = true
	vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
	vim.g.vimtex_quickfix_mode = false
	vim.g.vimtex_quickfix_autoclose_after_keystrokes = 3
	vim.g.vimtex_complete_enabled = true
	vim.g.vimtex_compiler_method = "latexmk"
	vim.g.vimtex_view_automatic = false

	local latexmk_engines = vim.g.vimtex_compiler_latexmk_engines or {}
	latexmk_engines["_"] = "-xelatex"
	vim.g.vimtex_compiler_latexmk_engines = latexmk_engines

	local latexmk = vim.g.vimtex_compiler_latexmk or {}
	latexmk.options = {
		"-verbose",
		"-file-line-error",
		"-synctex=1",
		"-interaction=nonstopmode",
		"-shell-escape",
	}
	vim.g.vimtex_compiler_latexmk = latexmk

	local global = require("core.global")

	if global.is_wsl then
		vim.g.vimtex_view_method = "sioyek"
		-- NOTE: Remember to `ln -s /path/in/windows/sioyek.exe /usr/local/bin/sioyek.exe`
		vim.g.vimtex_view_sioyek_exe = "sioyek.exe"
		vim.g.vimtex_callback_progpath = "wsl nvim"
	end
end
