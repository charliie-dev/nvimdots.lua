local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
assert(package.loaded.core == nil, "runtime_stage2_startup_spec must run before init.lua")
local registered_at_filetype = false
vim.api.nvim_create_autocmd("FileType", {
	pattern = "toml",
	once = true,
	callback = function()
		registered_at_filetype = vim.iter(vim.api.nvim_get_autocmds({ event = "FileType" })):any(function(event)
			return event.desc == "Start treesitter for installed parsers"
		end)
	end,
})
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			local ok, err = xpcall(function()
				assert(vim.fn.stdpath("config") == root, "wrong checkout")
				assert(vim.api.nvim_buf_get_name(0) == root .. "/mise.toml", "wrong initial file")
				assert(vim.bo.filetype == "toml", "initial filetype missing")
				assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], "highlighting missing")
				assert(
					vim.bo.indentexpr == "v:lua.require'nvim-treesitter'.indentexpr()",
					"initial TOML indentexpr missing: " .. vim.bo.indentexpr
				)
				assert(registered_at_filetype, "Treesitter missed the initial FileType event")
				vim.api.nvim_buf_set_lines(0, 0, -1, false, { "values = [", "1,", "]" })
				vim.cmd("normal! gg=G")
				assert(vim.fn.indent(2) == vim.bo.shiftwidth, "TOML indentexpr did not indent the array")
				assert(vim.fn.indent(3) == 0, "TOML closing bracket indentation is wrong")
				vim.bo.modified = false
			end, debug.traceback)
			if not ok then
				vim.api.nvim_err_writeln(err)
				vim.cmd.cquit(1)
			end
			print("runtime_stage2_startup_spec: initial TOML highlighting and indentation passed")
			vim.cmd("qa!")
		end, 300)
	end,
})
