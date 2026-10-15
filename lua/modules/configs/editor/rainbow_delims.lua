return function()
	---@param threshold number @Use global strategy if nr of lines exceeds this value
	local function init_strategy(threshold)
		return function(buf)
			local strategy = vim.api.nvim_buf_line_count(buf) > threshold and "rainbow-delimiters.strategy.global"
				or "rainbow-delimiters.strategy.local"
			-- Remembered so a later change in size can be noticed (see the autocmd below)
			vim.b[buf].rainbow_strategy = strategy
			return strategy
		end
	end

	local strategy = {
		[""] = init_strategy(500),
		c = init_strategy(300),
		cpp = init_strategy(300),
		lua = init_strategy(500),
		vimdoc = init_strategy(300),
		vim = init_strategy(300),
	}

	---@param buf number
	local function condition(buf)
		local enabled = (function()
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
		end)()
		vim.b[buf].rainbow_condition = enabled
		return enabled
	end

	vim.g.rainbow_delimiters = {
		strategy = strategy,
		condition = condition,
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

	-- rainbow-delimiters checks `condition` and picks a strategy only when a buffer gets its
	-- filetype, so a file that grows or shrinks across a line limit, or whose parse errors get fixed,
	-- kept the first decision. Check again shortly after the buffer changes. A buffer turned off by
	-- hand stays off unless the condition itself changes.
	local function recheck(buf)
		if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].rainbow_condition == nil then
			return
		end
		local rainbow = require("rainbow-delimiters")
		local was_enabled = vim.b[buf].rainbow_condition
		local enabled = condition(buf)
		if enabled ~= was_enabled then
			if enabled then
				rainbow.enable(buf)
			else
				rainbow.disable(buf)
			end
			return
		end
		if not enabled or not rainbow.is_enabled(buf) then
			return
		end
		local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
		local previous = vim.b[buf].rainbow_strategy
		if (strategy[lang] or strategy[""])(buf) ~= previous then
			rainbow.disable(buf)
			rainbow.enable(buf)
		end
	end

	local timers = {}
	local group = vim.api.nvim_create_augroup("RainbowDelimitersThresholds", { clear = true })
	vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufWritePost" }, {
		group = group,
		callback = function(args)
			local buf = args.buf
			-- Only buffers rainbow-delimiters considered (it calls `condition` for its languages)
			if vim.b[buf].rainbow_condition == nil then
				return
			end
			timers[buf] = timers[buf] or vim.uv.new_timer()
			timers[buf]:start(
				500,
				0,
				vim.schedule_wrap(function()
					recheck(buf)
				end)
			)
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		callback = function(args)
			if timers[args.buf] then
				timers[args.buf]:close()
				timers[args.buf] = nil
			end
		end,
	})
end
