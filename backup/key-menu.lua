local status, km = pcall(require, "key-menu")
if (not status) then
  return
end

km.set("n", "<Space>")
km.set("n", "g")

-- For surround.nvim
km.set("n", "c")
