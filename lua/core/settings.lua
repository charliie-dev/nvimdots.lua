local settings = {}

settings["use_ssh"] = true
settings["format_disabled_dirs"] = {
	vim.env.HOME .. "/.config/alacritty",
}
settings["use_icons"] = true

return settings
