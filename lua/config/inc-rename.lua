local status, inc_rename = pcall(require, "inc_rename")
if not status then
  print("inc_rename is not installed!")
  return
end

inc_rename.setup({
  cmd_name = "IncRename", -- the name of the command
  hl_group = "Substitute", -- the highlight group used for highlighting the identifier's new name
  preview_empty_name = false, -- whether an empty new name should be previewed; if false the command preview will be cancelled instead
  multifile_preview = true, -- whether to enable the command preview across multiple buffers
  show_message = true, -- whether to display a `Renamed m instances in n files` message after a rename operation
  post_hook = nil, -- callback to run after renaming, receives the result table (from LSP handler) as an argument
})
