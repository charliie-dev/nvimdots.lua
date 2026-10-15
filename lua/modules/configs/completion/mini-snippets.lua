return function()
	local vim_path = require("core.global").vim_path
	local gen_loader = require("mini.snippets").gen_loader

	-- Load the snippet files a VSCode-style package.json lists for a language. Match the language
	-- at the cursor and the buffer's filetype: Treesitter names markdown prose `markdown_inline`
	-- and tex `latex`, while the manifest uses filetypes.
	local function from_manifest(root)
		local manifest = root .. "/package.json"
		if vim.fn.filereadable(manifest) ~= 1 then
			return function()
				return {}
			end
		end
		local by_lang = {}
		for _, entry in ipairs(vim.json.decode(table.concat(vim.fn.readfile(manifest), "\n")).contributes.snippets) do
			local languages = type(entry.language) == "table" and entry.language or { entry.language }
			for _, lang in ipairs(languages) do
				by_lang[lang] = by_lang[lang] or {}
				table.insert(by_lang[lang], gen_loader.from_file(vim.fs.joinpath(root, entry.path)))
			end
		end
		return function(context)
			local res, seen = {}, {}
			for _, lang in ipairs({ context.lang, vim.bo[context.buf_id].filetype }) do
				if not seen[lang] then
					seen[lang] = true
					for _, load in ipairs(by_lang[lang] or {}) do
						table.insert(res, load(context))
					end
				end
			end
			return res
		end
	end

	require("modules.utils").load_plugin("mini.snippets", {
		snippets = {
			-- friendly-snippets and any other `snippets/` directory on 'runtimepath'
			gen_loader.from_lang({ lang_patterns = { markdown_inline = { "markdown.json" } } }),
			from_manifest(vim_path .. "/snips"),
			from_manifest(vim_path .. "/lua/user/snips"),
		},
		-- Blink expands snippets from completion and walks tabstops with <Tab>/<S-Tab>. Skip the
		-- global <C-j> expand and the session's <C-l>/<C-h>, which would shadow Insert-mode <C-h>.
		mappings = {
			expand = "",
			jump_next = "",
			jump_prev = "",
		},
	})

	-- blink.cmp adds its buffer keymaps (<Tab> snippet_forward, ...) when the buffer enters plain
	-- Insert mode, but a session leaves Insert mode with complete() active ("ic"), which blink skips.
	-- A session that is the buffer's first Insert mode (:Neogen in a fresh buffer) would then
	-- start without them, so add them when it starts.
	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("MiniSnippetsBlinkKeymaps", { clear = true }),
		pattern = "MiniSnippetsSessionStart",
		callback = function()
			if not package.loaded["blink.cmp"] or vim.b.blink_cmp_keymap_default ~= nil then
				return
			end
			local mappings = require("blink.cmp.keymap").mappings.default
			require("blink.cmp.keymap.apply").keymaps("default", mappings)
		end,
	})
end
