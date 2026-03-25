local ok, devicons = pcall(require, "nvim-web-devicons")
if ok then
	local filename = vim.fn.expand("%:t")
	devicons.set_icon({
		[filename] = { icon = "", color = "#FAF743", cterm_color = "227", name = "Env" },
	})
end
