---Set up global options.
---
---These options are applied globally. However, these options can be window- or
---buffer-local.
vim.g.mapleader = ' '
vim.o.confirm = true
vim.o.foldopen = ''
vim.o.laststatus = 3
vim.o.smarttab = true

-- Match floating window and PopUp menu borders to both be rounded.
vim.o.winborder = 'rounded'
vim.o.pumborder = vim.o.winborder

-- PopUp menu dimensions.
vim.o.pumheight = 10
vim.o.pummaxwidth = 60

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
