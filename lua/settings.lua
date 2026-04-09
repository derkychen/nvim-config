local icons = require("icons")
local utils = require("utils")

-- Enable UI2
require("vim._core.ui2").enable()

-- <Leader> key
vim.g.mapleader = " "

-- Global UI options
vim.o.laststatus = 3
vim.o.winborder = "rounded"

-- Global buffer indentation options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true

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

-- Generate window-local options
local function winlocal_opts(winid)
  local buf = vim.api.nvim_win_get_buf(winid)

  local sw = vim.api.nvim_get_option_value("shiftwidth", { buf = buf })
  if sw == 0 then sw = vim.api.nvim_get_option_value("tabstop", { buf = buf }) end

  return {
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
    foldlevel = 99,
    foldcolumn = "1",

    -- Window UI icons and characters
    fillchars = "fold: ,"
        .. "foldopen:" .. icons.arrows.down .. ","
        .. "foldclose:" .. icons.arrows.right .. ","
        .. "foldinner: ,"
        .. "foldsep: ,",
    list = true,
    listchars = "tab:↦ ,"
        .. "leadmultispace:" .. "│" .. string.rep(" ", math.max(sw - 1, 0)) .. ","
        .. "trail:⋅,"
        .. "precedes:,"
        .. "extends:,",
  }
end

-- Set window-local options
local function set_winlocal_opts(win)
  for opt, val in pairs(winlocal_opts(win)) do
    vim.api.nvim_set_option_value(opt, val, {
      win = win,
      scope = "local",
    })
  end
end

-- Decide what windows to apply window-local options for
local function apply_winlocal_opts()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if utils.valid_normal_buf(buf) then
      set_winlocal_opts(win)
    end
  end
end

-- Set window-local options when buffer is enters a window
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = apply_winlocal_opts,
})

-- Adapt window-local options when relevant options are set
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = apply_winlocal_opts,
})
