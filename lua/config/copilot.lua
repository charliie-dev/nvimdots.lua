local status, copilot = pcall(require, "copilot")
if not status then
  return
end

copilot.setup({
  cmp = {
    enabled = true,
    method = "getCompletionsCycling",
  },
  panel = { -- no config options yet
    enabled = true,
  },
  ft_disable = { "markdown", "terraform", "help" },
  plugin_manager_path = vim.fn.stdpath("data") .. "/site/pack/packer",
  -- plugin_manager_path = vim.env.HOME .. "/.config/nvim/plugged"
})
