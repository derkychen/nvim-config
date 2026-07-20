local icons = require("icons")

local M = {}

function M.setup()
  -- Configure diagnostic icons.
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.ERROR,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.WARN,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.INFO,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.HINT,
      },
    },
  })

  vim.keymap.set("n", "<Leader>do", vim.diagnostic.open_float,
    { noremap = true, silent = true, desc = "Open diagnostic" })
  vim.keymap.set("n", "<Leader>dt",
    function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
    { desc = "Toggle diagnostics" })
end

return M
