-- Default values
vim.g.conflict_marker_begin = "^<<<<<<< \\@="
vim.g.conflict_marker_common_ancestors = "^||||||| .*$"
vim.g.conflict_marker_separator = "^=======$"
vim.g.conflict_marker_end = "^>>>>>>> \\@="
vim.g.conflict_marker_enable_highlight = 1

vim.g.conflict_marker_highlight_group = 'Error'

-- highlight ConflictMarkerBegin guibg=#2f7366
-- highlight ConflictMarkerOurs guibg=#2e5049
-- highlight ConflictMarkerTheirs guibg=#344f69
-- highlight ConflictMarkerEnd guibg=#2f628e
-- highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81

-- Default mapping
-- `[x` & `x]` to jump to conflict marker
