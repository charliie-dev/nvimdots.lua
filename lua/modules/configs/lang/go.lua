return function()
	require("modules.utils").load_plugin("go", {
		-- By default, we've turned off these options to prevent clashes with our gopls config
		icons = false,
		diagnostic = false,
		lsp_cfg = false,
		lsp_gofumpt = false,
		lsp_keymaps = false,
		lsp_codelens = false,
		lsp_document_formatting = false,
		lsp_inlay_hints = { enable = false },
		-- DAP-related settings are also turned off here for the same reason
		dap_debug = false,
		dap_debug_keymap = false,
		textobjects = false,
		-- Miscellaneous options to seamlessly integrate with other plugins
		trouble = true,
		luasnip = false,
		run_in_floaterm = false,
	})

	-- go.nvim's tag commands run gomodifytags on the file on disk, write its output into whichever
	-- buffer is current when it replies and :write it. gopls modifies the tags through an LSP edit
	-- of this file's buffer instead, unsaved changes included, and leaves saving to you.
	local tag_flags = {
		["-add-tags"] = "Add",
		["-remove-tags"] = "Remove",
		["-add-options"] = "AddOptions",
		["-a"] = "AddOptions",
		["-remove-options"] = "RemoveOptions",
		["-transform"] = "Transform",
		["-t"] = "Transform",
		["-template"] = "ValueFormat",
	}
	local tag_switches = {
		["-clear-tags"] = "Clear",
		["-clear-options"] = "ClearOptions",
		["-override"] = "Overwrite",
		["-skip-unexported"] = "SkipUnexportedFields",
	}

	---Turn gomodifytags flags into gopls.modify_tags arguments
	---@param fargs string[]
	---@return table? args, string? bad_flag
	local function tag_args(fargs)
		local args, i = {}, 1
		while i <= #fargs do
			local flag = fargs[i]
			if tag_switches[flag] then
				args[tag_switches[flag]] = true
				i = i + 1
			elseif tag_flags[flag] then
				local value = fargs[i + 1]
				-- go.nvim adds json tags when the tag list is left out
				if not value and (flag == "-add-tags" or flag == "-remove-tags") then
					value = "json"
				end
				if not value then
					return nil, flag
				end
				args[tag_flags[flag]] = value
				i = i + 2
			else
				return nil, flag
			end
		end
		local config = require("go").config()
		if args.Add then
			args.Transform = args.Transform or config.tag_transform or nil
			args.AddOptions = args.AddOptions or config.tag_options or nil
		end
		return args
	end

	---The struct type around the cursor, also from its `type Name struct` line
	---@param bufnr integer
	---@return TSNode?
	local function struct_at_cursor(bufnr)
		local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
		if not ok or not parser then
			return
		end
		-- Parse first: the tree can predate the latest edits, or not exist without highlighting
		parser:parse()
		local node = vim.treesitter.get_node({ bufnr = bufnr, lang = "go" })
		while node do
			local kind = node:type()
			if kind == "struct_type" then
				return node
			elseif kind == "type_spec" or kind == "type_declaration" then
				for child in node:iter_children() do
					local spec = child:type() == "type_spec" and child or node
					local type = spec:field("type")[1]
					if type and type:type() == "struct_type" then
						return type
					end
				end
			end
			node = node:parent()
		end
	end

	---@param fargs string[]
	local function modify_tags(fargs)
		local bufnr = vim.api.nvim_get_current_buf()
		local args, bad_flag = tag_args(fargs)
		if not args then
			vim.notify("Unsupported struct tag option: " .. bad_flag, vim.log.levels.ERROR, { title = "go.nvim" })
			return
		end
		local client = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })[1]
		if not client then
			vim.notify("gopls is not attached to this buffer", vim.log.levels.WARN, { title = "go.nvim" })
			return
		end
		local struct = struct_at_cursor(bufnr)
		if not struct then
			vim.notify("No struct at the cursor", vim.log.levels.WARN, { title = "go.nvim" })
			return
		end
		local start_row, _, end_row = struct:range()
		local last = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ""
		args.URI = vim.uri_from_bufnr(bufnr)
		args.Range = {
			start = { line = start_row, character = 0 },
			["end"] = { line = end_row, character = vim.str_utfindex(last, "utf-16") },
		}
		client:exec_cmd(
			{ title = "Modify struct tags", command = "gopls.modify_tags", arguments = { args } },
			{ bufnr = bufnr }
		)
	end

	local go = package.loaded.go
	vim.api.nvim_create_user_command("GoAddTag", function(opts)
		local fargs = opts.fargs
		if #fargs == 0 or fargs[1]:sub(1, 1) == "-" then
			table.insert(fargs, 1, "json")
		end
		modify_tags({ "-add-tags", unpack(fargs) })
	end, { nargs = "*", complete = go.add_tags_complete, desc = "Add struct tags through gopls" })
	vim.api.nvim_create_user_command("GoRmTag", function(opts)
		local fargs = opts.fargs
		if #fargs == 0 or fargs[1]:sub(1, 1) == "-" then
			table.insert(fargs, 1, "json")
		end
		modify_tags({ "-remove-tags", unpack(fargs) })
	end, { nargs = "*", desc = "Remove struct tags through gopls" })
	vim.api.nvim_create_user_command("GoClearTag", function()
		modify_tags({ "-clear-tags" })
	end, { desc = "Clear struct tags through gopls" })
	vim.api.nvim_create_user_command("GoModifyTag", function(opts)
		modify_tags(opts.fargs)
	end, { nargs = "*", complete = go.modify_tags_complete, desc = "Modify struct tags through gopls" })
end
