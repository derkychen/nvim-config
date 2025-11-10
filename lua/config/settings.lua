-- <Leader> key
vim.g.mapleader = " "

-- Always show tabline
vim.opt.showtabline = 2

-- Editor line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Line and column highlighting
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- Indentation settings
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Indentation indicators
local function update_leadmultispace()
  if not vim.wo.list then return end

  local sw = vim.bo.shiftwidth
  if sw == 0 then sw = vim.bo.tabstop end
  local s = "│" .. string.rep(" ", math.max(sw - 1, 0))

  local lc = vim.opt_local.listchars:get()
  if lc.leadmultispace ~= s then
    lc.leadmultispace = s
    vim.opt_local.listchars = lc
  end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  callback = update_leadmultispace,
})

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = update_leadmultispace,
})

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
