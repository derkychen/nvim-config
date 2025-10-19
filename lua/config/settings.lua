-- <Leader> key
vim.g.mapleader = " "

-- Always show tabline
vim.opt.showtabline = 2

-- Indentation settings
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- Editor line numbers
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")

-- Code folding with Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.opt.foldcolumn = "0" -- change to 1 for next release
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- foldinner = " ", -- only available next release
  foldsep = " ",
}

vim.opt.autoread = true
