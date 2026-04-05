return function()
	local rd = require("rainbow-delimiters")

	---@param threshold number @Use global strategy if nr of lines exceeds this value
	local function init_strategy(threshold)
		return function()
			if vim.api.nvim_buf_line_count(0) > threshold then
				return rd.strategy["global"]
			end
			return rd.strategy["local"]
		end
	end

	vim.g.rainbow_delimiters = {
		strategy = {
			[""] = init_strategy(500),
			c = init_strategy(300),
			cpp = init_strategy(300),
			lua = init_strategy(500),
			vimdoc = init_strategy(300),
			vim = init_strategy(300),
		},
		---@param buf number
		condition = function(buf)
			if vim.api.nvim_buf_line_count(buf) > 15000 then
				return false
			end
			-- pcall handles both nvim 0.11 (throws) and 0.12+ (returns nil)
			local ok, parser = pcall(vim.treesitter.get_parser, buf)
			if not ok or not parser then
				return false
			end
			local errors = 200
			parser:for_each_tree(function(lt)
				if lt:root():has_error() and errors >= 0 then
					errors = errors - 1
				end
			end)
			return errors >= 0
		end,
		query = {
			[""] = "rainbow-delimiters",
			latex = "rainbow-blocks",
			javascript = "rainbow-delimiters-react",
		},
		highlight = {
			"RainbowDelimiterRed",
			"RainbowDelimiterOrange",
			"RainbowDelimiterYellow",
			"RainbowDelimiterGreen",
			"RainbowDelimiterBlue",
			"RainbowDelimiterCyan",
			"RainbowDelimiterViolet",
		},
	}

	require("modules.utils").load_plugin("rainbow_delimiters", nil, true)
end
