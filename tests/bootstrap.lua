local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local stdpath = vim.fn.stdpath
local installed = stdpath("config")

-- Keep installed dependencies and caches, but resolve configuration to this checkout.
vim.fn.stdpath = function(kind)
	return kind == "config" and root or stdpath(kind)
end
local paths = vim.opt.runtimepath:get()
for i, path in ipairs(paths) do
	if path == installed then
		paths[i] = root
	elseif path == installed .. "/after" then
		paths[i] = root .. "/after"
	end
end
vim.opt.runtimepath = paths
vim.opt.runtimepath:prepend(root)
vim.opt.packpath = vim.o.runtimepath
