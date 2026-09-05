--- Tab page functionality.
---
--- Provides keymaps for opening and closing tab pages.

--- Closes the current tab.
local function close_current()
  if vim.fn.tabpagenr('$') > 1 then
    vim.cmd.tabclose()
  else
    vim.api.nvim_cmd({
      cmd = 'qa',
      mods = {
        confirm = true,
      },
    }, {})
  end
end

-- Keymaps.
vim.keymap.set('n', '<Leader>tn', vim.cmd.tabnew, {})
vim.keymap.set('n', '<Leader>tx', close_current, {})
