return function()
	require("modules.utils").load_plugin("lazydev", {
		library = {
			"lazy.nvim",
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})

	-- lazydev forgets a buffer when any lua_ls client detaches from it, so a lua_ls restart
	-- registered another nvim_buf_attach callback next to the old one and every edit was scanned
	-- once more per restart. Register a buffer once; later attaches only rescan it, which the new
	-- client still needs for its library.
	local lazydev_buf = require("lazydev.buf")
	local on_attach = lazydev_buf.on_attach
	local registered = {}
	lazydev_buf.on_attach = function(client, buf)
		if not registered[buf] then
			on_attach(client, buf)
			if lazydev_buf.attached[buf] then
				registered[buf] = true
				-- The buffer's nvim_buf_attach callbacks go away with it
				vim.api.nvim_create_autocmd("BufUnload", {
					buffer = buf,
					once = true,
					callback = function()
						registered[buf] = nil
					end,
				})
			end
			return
		end
		-- The rest of lazydev's on_attach, without attaching to the buffer again
		local root = require("lazydev.workspace").get_root(client, buf)
		if lazydev_buf.attached[buf] or not require("lazydev.config").is_enabled(root) then
			return
		end
		lazydev_buf.attached[buf] = buf
		lazydev_buf.on_lines(buf, 0, vim.api.nvim_buf_line_count(buf))
		lazydev_buf.on_file(buf)
		lazydev_buf.update()
	end
end
