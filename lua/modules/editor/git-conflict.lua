require("git-conflict").setup({
	default_mappings = true, -- disable buffer local mapping created by this plugin
	disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
	highlights = { -- They must have background color, otherwise the default color will be used
		incoming = "DiffText",
		current = "DiffAdd",
	},
})

-- :GitConflictChooseOurs (co) - Select the current changes.
-- :GitConflictChooseTheirs (ct) - Select the incoming changes.
-- :GitConflictChooseBoth (cb) - Select both changes.
-- :GitConflictChooseNone (c0) - Select both none of the changes.
-- :GitConflictNextConflict ([x) - Move to the next conflict.
-- :GitConflictPrevConflict (]x) - Move to the previous conflict.
-- :GitConflictListQf - Get all conflict to quickfix
