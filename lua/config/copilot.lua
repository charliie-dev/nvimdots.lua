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
  -- Use this field to provide the path to a specific node version such as one installed by nvm. Node version must be < 18.
  -- copilot_node_command = vim.fn.expand("$HOME") .. "/tools/nodejs/bin/node",
})

