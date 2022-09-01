M = {}

local status, _ = pcall(require, "lspconfig")
if not status then
	return
end

M.server_capabilities = function()
  local active_clients = vim.lsp.get_active_clients()
  local active_client_map = {}

  for index, value in ipairs(active_clients) do
    active_client_map[value.name] = index
  end

  vim.ui.select(vim.tbl_keys(active_client_map), {
    prompt = "Select client:",
    format_item = function(item)
      return "capabilites for: " .. item
    end,
  }, function(choice)
    -- print(active_client_map[choice])
    print(vim.inspect(vim.lsp.get_active_clients()[active_client_map[choice]].server_capabilities.executeCommandProvider))
    vim.pretty_print(vim.lsp.get_active_clients()[active_client_map[choice]].server_capabilities)
  end)
end

require("config.lsp.lsp-signature")
require("config.lsp.mason")
require("config.lsp.mason-install")
require("config.lsp.null-ls")
require("config.lsp.handlers").setup()

require("config.lsp.fidget")
require("config.lsp.hlargs")
require("config.lsp.inlayhints")
require("config.lsp.tabout")
require("config.lsp.lspsaga")

local status_1, lsp_lines = pcall(require, "lsp_lines")
if not status_1 then
  return
end

lsp_lines.setup()

return M
