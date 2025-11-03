-- <Leader> key
vim.g.mapleader = " "

-- Always show tabline
vim.opt.showtabline = 2

-- Editor line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- Indentation settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2

-- Indentation indicators
vim.opt.listchars:append({ leadmultispace = '│ ' })
vim.opt.list = true

-- Code folding with Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.opt.foldcolumn = "0" -- change to 1 for next release
vim.opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  --foldinner = " ", -- only available next release
  foldsep = " ",
}

