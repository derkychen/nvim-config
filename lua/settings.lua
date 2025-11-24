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

-- Window-local options
local winopts = {
  -- Statuscolumn structure
  statuscolumn = "%s %l %C ",

  -- Editor line numbers
  number = true,
  relativenumber = true,

  -- Line and column highlighting
  cursorline = true,
  cursorcolumn = true,

  -- Line wrap at words
  linebreak = true,

  -- Code folding with Treesitter
  foldmethod = "expr",
  foldexpr = "v:lua.vim.treesitter.foldexpr()",
  foldtext = "",
  foldenable = true,
  foldlevel = 99,
  foldcolumn = "1",

  fillchars = {
    fold = " ",
    foldopen = "",
    foldclose = "",
    -- foldinner = " ", -- only available next release
    foldsep = " ",
  },

  list = true,
}

-- Set listchars
local function set_listchars()
  if not vim.wo.list then
    return
  end

  local sw = vim.bo.shiftwidth
  if sw == 0 then
    sw = vim.bo.tabstop
  end

  vim.opt_local.listchars = {
    trail = "⋅",
    tab = "↦ ",
    leadmultispace = "│" .. string.rep(" ", math.max(sw - 1, 0)),
  }
end

-- Check if valid for setting window-local options
local function valid_buffer()
  return vim.bo.buftype == "" and vim.bo.buflisted
end

local function set_winlocal()
  if valid_buffer() then
    for opt, val in pairs(winopts) do
      vim.opt_local[opt] = val
    end
    set_listchars()
  end
end

-- Set window-local options
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = set_winlocal,
})

-- Adapt listchars when relevant options are set
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = function()
    if valid_buffer() then
      set_listchars()
    end
  end,
})
