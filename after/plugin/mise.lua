-- Custom treesitter predicate for detecting mise TOML files
require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
	local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	-- Match mise.toml, mise.*.toml, .mise.toml, .mise.*.toml, or any .toml inside a .mise/ directory
	return string.match(filename, "^%.?mise[%w_%-]*%.toml$") ~= nil or string.match(filepath, "/%.mise/") ~= nil
end, { force = true, all = false })
