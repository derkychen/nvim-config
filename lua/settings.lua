local icons = require("icons")

-- <Leader> key
vim.g.mapleader = " "

-- Always show tabline
vim.opt.showtabline = 2

-- Indentation settings
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true

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

-- Window-local options
local winopts = {
  -- Statuscolumn structure
  statuscolumn = " %s%l %C ",

  -- Editor line numbers
  number = true,
  relativenumber = true,

  -- Line and column highlighting
  cursorline = true,
  cursorcolumn = true,

  -- Line wrap at words, match indent
  linebreak = true,
  breakindent = true,

  -- Code folding with Treesitter
  foldmethod = "expr",
  foldexpr = "v:lua.vim.treesitter.foldexpr()",
  foldtext = "",
  foldenable = true,
  foldlevel = 99,
  foldcolumn = "1",

  fillchars = {
    fold = " ",
    foldopen = icons.arrows.down,
    foldclose = icons.arrows.right,
    -- foldinner = " ", -- only available next release
    foldsep = " ",
  },

  list = true,
}

-- Set listchars
local function set_listchars()
  if vim.bo.buftype == "" and vim.wo.list then
    local sw = vim.bo.shiftwidth
    if sw == 0 then
      sw = vim.bo.tabstop
    end
    vim.opt_local.listchars = {
      tab = "↦ ",
      leadmultispace = "│" .. string.rep(" ", math.max(sw - 1, 0)),
      trail = "⋅",
    }
  end
end

-- Set window-local options
local function set_winlocal()
  --if vim.bo.buftype == "" then
    for opt, val in pairs(winopts) do
      vim.opt_local[opt] = val
    end
  --end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = set_winlocal,
})

-- Set listchars after filetype is set
vim.api.nvim_create_autocmd("FileType", {
  callback = set_listchars,
})

-- Adapt listchars when relevant options are set
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = set_listchars,
})

