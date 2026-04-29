local settings = require("core.settings")
local global = require("core.global")

-- Create cache dir and data dirs
local createdir = function()
	local data_dirs = {
		global.cache_dir .. "/backup",
		global.cache_dir .. "/session",
		global.cache_dir .. "/swap",
		global.cache_dir .. "/tags",
		global.cache_dir .. "/undo",
	}
	-- Only check whether cache_dir exists, this would be enough.
	if not vim.uv.fs_stat(global.cache_dir) then
		vim.fn.mkdir(global.cache_dir, "p")
		for _, dir in pairs(data_dirs) do
			if not vim.uv.fs_stat(dir) then
				vim.fn.mkdir(dir, "p")
			end
		end
	end
end

local leader_map = function()
	vim.g.mapleader = ","
	-- Below lines is only needed when leader is set to <Space>
	vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })
end

local clipboard_config = function()
	if global.is_mac then
		vim.g.clipboard = {
			name = "macOS-clipboard",
			copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
			paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
			cache_enabled = 0,
		}
	elseif global.is_wsl then
		vim.g.clipboard = {
			name = "psyank-wsl",
			copy = {
				["+"] = "clip.exe",
				["*"] = "clip.exe",
			},
			paste = {
				["+"] = [[powershell.exe -NoProfile -NoLogo -NonInteractive -Command [console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))]],
				["*"] = [[powershell.exe -NoProfile -NoLogo -NonInteractive -Command [console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))]],
			},
			cache_enabled = 0,
		}
	elseif os.getenv("SSH_TTY") then
		local osc52 = require("vim.ui.clipboard.osc52")
		-- Windows Terminal does not implement OSC 52 read; fall back to the
		-- unnamed register so `"+p` does not block waiting for a reply.
		local is_wt = os.getenv("WT_SESSION") ~= nil
		local register_paste = function()
			return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
		end
		vim.g.clipboard = {
			name = "OSC 52",
			copy = {
				["+"] = osc52.copy("+"),
				["*"] = osc52.copy("*"),
			},
			paste = {
				["+"] = is_wt and register_paste or osc52.paste("+"),
				["*"] = is_wt and register_paste or osc52.paste("*"),
			},
		}
	elseif os.getenv("TMUX") then
		vim.g.clipboard = {
			name = "tmux",
			copy = {
				["+"] = "tmux set-buffer -w",
				["*"] = "tmux set-buffer -w",
			},
			paste = {
				["+"] = "tmux save-buffer -",
				["*"] = "tmux save-buffer -",
			},
			cache_enabled = 0,
		}
	end
end

local shell_config = function()
	if global.is_windows then
		if not (vim.fn.executable("pwsh") == 1 or vim.fn.executable("powershell") == 1) then
			vim.notify(
				[[paste
Failed to setup terminal config
PowerShell is either not installed, missing from PATH, or not executable;
cmd.exe will be used instead for `:!` (shell bang) and terminal.
You're recommended to install PowerShell for better experience.]],
				vim.log.levels.WARN,
				{ title = "[core] Runtime error" }
			)
			return
		end

		local basecmd = "-NoLogo -MTA -ExecutionPolicy RemoteSigned"
		local ctrlcmd = "-Command [console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8"
		local set_opts = vim.api.nvim_set_option_value
		set_opts("shell", vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell", {})
		set_opts("shellcmdflag", string.format("%s %s;", basecmd, ctrlcmd), {})
		set_opts("shellredir", "-RedirectStandardOutput %s -NoNewWindow -Wait", {})
		set_opts("shellpipe", "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode", {})
		set_opts("shellquote", "", {})
		set_opts("shellxquote", "", {})
	end
end

local load_core = function()
	createdir()
	leader_map()

	clipboard_config()
	shell_config()

	require("core.options")
	require("core.event")
	require("core.pack")
	require("keymap")

	vim.api.nvim_set_option_value("background", settings.background, {})
	vim.cmd.colorscheme(settings.colorscheme)
end

load_core()
