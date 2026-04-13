require("ui2")

local icons = require("icons")
local utils = require("utils")

-- <Leader> key
vim.g.mapleader = " "

-- Global UI options
vim.o.laststatus = 3
vim.o.winborder = "rounded"

-- Global diagnostic icons
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

-- Global buffer indentation options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true

-- Generate window-local options
local function winlocal_opts(win)
  local buf = vim.api.nvim_win_get_buf(win)

  local sw = vim.api.nvim_get_option_value("shiftwidth", { buf = buf })
  if sw == 0 then
    sw = vim.api.nvim_get_option_value("tabstop", { buf = buf })
  end

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
      .. "foldopen:"
      .. icons.arrows.down
      .. ","
      .. "foldclose:"
      .. icons.arrows.right
      .. ","
      .. "foldinner: ,"
      .. "foldsep: ,",
    list = true,
    listchars = "tab:↦ ," .. "leadmultispace:" .. "│" .. string.rep(
      " ",
      math.max(sw - 1, 0)
    ) .. "," .. "trail:⋅," .. "precedes:," .. "extends:,",
  }
end

-- Set window-local options for windows containing valid, normal buffers
-- TODO: Optimize once the ev.win field is implemented:
-- https://github.com/neovim/neovim/issues/23581
local function set_winlocal_opts()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if utils.valid_normal_buf(buf) then
      for opt, val in pairs(winlocal_opts(win)) do
        vim.api.nvim_set_option_value(opt, val, {
          win = win,
          scope = "local",
        })
      end
    end
  end
end

-- Apply window-local options when a buffer is displayed in a window, or when
-- relevant options are set
local winlocal_opts_group =
  vim.api.nvim_create_augroup("WindowLocalOptions", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = set_winlocal_opts,
  group = winlocal_opts_group,
})

vim.api.nvim_create_autocmd("OptionSet", {
  callback = set_winlocal_opts,
  group = winlocal_opts_group,
  pattern = { "shiftwidth", "tabstop", "list" },
})
