local icons = {
	diagnostics = require("modules.ui.icons").get("diagnostics", true),
	misc = require("modules.ui.icons").get("misc", true),
	git = require("modules.ui.icons").get("git"),
	ui = require("modules.ui.icons").get("ui", true),
}

local function escape_status()
	local ok, m = pcall(require, "better_escape")
	return ok and m.waiting and icons.misc.EscapeST or ""
end

local _cache = { context = "", bufnr = -1 }
local function lspsaga_symbols()
	local exclude = {
		["terminal"] = true,
		["toggleterm"] = true,
		["prompt"] = true,
		["NvimTree"] = true,
		["help"] = true,
	}
	if vim.api.nvim_win_get_config(0).zindex or exclude[vim.bo.filetype] then
		return "" -- Excluded filetypes
	else
		local currbuf = vim.api.nvim_get_current_buf()
		local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
		if ok and lspsaga:get_winbar() ~= nil then
			_cache.context = lspsaga:get_winbar()
			_cache.bufnr = currbuf
		elseif _cache.bufnr ~= currbuf then
			_cache.context = "" -- Reset [invalid] cache (usually from another buffer)
		end

		return _cache.context
	end
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

local function get_cwd()
	local cwd = vim.fn.getcwd()
	local home = os.getenv("HOME")
	if cwd:find(home, 1, true) == 1 then
		cwd = "~" .. cwd:sub(#home + 1)
	end
	return icons.ui.RootFolderOpened .. cwd
end

local mini_sections = {
	lualine_a = { "filetype" },
	lualine_b = {},
	lualine_c = {},
	lualine_x = {},
	lualine_y = {},
	lualine_z = {},
}
local outline = {
	sections = mini_sections,
	filetypes = { "lspsagaoutline" },
}
local diffview = {
	sections = mini_sections,
	filetypes = { "DiffviewFiles" },
}

-- local hide_in_width = function()
-- 	return vim.fn.winwidth(0) > 30
-- end

-- local git_blame = require("gitblame")
-- local gitblame_cond = function()
-- 	return (git_blame.is_blame_text_available() and hide_in_width())
-- end

local function python_venv()
	local function env_cleanup(venv)
		if string.find(venv, "/") then
			local final_venv = venv
			for w in venv:gmatch("([^/]+)") do
				final_venv = w
			end
			venv = final_venv
		end
		return venv
	end

	if vim.bo.filetype == "python" then
		local venv = os.getenv("CONDA_DEFAULT_ENV")
		if venv then
			return string.format(icons.misc.PyEnv .. ":(%s)", env_cleanup(venv))
		end
		venv = os.getenv("VIRTUAL_ENV")
		if venv then
			return string.format(icons.misc.PyEnv .. ":(%s)", env_cleanup(venv))
		end
	end
	return ""
end

-- check your colorscheme in REPO/lua/lualine/themes/THEME.lua -> normal.b.bg
-- if vim.g.colors_name == "catppuccin" then
-- 	vim.api.nvim_set_hl(0, "SLGitIcon", { fg = "#E8AB53", bg = "#575268" })
-- 	vim.api.nvim_set_hl(0, "SLBranchName", { fg = "#D4D4D4", bg = "#575268" })
-- end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = vim.g.colors_name,
		disabled_filetypes = { "alpha" },
		component_separators = "|",
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			{
				"branch",
				icons_enabled = true,
				-- icon = "%#SLGitIcon#" .. icons.git.Branch .. "%*" .. "%#SLBranchName#",
				icon = icons.git.Branch,
			},
			{ "diff", source = diff_source },
		},
		lualine_c = { lspsaga_symbols },
		lualine_x = {
			{ escape_status },
			-- { git_blame.get_current_blame_text, cond = gitblame_cond },
			{ get_cwd },
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = {
					error = icons.diagnostics.Error .. " ",
					warn = icons.diagnostics.Warning .. " ",
					info = icons.diagnostics.Information .. " ",
				},
			},
		},
		lualine_y = {
			{ "filetype", colored = true, icon_only = true },
			{ python_venv },
			{ "encoding" },
			{
				"fileformat",
				icons_enabled = true,
				symbols = {
					unix = "LF",
					dos = "CRLF",
					mac = "CR",
				},
			},
		},
		lualine_z = { "progress", "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {
		"quickfix",
		"neo-tree",
		"nvim-tree",
		"nvim-dap-ui",
		"toggleterm",
		"fugitive",
		outline,
		diffview,
	},
})

-- Properly set background color for lspsaga
local winbar_bg = require("modules.utils").hl_to_rgb("StatusLine", true, "#000000")
for _, hlGroup in pairs(require("lspsaga.lspkind").get_kind()) do
	require("modules.utils").extend_hl("LspSagaWinbar" .. hlGroup[1], { bg = winbar_bg })
end
require("modules.utils").extend_hl("LspSagaWinbarSep", { bg = winbar_bg })
