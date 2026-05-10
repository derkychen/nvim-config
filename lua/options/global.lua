local M = {}

function M.setup()
  -- Use Space as <Leader> key
  vim.g.mapleader = " "

  -- UI options
  vim.o.laststatus = 3
  vim.o.winborder = "rounded"

  -- Editing
  vim.o.smarttab = true
end

return M
