local status, schemastore = pcall(require, "schemastore")
if not status then
	return
end

return {
	init_options = {
		provideFormatter = false,
	},
	settings = {
		json = {
			schemas = schemastore.json.schemas(),
      validate = { enable = true },
		},
	},
	setup = {
		commands = {
			-- Format = {
			--   function()
			--     vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
			--   end,
			-- },
		},
	},
}
