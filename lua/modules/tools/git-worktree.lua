require("git-worktree").setup({
	change_directory_command = "cd", -- default: "cd",
	update_on_change = true, -- default: true,
	update_on_change_command = "e .", -- default: "e .",
	clearjumps_on_change = true, -- default: true,
	autopush = false, -- default: false,
})

-- NOTE: learn git-worktree: https://youtu.be/2uEqYw-N8uE
-- NOTE: most importantly, use `git clone --bare <upstream>`

local Worktree = require("git-worktree")

-- op = Operations.Switch, Operations.Create, Operations.Delete
-- metadata = table of useful values (structure dependent on op)
--      Switch
--          path = path you switched to
--          prev_path = previous worktree path
--      Create
--          path = path where worktree created
--          branch = branch name
--          upstream = upstream remote name
--      Delete
--          path = path where worktree deleted

Worktree.on_tree_change(function(op, metadata)
	if op == Worktree.Operations.Switch then
		print("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
		vim.notify(
			"Switched from " .. "\n" .. metadata.prev_path .. "\n" .. " to " .. "\n" .. metadata.path,
			vim.log.levels.INFO,
			{ title = "git-worktree" }
		)
	end
end)
