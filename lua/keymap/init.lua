local keymap = vim.keymap.set
local opts = { noremap = true, silent = true, nowait = true }

-- Plugin keymaps

--- DAP
keymap("n", "<F6>", "<cmd>lua require('dap').continue()<cr>", opts) -- Launching debug sessions and resuming execution
keymap("n", "<leader>dr", "<cmd>lua require('dap').continue()<cr>", opts)
keymap("n", "<leader>dd", "<cmd>lua require('dap').terminate()<cr>", opts)
keymap("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", opts)
keymap("n", "<leader>dB", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", opts)
keymap("n", "<leader>dbl", "<cmd>lua require('dap').list_breakpoints()<cr>", opts)
keymap("n", "<leader>drc", "<cmd>lua require('dap').run_to_cursor()<cr>", opts)
keymap("n", "<leader>drl", "<cmd>lua require('dap').run_last()<cr>", opts)
keymap("n", "<F9>", "<cmd>lua require('dap').step_over()<cr>", opts)
keymap("n", "<leader>dv", "<cmd>lua require('dap').step_over()<cr>", opts)
keymap("n", "<F10>", "<cmd>lua require('dap').step_into()<cr>", opts)
keymap("n", "<leader>di", "<cmd>lua require('dap').step_into()<cr>", opts)
keymap("n", "<F11>", "<cmd>lua require('dap').step_out()<cr>", opts)
keymap("n", "<leader>do", "<cmd>lua require('dap').step_out()<cr>", opts)
keymap("n", "<leader>dl", "<cmd>lua require('dap').repl.open()<cr>", opts)

--- Telescope
keymap("n", "<leader>fp", "<cmd>lua require('telescope').extensions.project.project{ display_type = 'full' }<cr>", opts)
keymap("n", "<leader>fr", "<cmd>lua require('telescope').extensions.frecency.frecency{}<cr>", opts)
keymap("n", "<leader>fw", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args{}<cr>", opts)
keymap("n", "<leader>fe", "<cmd>Telescope oldfiles<cr>", opts)
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", opts)
keymap("n", "<leader>fn", "<cmd>enew<cr>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope git_files<cr>", opts)
keymap("n", "<leader>fz", "<cmd>Telescope zoxide list<cr>", opts)

--- bufdelete.nvim
keymap("n", "<F4>", "<cmd>Bwipeout<cr>", opts)

--- BufferLine
keymap("n", "<tab>", "<cmd>BufferLineCycleNext<cr>", opts)
keymap("n", "<S-tab>", "<cmd>BufferLineCyclePrev<cr>", opts)

--- Lsp mapping work when event:InsertEnter & event:LspStart
keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
keymap("n", "<leader>lr", "<cmd>LspRestart<cr>", opts)
keymap("n", "go", "<cmd>Lspsaga outline<cr>", opts)
keymap("n", "g[", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
keymap("n", "g]", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
keymap("n", "gr", "<cmd>Lspsaga rename<cr>", opts)
keymap("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
keymap({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<cr>", opts)
keymap("n", "gd", "<cmd>Lspsaga peek_definition<cr>", opts)
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<cr>", opts)
keymap("n", "gS", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
keymap("n", "gD", "<cmd>lua vim.lsp.buf.definition()<cr>", opts) -- go to definition
keymap("n", "gDC", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
keymap("n", "gI", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
keymap("n", "gT", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
-- keymap("n", "gDL", "<cmd>lua vim.diagnostic.setloclist()<cr>", opts) -- use trouble.nvim instead
-- keymap("n", "gQL", "<cmd>lua vim.diagnostic.setqflist()<cr>", opts) -- use trouble.nvim instead

--- Toggleterm
-- "Ctrl+ \" to open toggleterm
keymap("n", "<leader>lg", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", opts)

--- Tmux.nvim
-- Move from Nvim windows to tmux panes
keymap("n", "<C-j>", '<cmd>lua require("tmux").move_bottom()<cr>', opts)
keymap("n", "<C-k>", '<cmd>lua require("tmux").move_top()<cr>', opts)
keymap("n", "<C-h>", '<cmd>lua require("tmux").move_left()<cr>', opts)
keymap("n", "<C-l>", '<cmd>lua require("tmux").move_right()<cr>', opts)
-- Neovim windos/Tmux panes resize
keymap("n", "<M-j>", '<cmd>lua require("tmux").resize_bottom()<cr>', opts)
keymap("n", "<M-k>", '<cmd>lua require("tmux").resize_top()<cr>', opts)
keymap("n", "<M-h>", '<cmd>lua require("tmux").resize_left()<cr>', opts)
keymap("n", "<M-l>", '<cmd>lua require("tmux").resize_right()<cr>', opts)

--- Trouble.nvim
keymap("n", "<leader>tt", "<cmd>TroubleToggle<cr>", opts)
keymap("n", "<leader>tr", "<cmd>TroubleToggle lsp_references<cr>", opts)
keymap("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>", opts)
keymap("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)
keymap("n", "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", opts)
keymap("n", "<leader>tl", "<cmd>TroubleToggle loclist<cr>", opts)

--- NeoTree
keymap("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", opts)
keymap("n", "<leader>nf", "<cmd>NvimTreeFindFile<cr>", opts)
keymap("n", "<leader>nr", "<cmd>NvimTreeRefresh<cr>", opts)

--- Undotree
keymap("n", "<leader>u", "<cmd>UndotreeToggle<cr>", opts)

--- accelerate-jk
keymap("n", "j", "<Plug>(accelerated_jk_gj)", {})
keymap("n", "k", "<Plug>(accelerated_jk_gk)", {})

--- MarkdownPreview
keymap("n", "<F12>", "<cmd>MarkdownPreviewToggle<cr>", opts)

--- SnipRun
keymap("n", "<leader>r", "<cmd>SnipRun<cr>", opts)

--- Diffview
keymap("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", opts)
keymap("n", "<leader><leader>dv", "<cmd>DiffviewClose<cr>", opts)

--- Legendary
keymap("n", "<C-p>", "<cmd>Legendary<cr>", opts)

--- hlslens
keymap("n", "n", [[<cmd>execute('normal! ' . v:count1 . 'n')<cr><cmd>lua require('hlslens').start()<cr>]], opts)
keymap("n", "N", [[<cmd>execute('normal! ' . v:count1 . 'N')<cr><cmd>lua require('hlslens').start()<cr>]], opts)
keymap("n", "*", [[*<cmd>lua require('hlslens').start()<cr>]], opts)
keymap("n", "#", [[#<cmd>lua require('hlslens').start()<cr>]], opts)
keymap("n", "<esc>", "<cmd>noh<cr>", opts)

--- Packer
keymap("n", "<leader>pc", "<cmd>PackerCompile<cr>", opts)
keymap("n", "<leader>ps", "<cmd>PackerSync<cr>", opts)
keymap("n", "<leader>pt", "<cmd>PackerStatus<cr>", opts)

--- comment-frame
-- "<leader>cf" to use comment-frame

--- gomove
keymap({ "n", "x" }, "<leader><S-h>", "<Plug>GoNSMLeft", {})
keymap({ "n", "x" }, "<leader><S-j>", "<Plug>GoNSMDown", {})
keymap({ "n", "x" }, "<leader><S-k>", "<Plug>GoNSMUp", {})
keymap({ "n", "x" }, "<leader><S-l>", "<Plug>GoNSMRight", {})

--- ssr.nvim, structural search and replace
keymap({ "n", "x" }, "<leader>sr", function()
	require("ssr").open()
end)

--- nvim-surround
-- keymaps = {
--     insert = "<C-g>z",
--     insert_line = "<C-g>Z",
--     normal = "gz",
--     normal_cur = "gZ",
--     normal_line = "gzz",
--     normal_cur_line = "gZZ",
--     visual = "gz",
--     visual_line = "gZ",
--     delete = "gzd",
--     change = "gzc",
-- },

--- treesj
-- "<Space>m" to toggle split/join

--- autolist.nvim
-- <C-t> to indent.
-- <C-d> to dedent.
-- <C-r> to change from `ol`->`ul`/`ul`->`ol`
-- <CR> on an empty list marker to end the list.

--- dial
keymap({ "n", "v" }, "<leader>=", "<Plug>(dial-increment)", { noremap = true })
keymap({ "n", "v" }, "<leader>-", "<Plug>(dial-decrement)", { noremap = true })

--- regexplainer
-- "<leader>gR" to toggle regexplainer

--- leap.nvim
-- "s/S", "f/F", "t/T" to use leap
