local icon = require("modules.ui.icons")

require("dapui").setup({
	icons = { expanded = icon.ui.ArrowOpen, collapsed = icon.ui.ArrowClosed, current_frame = icon.ui.Indicator },
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	layouts = {
		{
			elements = {
				-- Provide as ID strings or tables with "id" and "size" keys
				{
					id = "scopes",
					size = 0.25, -- Can be float or integer > 1
				},
				{ id = "watches", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
			},
			size = 40,
			position = "left",
		},
		{ elements = { "repl" }, size = 10, position = "bottom" },
	},
	-- Requires Nvim version >= 0.8
	controls = {
		enabled = true,
		-- Display controls in this session
		element = "repl",
		icons = {
			pause = icon.dap.Pause,
			play = icon.dap.Play,
			step_into = icon.dap.StepInto,
			step_over = icon.dap.StepOver,
			step_out = icon.dap.StepOut,
			step_back = icon.dap.StepBack,
			run_last = icon.dap.RunLast,
			terminate = icon.dap.Terminate,
		},
	},
	floating = {
		max_height = nil,
		max_width = nil,
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = { close = { "q", "<Esc>" } },
	},
	windows = { indent = 1 },
})
