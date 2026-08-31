---Configuration for my sessions module.
local sessions = require('sessions')

-- Keymaps.
vim.keymap.set(
  'n',
  '<Leader>ss',
  sessions.save_current,
  { desc = 'Save current session' }
)
vim.keymap.set(
  'n',
  '<Leader>sa',
  sessions.save_select,
  { desc = 'Select a name to save current session to' }
)
vim.keymap.set(
  'n',
  '<Leader>sl',
  sessions.load_select,
  { desc = 'Select session to load' }
)
vim.keymap.set(
  'n',
  '<Leader>sx',
  sessions.delete_current,
  { desc = 'Delete current session' }
)
vim.keymap.set(
  'n',
  '<Leader>sd',
  sessions.delete_select,
  { desc = 'Select session to delete' }
)
vim.keymap.set(
  'n',
  '<Leader>sr',
  sessions.rename_current,
  { desc = 'Rename current session' }
)
vim.keymap.set(
  'n',
  '<Leader>sc',
  sessions.rename_select,
  { desc = 'Select session to rename' }
)
