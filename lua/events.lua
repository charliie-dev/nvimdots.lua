local vim = vim
local autocmd = {}

function autocmd.nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		vim.api.nvim_command("augroup " .. group_name)
		vim.api.nvim_command("autocmd!")
		for _, def in ipairs(definition) do
			local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
			vim.api.nvim_command(command)
		end
		vim.api.nvim_command("augroup END")
	end
end

function autocmd.load_autocmds()
	local definitions = {
		packer = {},
		bufs = {
			-- Reload vim config automatically
			{
				"BufWritePost",
				[[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]],
			},
			-- Reload Vim script automatically if setlocal autoread
			{
				"BufWritePost,FileWritePost",
				"*.vim",
				[[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]],
			},
			{ "BufWritePre", "/tmp/*", "setlocal noundofile" },
			{ "BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile" },
			{ "BufWritePre", "MERGE_MSG", "setlocal noundofile" },
			{ "BufWritePre", "*.tmp", "setlocal noundofile" },
			{ "BufWritePre", "*.bak", "setlocal noundofile" },
			-- Auto change directory
			{ "BufEnter", "*", "silent! lcd %:p:h" },
      -- Remove trailing whitespace when save
      { "BufWritePre", "*", [[%s/\s\+$//e]] },
      {
        "BufRead,BufNewFile",
        "md,mdx",
        "filetype=markdown",
      },
      -- <F5> to execute
      {
        "BufRead,BufNewFile",
        "*.py",
        [[if executable('python3') | noremap <F5> :% w !python<CR> | else | echo "No python3 found"]],
      },
      {
        "BufRead,BufNewFile",
        "*.js",
        [[if executable('node') | noremap <F5> :% w !node<CR> | else | echo "No node found"]],
      },
		},
		wins = {
			-- Highlight current line only on focused window
			{
				"WinEnter,BufEnter,InsertLeave",
				"*",
				[[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
			},
			{
				"WinLeave,BufLeave,InsertEnter",
				"*",
				[[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]],
			},
			-- Force write shada on leaving nvim
			{
				"VimLeave",
				"*",
				[[if has('nvim') | wshada! | else | wviminfo! | endif]],
			},
			-- Check if file changed when its window is focus, more eager than 'autoread'
			{ "FocusGained", "* checktime" },
			-- Equalize window dimensions when resizing vim window
			{ "VimResized", "*", [[tabdo wincmd =]] },
		},
		ft = {
			{ "FileType", "alpha", "set showtabline=0" },
			{ "FileType", "markdown", "set wrap" },
			{ "FileType", "make", "set noexpandtab shiftwidth=8 softtabstop=0" },
			{ "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
			{
				"FileType",
				"*",
				[[setlocal formatoptions-=cro]],
			},
			{
				"FileType",
				"c,cpp,py,ipynb",
        [[setlocal tabstop=4 shiftwidth=4 expandtab]],
			},
      {
				"FileType",
				"html,yaml,toml,lua,vim",
        [[setlocal tabstop=2 shiftwidth=2 expandtab]],
			},


		},
		yank = {
			{
				"TextYankPost",
				"*",
				[[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
			},
      -- -- Copy to system clipboard on Windows
      -- {
      --   "TextYankPost",
      --   "*",
      --   [[if v:event.operator ==# 'y' | call system('/mnt/c/Windows/System32/clip.exe', @0) | endif]],
      -- },
		},
	}

	autocmd.nvim_create_augroups(definitions)
end

autocmd.load_autocmds()

vim.cmd [[
" Open md files with toc if there's one.
au BufRead *.md :call OpenMd()

function! OpenMd()
  setlocal foldlevel=1
  " SymbolsOutline
endfunction
]]
