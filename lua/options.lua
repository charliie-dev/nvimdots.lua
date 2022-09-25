local options = {
	-- foldmethod = "marker",
	autoindent = true,
	autoread = true,
	backspace = { "start", "eol", "indent" },
	backup = false,
	backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim",
	breakindent = true,
	cindent = true,
	cmdheight = 1,
	colorcolumn = "80",
	compatible = false,
	completeopt = { "menu", "menuone", "noselect" }, -- required by nvim-cmp
	cursorline = true,
	encoding = "utf-8",
	expandtab = true,
	foldexpr = "nvim_treesitter#foldexpr()",
	foldlevel = 3,
	foldmethod = "expr",
	hlsearch = false,
	ignorecase = true,
	inccommand = "split",
	incsearch = true,
	laststatus = 3,
	lazyredraw = true,
	mouse = "nv",
	number = true,
	numberwidth = 4,
	pumheight = 10,
	ruler = false,
	scrolloff = 10,
	shell = "bash",
	shiftround = true,
	shiftwidth = 2,
	showcmd = true,
	showmatch = true,
	showmode = true,
	sidescrolloff = 10,
	signcolumn = "yes",
	smartcase = true,
	smartindent = true,
	smarttab = true,
	softtabstop = 2,
	spell = true,
	spelllang = { "en_us" },
	splitbelow = true,
	splitright = true,
	swapfile = false,
	tabstop = 2,
	timeoutlen = 500,
	title = true,
	ttimeoutlen = -1,
	undofile = true,
	updatetime = 300,
	whichwrap = "<,>,[,]",
	wildignore = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**",
	wildignorecase = true,
	wildmenu = true,
	wildmode = "longest:full,full",
	wildoptions = "pum",
	wrap = false,
	writebackup = false,
}
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- disable_distribution_plugins
vim.g.did_load_fzf = 1
vim.g.did_load_gtags = 1
vim.g.did_load_gzip = 1
vim.g.did_load_tar = 1
vim.g.did_load_tarPlugin = 1
vim.g.did_load_zip = 1
vim.g.did_load_zipPlugin = 1
vim.g.did_load_getscript = 1
vim.g.did_load_getscriptPlugin = 1
vim.g.did_load_vimball = 1
vim.g.did_load_vimballPlugin = 1
vim.g.did_load_matchit = 1
vim.g.did_load_matchparen = 1
vim.g.did_load_2html_plugin = 1
vim.g.did_load_logiPat = 1
vim.g.did_load_rrhelper = 1
vim.g.did_load_netrw = 1
vim.g.did_load_netrwPlugin = 1
vim.g.did_load_netrwSettings = 1
vim.g.did_load_netrwFileHandlers = 1

-- use filetype.lua instead and disable filetype.vim
-- vim.g.do_filetype_lua = 1
-- vim.g.did_load_filetypes = 1

local function isempty(s)
	return s == nil or s == ""
end

-- faster startup
vim.g.python_host_skip_check = 1
if not isempty(vim.env.CONDA_PREFIX) then
	vim.g.python3_host_prog = vim.env.CONDA_PREFIX .. "/bin/python"
-- print(vim.g.python3_host_prog)
else
	vim.g.python3_host_prog = "/usr/bin/python3"
end
-- also faster startup, since I don't need to load indent/ & ftplugin
-- vim.cmd [[filetype plugin indent on]]

-- custom perl path
vim.g.perl_host_prog = vim.env.HOME .. "/tools/perl/bin/perl"

-- custom ruby path
vim.g.ruby_host_prog = vim.env.HOME .. "/tools/ruby/bin/ruby"

-- Access system clipboard
vim.cmd([[set clipboard=unnamedplus]])
vim.cmd([[set t_BE= ]])

vim.cmd([[syntax enable]])

-- Add suffixes
vim.cmd([[set suffixesadd+=.js,.es,.jsx,.json,.css,.less,.sass,.styl,.py,.ipynd,.md,.lua,.vim]])
