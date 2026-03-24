local autocmd = {}

-- Autoclose some filetype with <q>
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"snacks_notif",
		"nofile",
		"terminal",
		"prompt",
		"snacks_terminal",
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

			-- Remove Neovim 0.11 default LSP keymaps that conflict with our setup
			-- grn/gra: we override with Lspsaga rename / tiny-code-action
			-- <C-s> (insert): we use it for saving files
			pcall(vim.keymap.del, "n", "grn", { buffer = event.buf })
			pcall(vim.keymap.del, { "n", "v" }, "gra", { buffer = event.buf })
			pcall(vim.keymap.del, { "i", "s" }, "<C-s>", { buffer = event.buf })

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

	local no_undofile = function(event)
		vim.bo[event.buf].undofile = false
	end

	local ignored_fts = { dashboard = true, clap_ = true }
	local function is_ignored_ft()
		local ft = vim.bo.filetype
		for ft_pattern in pairs(ignored_fts) do
			if ft:find(ft_pattern) then
				return true
			end
		end
		return false
	end

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
				function(event)
					if vim.bo[event.buf].autoread then
						vim.cmd.source(event.match)
						vim.notify("source " .. vim.api.nvim_buf_get_name(event.buf))
					end
				end,
			},
			{ "BufWritePre", "*~", no_undofile },
			{ "BufWritePre", "/tmp/*", no_undofile },
			{ "BufWritePre", "*.tmp", no_undofile },
			{ "BufWritePre", "*.bak", no_undofile },
			{ "BufWritePre", "MERGE_MSG", no_undofile },
			{ "BufWritePre", "description", no_undofile },
			{ "BufWritePre", "COMMIT_EDITMSG", no_undofile },
		},
		wins = {
			-- Highlight current line only in focused window
			{
				{ "WinEnter", "BufEnter", "InsertLeave" },
				"*",
				function()
					if not vim.wo.cursorline and not is_ignored_ft() and not vim.wo.previewwindow then
						vim.wo.cursorline = true
					end
				end,
			},
			{
				{ "WinLeave", "BufLeave", "InsertEnter" },
				"*",
				function()
					if vim.wo.cursorline and not is_ignored_ft() and not vim.wo.previewwindow then
						vim.wo.cursorline = false
					end
				end,
			},
			-- Attempt to write shada when leaving nvim
			{
				"VimLeave",
				"*",
				function()
					vim.cmd.wshada()
				end,
			},
			-- Check if a file has changed when its window is in focus, being more proactive than 'autoread'
			{
				"FocusGained",
				"*",
				function()
					vim.cmd.checktime()
				end,
			},
			-- Maintain uniform window dimensions when resizing Vim windows
			{
				"VimResized",
				"*",
				function()
					vim.cmd("tabdo wincmd =")
				end,
			},
		},
		ft = {
			{
				"FileType",
				"*",
				function(event)
					vim.bo[event.buf].formatoptions = vim.bo[event.buf].formatoptions:gsub("[cro]", "")
				end,
			},
			{
				"FileType",
				"snacks_dashboard",
				function()
					vim.wo.showtabline = 0
				end,
			},
			{
				"FileType",
				"dap-repl",
				function()
					require("dap.ext.autocompl").attach()
				end,
			},
			{
				"FileType",
				{ "c", "cpp" },
				function(event)
					vim.keymap.set(
						"n",
						"<leader>h",
						"<Cmd>ClangdSwitchSourceHeader<CR>",
						{ buffer = event.buf, silent = true }
					)
				end,
			},
		},
		yank = {
			{
				"TextYankPost",
				"*",
				function()
					vim.hl.on_yank({ higroup = "IncSearch", timeout = 300 })
				end,
			},
		},
	}

	autocmd.nvim_create_augroups(require("modules.utils").extend_config(definitions, "user.event"))
end

autocmd.load_autocmds()
