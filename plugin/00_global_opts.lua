--- Sets up global options.
---
--- These options are applied globally. However, these options can be window- or
--- buffer-local.
vim.g.mapleader = ' '
vim.o.confirm = true
vim.o.foldopen = ''
vim.o.laststatus = 3
vim.o.smarttab = true

-- Match floating window and popup menu borders to both be rounded.
vim.o.winborder = 'single'
vim.o.pumborder = vim.o.winborder

-- Popup menu dimensions.
vim.o.pumwidth = 0
vim.o.pummaxwidth = 60
vim.o.pumheight = 10

-- Autocomplete settings.
vim.o.wildmode = 'noselect:full'
vim.o.wildoptions = table.concat({
  'pum',
  'fuzzy',
}, ',')
vim.o.completeopt = table.concat({
  'menuone',
  'noinsert',
  'fuzzy',
  'popup',
}, ',')
