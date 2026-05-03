local icons = require("icons")

-- Use Space as <Leader> key
vim.g.mapleader = " "

-- UI options
vim.o.laststatus = 3
vim.o.winborder = "rounded"


-- Editing
vim.o.smarttab = true

-- Diagnostic icons
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

