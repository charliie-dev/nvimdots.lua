local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true, nowait = true }

-- Plugin keymaps

--- DAP
keymap("n", "<F6>", "<cmd>lua require('dap').continue()<cr>", opts) -- Launching debug sessions and resuming execution
keymap("n", "<F7>", "<cmd>lua require('dap').terminate() require('dapui').close()<cr>", opts)
keymap("n", "<F8>", "<cmd>lua require('dap').toggle_breakpoint()<cr>", opts)
keymap("n", "<F9>", "<cmd>lua require('dap').step_into()<cr>", opts)
keymap("n", "<F10>", "<cmd>lua require('dap').step_out()<cr>", opts)
keymap("n", "<F11>", "<cmd>lua require('dap').step_over()<cr>", opts)
keymap("n", "<leader>db", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))", opts)
keymap("n", "<leader>dc", "<cmd>lua require('dap').run_to_cursor()<cr>", opts)
keymap("n", "<leader>dl", "<cmd>lua require('dap').run_last()<cr>", opts)
keymap("n", "<leader>do", "<cmd>lua require('dap').repl.open()<cr>", opts)

--- Telescope
keymap("n", "<leader>fu", "<cmd>lua require('telescope').extensions.undo.undo()<cr>", opts)
keymap("n", "<leader>fp", "<cmd>lua require('telescope').extensions.projects.projects{}<cr>", opts)
keymap("n", "<leader>fr", "<cmd>lua require('telescope').extensions.frecency.frecency{}<cr>", opts)
keymap("n", "<leader>fw", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args{}<cr>", opts)
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
keymap("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", opts)
keymap("n", "<leader>fe", "<cmd>Telescope oldfiles<cr>", opts)
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope git_files<cr>", opts)
keymap("n", "<leader>fn", "<cmd>enew<cr>", opts)
keymap("n", "<leader>fz", "<cmd>Telescope zoxide list<cr>", opts)

--- nvim-bufdel
keymap("n", "<F4>", "<cmd>BufDel<cr>", opts)

--- BufferLine
keymap("n", "<tab>", "<cmd>BufferLineCycleNext<cr>", opts)
keymap("n", "<S-tab>", "<cmd>BufferLineCyclePrev<cr>", opts)

--- Lsp mapping work when event:InsertEnter & event:LspStart
keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
keymap("n", "<leader>lr", "<cmd>LspRestart<cr>", opts)
keymap("n", "go", "<cmd>Lspsaga outline<cr>", opts)
keymap("n", "g[", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
keymap("n", "g]", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<cr>", opts)
keymap("n", "gr", "<cmd>Lspsaga rename<cr>", opts)
keymap("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
keymap("n", "ga", "<cmd>Lspsaga code_action<cr>", opts)
keymap("v", "ga", "<cmd>Lspsaga code_action<cr>", opts)
keymap("n", "gd", "<cmd>Lspsaga peek_definition<cr>", opts)
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<cr>", opts)
keymap("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", opts)
keymap("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<cr>", opts)
keymap("n", "gS", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
keymap("n", "gD", "<cmd>Lspsaga goto_definition<cr>", opts)
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

--- NvimTree
keymap("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", opts)
keymap("n", "<leader>nf", "<cmd>NvimTreeFindFile<cr>", opts)
keymap("n", "<leader>nr", "<cmd>NvimTreeRefresh<cr>", opts)

--- accelerate-jk
keymap("n", "j", "<Plug>(accelerated_jk_gj)", {})
keymap("n", "k", "<Plug>(accelerated_jk_gk)", {})

--- MarkdownPreview
keymap("n", "<F12>", "<cmd>MarkdownPreviewToggle<cr>", opts)

-- Tabout
keymap("i", "<A-l>", "<Plug>(TaboutMulti)", opts)
keymap("i", "<A-h>", "<Plug>(TaboutBackMulti)", opts)

--- SnipRun
keymap("n", "<leader>R", "<cmd>SnipRun<cr>", opts)
keymap("v", "<leader>R", "<cmd>%SnipRun<cr>", opts)

--- Diffview
keymap("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", opts)
keymap("n", "<leader><leader>dv", "<cmd>DiffviewClose<cr>", opts)

--- Legendary
keymap("n", "<C-p>", "<cmd>Legendary<cr>", opts)

--- Lazy.nvim
keymap("n", "<leader>ph", "<cmd>Lazy<cr>", opts)
keymap("n", "<leader>ps", "<cmd>Lazy sync<cr>", opts)
keymap("n", "<leader>pu", "<cmd>Lazy update<cr>", opts)
keymap("n", "<leader>pi", "<cmd>Lazy install<cr>", opts)
keymap("n", "<leader>pl", "<cmd>Lazy log<cr>", opts)
keymap("n", "<leader>pc", "<cmd>Lazy check<cr>", opts)
keymap("n", "<leader>pd", "<cmd>Lazy debug<cr>", opts)
keymap("n", "<leader>pp", "<cmd>Lazy profile<cr>", opts)
keymap("n", "<leader>pr", "<cmd>Lazy restore<cr>", opts)
keymap("n", "<leader>px", "<cmd>Lazy clean<cr>", opts)

--- comment-frame
keymap("n", "<leader>cf", "<cmd>lua require('nvim-comment-frame').add_comment()<cr>", {})
keymap("n", "<leader>cF", "<cmd>lua require('nvim-comment-frame').add_multiline_comment()<cr>", {})

--- ssr.nvim, structural search and replace
-- vim.keymap.set({ "n", "x" }, "<leader>sr", function()
-- 	require("ssr").open()
-- end, { desc = "structural search and replace." })

--- search-replace.nvim
-- SearchReplaceSingleBuffer
keymap("n", "<leader>rs", "<cmd>SearchReplaceSingleBufferSelections<cr>", opts)
keymap("n", "<leader>ro", "<cmd>SearchReplaceSingleBufferOpen<cr>", opts)
keymap("n", "<leader>rw", "<cmd>SearchReplaceSingleBufferCWord<cr>", opts)
keymap("n", "<leader>rW", "<cmd>SearchReplaceSingleBufferCWORD<cr>", opts)
keymap("n", "<leader>re", "<cmd>SearchReplaceSingleBufferCExpr<cr>", opts)
keymap("n", "<leader>rf", "<cmd>SearchReplaceSingleBufferCFile<cr>", opts)
-- SearchReplaceMultiBuffer
keymap("n", "<leader>rbs", "<cmd>SearchReplaceMultiBufferSelections<cr>", opts)
keymap("n", "<leader>rbo", "<cmd>SearchReplaceMultiBufferOpen<cr>", opts)
keymap("n", "<leader>rbw", "<cmd>SearchReplaceMultiBufferCWord<cr>", opts)
keymap("n", "<leader>rbW", "<cmd>SearchReplaceMultiBufferCWORD<cr>", opts)
keymap("n", "<leader>rbe", "<cmd>SearchReplaceMultiBufferCExpr<cr>", opts)
keymap("n", "<leader>rbf", "<cmd>SearchReplaceMultiBufferCFile<cr>", opts)
-- Visual Mode
keymap("v", "<C-r>", "<cmd>SearchReplaceSingleBufferVisualSelection<cr>", opts)
keymap("v", "<C-w>", "<cmd>SearchReplaceWithinVisualSelectionCWord<cr>", opts)

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
keymap("n", "<leader>=", "<Plug>(dial-increment)", { noremap = true })
keymap("v", "<leader>=", "<Plug>(dial-increment)", { noremap = true })
keymap("n", "<leader>-", "<Plug>(dial-decrement)", { noremap = true })
keymap("v", "<leader>-", "<Plug>(dial-decrement)", { noremap = true })

--- EasyAlign
keymap("n", "gea", "v:lua.enhance_align('nea')", {})
keymap("x", "gea", "v:lua.enhance_align('xea')", {})

--- regexplainer
-- "<leader>gR" to toggle regexplainer

--- nabla
keymap("n", "<leader>mp", "<cmd>lua require('nabla').popup('rounded')<cr>", opts)

--- leap.nvim
-- "s/S", "f/F", "t/T" to use leap

--- syntax-tree-surfer
-- Visual Selection from Normal Mode
keymap("n", "vx", "<cmd>STSSelectMasterNode<cr>", opts)
keymap("n", "vn", "<cmd>STSSelectCurrentNode<cr>", opts)

-- Select Nodes in Visual Mode
keymap("x", "[", "<cmd>STSSelectPrevSiblingNode<cr>", opts)
keymap("x", "]", "<cmd>STSSelectNextSiblingNode<cr>", opts)
keymap("x", "=", "<cmd>STSSelectParentNode<cr>", opts)
keymap("x", "-", "<cmd>STSSelectChildNode<cr>", opts)

-- Targeted Jump with virtual_text, placed in tree-surfer.lua
-- "gv", jump to variable_declarations(only within visible window)
-- "gfu", jump to functions
-- "gif", jump to if-statements
-- "gfo", jump to for-statements
-- "gj", jump to certain nodes

--- various-textobjs
-- select around same indent level
keymap("o", "aI", "<cmd>lua require('various-textobjs').indentation(false, false)<cr>", opts)
keymap("x", "aI", "<cmd>lua require('various-textobjs').indentation(false, false)<cr>", opts)
-- select inside same indent level
keymap("o", "iI", "<cmd>lua require('various-textobjs').indentation(true, true)<cr>", opts)
keymap("x", "iI", "<cmd>lua require('various-textobjs').indentation(true, true)<cr>", opts)

-- select around value of key-value pair, including trailing commas or semicolons
keymap("o", "av", "<cmd>lua require('various-textobjs').value(false)<cr>", opts)
keymap("x", "av", "<cmd>lua require('various-textobjs').value(false)<cr>", opts)
-- select inside value of key-value pair, excluding trailing commas or semicolons
keymap("o", "iv", "<cmd>lua require('various-textobjs').value(true)<cr>", opts)
keymap("x", "iv", "<cmd>lua require('various-textobjs').value(true)<cr>", opts)

-- select around number, including signs & decimal point
keymap("o", "an", "<cmd>lua require('various-textobjs').number(false)<cr>", opts)
keymap("x", "an", "<cmd>lua require('various-textobjs').number(false)<cr>", opts)
-- select pure number, excluding signs & decimal point
keymap("o", "in", "<cmd>lua require('various-textobjs').number(true)<cr>", opts)
keymap("x", "in", "<cmd>lua require('various-textobjs').number(true)<cr>", opts)

-- select LSP diagnostic(require built-in LSP)
keymap("o", "!", "<cmd>lua require('various-textobjs').diagnostic()<cr>", opts)
keymap("x", "!", "<cmd>lua require('various-textobjs').diagnostic()<cr>", opts)

-- select entire mdlink, [title](url), md only
keymap("o", "al", "<cmd>lua require('various-textobjs').mdlink(false)<cr>", opts)
keymap("x", "al", "<cmd>lua require('various-textobjs').mdlink(false)<cr>", opts)
-- select mdlink title, md only
keymap("o", "il", "<cmd>lua require('various-textobjs').mdlink(true)<cr>", opts)
keymap("x", "il", "<cmd>lua require('various-textobjs').mdlink(true)<cr>", opts)

-- select arround mdFencedCodeBlock, including the enclosing backticks, md only
keymap("o", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
keymap("x", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
-- select inside mdFencedCodeBlock, excluding the enclosing backticks, md only
keymap("o", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)
keymap("x", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)

-- select arround doubleSquareBrackets([[]]), including the four square brackets(lua, shell, neorg, md)
keymap("o", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
keymap("x", "aC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<cr>", opts)
-- select inside doubleSquareBrackets([[]]), excluding the four square brackets(lua, shell, neorg, md)
keymap("o", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)
keymap("x", "iC", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<cr>", opts)

-- select column down until indent or shorter line. Accepts `{count}` for multi-columns
keymap("o", "|", "<cmd>lua require('various-textobjs').column()<cr>", opts)
keymap("x", "|", "<cmd>lua require('various-textobjs').column()<cr>", opts)
keymap("x", "|", "<cmd>lua require('various_textobjs').column()<cr>", opts)

-- select the rest of the Paragraph, like `}`, but linewise
keymap("o", "r", "<cmd>lua require('various-textobjs').restOfParagraph()<cr>", opts)
keymap("x", "r", "<cmd>lua require('various-textobjs').restOfParagraph()<cr>", opts)

-- select subword, but never treating `-`, `_` or `.` as word delimiters
keymap("o", "aS", "<cmd>lua require('various-textobjs').subword(false)<cr>", opts)
keymap("x", "aS", "<cmd>lua require('various-textobjs').subword(false)<cr>", opts)
-- --
keymap("o", "iS", "<cmd>lua require('various-textobjs').subword(true)<cr>", opts)
keymap("x", "iS", "<cmd>lua require('various-textobjs').subword(true)<cr>", opts)

--- markdowny.nvim(hard-coded)
-- vim.keymap.set("v", "<C-b>", ":lua require('markdowny').bold()<cr>", { buffer = 0 })
-- vim.keymap.set("v", "<C-i>", ":lua require('markdowny').italic()<cr>", { buffer = 0 })
-- vim.keymap.set("v", "<C-k>", ":lua require('markdowny').link()<cr>", { buffer = 0 })

--- oil.nvim
keymap("n", "<leader>o", "<cmd>lua require('oil').open_float()<cr>", opts)
