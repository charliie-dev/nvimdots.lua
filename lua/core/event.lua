local autocmd = {}

-- Autoclose NvimTree
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeAutoClose", { clear = true }),
	pattern = "NvimTree_*",
	callback = function()
		local layout = vim.fn.winlayout()
		if
			layout[1] == "leaf"
			and vim.bo[vim.api.nvim_win_get_buf(layout[2])].filetype == "NvimTree"
			and layout[3] == nil
		then
			vim.cmd({ cmd = "quit", mods = { confirm = true } })
		end
	end,
})

-- Autoclose some filetype with <q>
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"nofile",
		"terminal",
		"prompt",
		"toggleterm",
		"copilot",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Hold off on configuring anything related to the LSP until LspAttach
local mapping = require("keymap.completion")
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspKeymapLoader", { clear = true }),
	callback = function(event)
		if not _G._debugging then
			-- LSP Keymaps
			mapping.lsp(event.buf)

			-- LSP Inlay Hints
			local inlayhints_enabled = require("core.settings").lsp_inlayhints
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities.inlayHintProvider ~= nil then
				vim.lsp.inlay_hint.enable(inlayhints_enabled == true, { bufnr = event.buf })
			end
		end
	end,
})

-- Create custom filetype for gitlab_ci_ls
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.gitlab-ci*.{yml,yaml}",
	callback = function()
		vim.bo.filetype = "yaml.gitlab"
	end,
})

-- Start treesitter for installed parsers
vim.api.nvim_create_autocmd("FileType", {
	pattern = require("core.settings").treesitter_deps,
	callback = function(args)
		vim.treesitter.start(args.buf)
	end,
})

-- Autojump to last edit
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

--- Process autocmd definitions using nvim_create_autocmd.
--- Each definition entry: { event(s), pattern, command_or_callback }
---   - event(s): string (comma-separated) or table of strings
---   - pattern: string or table of strings
---   - command_or_callback: string (vimscript) or function (lua callback)
---     Prefix command with "nested " to set nested = true.
function autocmd.nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		local group = vim.api.nvim_create_augroup("_" .. group_name, { clear = true })
		for _, def in ipairs(definition) do
			local events = type(def[1]) == "table" and def[1] or vim.split(def[1], ",", { plain = true })
			local pattern = def[2]
			local action = def[3]

			local opts = { group = group, pattern = pattern }

			if type(action) == "function" then
				opts.callback = action
			elseif type(action) == "string" then
				if action:match("^nested ") then
					opts.nested = true
					action = action:sub(8)
				end
				opts.command = action
			end

			vim.api.nvim_create_autocmd(events, opts)
		end
	end
end

function autocmd.load_autocmds()
	local vim_path = require("core.global").vim_path

	local definitions = {
		bufs = {
			-- Reload vim config automatically
			{
				"BufWritePost",
				{ vim_path .. "/*.vim", vim_path .. "/*.yaml", vim_path .. "/vimrc" },
				"nested source $MYVIMRC | redraw",
			},
			-- Reload Vim script automatically if setlocal autoread
			{
				{ "BufWritePost", "FileWritePost" },
				"*.vim",
				[[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]],
			},
			{ "BufWritePre", "*~", "setlocal noundofile" },
			{ "BufWritePre", "/tmp/*", "setlocal noundofile" },
			{ "BufWritePre", "*.tmp", "setlocal noundofile" },
			{ "BufWritePre", "*.bak", "setlocal noundofile" },
			{ "BufWritePre", "MERGE_MSG", "setlocal noundofile" },
			{ "BufWritePre", "description", "setlocal noundofile" },
			{ "BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile" },
		},
		wins = {
			-- Highlight current line only in focused window
			{
				{ "WinEnter", "BufEnter", "InsertLeave" },
				"*",
				[[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
			},
			{
				{ "WinLeave", "BufLeave", "InsertEnter" },
				"*",
				[[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]],
			},
			-- Attempt to write shada when leaving nvim
			{ "VimLeave", "*", "wshada" },
			-- Check if a file has changed when its window is in focus, being more proactive than 'autoread'
			{ "FocusGained", "*", "checktime" },
			-- Maintain uniform window dimensions when resizing Vim windows
			{ "VimResized", "*", [[tabdo wincmd =]] },
		},
		ft = {
			{ "FileType", "*", "setlocal formatoptions-=cro" },
			{ "FileType", "alpha", "setlocal showtabline=0" },
			{ "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
			{
				"FileType",
				{ "c", "cpp" },
				"nnoremap <silent> <buffer> <leader>h <Cmd>ClangdSwitchSourceHeader<CR>",
			},
		},
		yank = {
			{
				"TextYankPost",
				"*",
				[[silent! lua vim.hl.on_yank({ higroup = "IncSearch", timeout = 300 })]],
			},
		},
	}

	autocmd.nvim_create_augroups(require("modules.utils").extend_config(definitions, "user.event"))
end

autocmd.load_autocmds()
