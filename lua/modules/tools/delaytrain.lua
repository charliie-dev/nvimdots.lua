require("delaytrain").setup({
	delay_ms = 1000, -- How long repeated usage of a key should be prevented
	grace_period = 2, -- How many repeated keypresses are allowed
	keys = { -- Which keys (in which modes) should be delayed
		["nv"] = { "h", "j", "k", "l", "<Left>", "<Down>", "<Up>", "<Right>" },
		-- ["nvi"] = { "<Left>", "<Down>", "<Up>", "<Right>" },
	},
	ignore_filetypes = { "help", "diff", "NvimTr*", "lspsagaoutline", "notify", "oil" },
})
