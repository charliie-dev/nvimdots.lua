return function()
	---@param threshold number @Use global strategy if nr of lines exceeds this value
	local function init_strategy(threshold)
		return function(buf)
			if vim.api.nvim_buf_line_count(buf) > threshold then
				return "rainbow-delimiters.strategy.global"
			end
			return "rainbow-delimiters.strategy.local"
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
			local parse_ok, trees = pcall(parser.parse, parser, true)
			if not parse_ok or not trees then
				return false
			end
			local error_limit = 200
			local error_count = 0
			local function count_errors(node)
				if node:type() == "ERROR" or node:missing() then
					error_count = error_count + 1
					if error_count > error_limit then
						return
					end
				end
				for child in node:iter_children() do
					count_errors(child)
					if error_count > error_limit then
						return
					end
				end
			end
			parser:for_each_tree(function(tree)
				if error_count <= error_limit then
					count_errors(tree:root())
				end
			end)
			return error_count <= error_limit
		end,
		query = {
			[""] = "rainbow-delimiters",
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
