---Configuration for built-in diagnostic functionality.
local icons = require('icons')

-- Set diagnostic icons.
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
    },
  },
})

-- Keymaps.
vim.keymap.set(
  'n',
  '<Leader>do',
  vim.diagnostic.open_float,
  { noremap = true, silent = true, desc = 'Open diagnostics' }
)
vim.keymap.set('n', '<Leader>dt', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })
