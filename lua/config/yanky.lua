local status, yanky = pcall(require, "yanky")
if not status then
  return
end

yanky.setup({
  ring = {
    history_length = 10,
    storage = "shada",
    sync_with_numbered_registers = true,
  },
  picker = {
    select = {
      action = nil, -- nil to use default put action
    },
    telescope = {
      mappings = nil, -- nil to use default mappings
    },
  },
  system_clipboard = {
    sync_with_ring = true,
  },
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
  preserve_cursor_position = {
    enabled = true,
  },
})
