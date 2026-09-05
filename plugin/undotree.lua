--- Configuration for the built-in undo tree plugin.
---
--- Lazy-loads the undo tree.

--- Toggles the undo tree in a floating window.
local function toggle_undotree()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Close undo tree if it is open.
  local undotree_win = vim.b[current_buf].nvim_undotree
    or vim.b[current_buf].nvim_is_undotree

  if undotree_win and vim.api.nvim_win_is_valid(undotree_win) then
    vim.cmd.Undotree()
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local source_win = vim.api.nvim_get_current_win()
  local win_config = require('utils').se_small_win_config(source_win)

  -- Floating window at the bottom-left of the source window, slightly inset.
  local win = vim.api.nvim_open_win(buf, false, win_config)

  require('undotree').open({ winid = win })

  vim.api.nvim_set_current_win(win)
end

-- Lazy-load `nvim-autopairs` when a buffer is entered.
require('lazyload').register({
  augroup_name = 'UndoTreeLazyLoad',
  events = 'BufEnter',
  name = 'nvim.undotree',
  config = function()
    vim.keymap.set(
      'n',
      '<leader>u',
      toggle_undotree,
      { desc = 'Toggle undotree' }
    )
  end,
})
