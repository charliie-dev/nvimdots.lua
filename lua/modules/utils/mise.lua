local M = {}

---Report whether a path names a config file mise loads: mise.toml, .mise.toml, mise.<env>.toml,
---mise.local.toml, mise/config.toml, .mise/config.toml, the config*.toml files of ~/.config/mise
---and the files of a mise conf.d.
---@param path string
---@return boolean
function M.is_config(path)
	if path == "" then
		return false
	end
	local name = vim.fs.basename(path)
	local parent = vim.fs.basename(vim.fs.dirname(path))
	local grandparent = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(path)))
	if name:match("^%.?mise%.toml$") or name:match("^%.?mise%..+%.toml$") then
		return true
	end
	if (parent == "mise" or parent == ".mise") and name:match("^config.*%.toml$") then
		return true
	end
	return parent == "conf.d" and (grandparent == "mise" or grandparent == ".mise")
end

return M
