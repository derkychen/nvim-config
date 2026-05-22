local M = {}

function M.setup()
  vim.g.mapleader = " "       -- Use Space as <Leader> key
  vim.o.confirm = true        -- Confirm operations that would normally fail
  vim.o.laststatus = 3        -- Global status line
  vim.o.winborder = "rounded" -- Rounded floating window borders
  vim.o.pumborder = "rounded" -- Rounded popupmenu window borders
  vim.o.smarttab = true       -- Insert tabs smartly
end

return M
