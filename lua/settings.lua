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

-- Set static window-local options
local function set_static_winlocal_opts(win)
  local static_winlocal_opts = {
    number = true,                                -- Current line number
    relativenumber = true,                        -- Relative line numbers

    cursorline = true,                            -- Highlight current line
    cursorcolumn = true,                          -- Highlight current column

    linebreak = true,                             -- Wrap lines at words
    breakindent = true,                           -- Indent wrapped lines

    foldmethod = "expr",                          -- Custom code folding
    foldexpr = "v:lua.vim.treesitter.foldexpr()", -- Fold code with Tree-sitter
    foldtext = "",                                -- No text for closed fold
    foldlevel = 99,                               -- Allow 99 levels of nesting
    foldcolumn = "1",                             -- Width of fold column

    fillchars =
        "fold: ," ..                                 -- Fill closed fold
        "foldopen:" .. icons.arrows.down .. "," ..   -- Arrow for opened fold
        "foldclose:" .. icons.arrows.right .. "," .. -- Arrow for closed fold
        "foldinner: ," ..                            -- No foldlevel indicator
        "foldsep: ,",                                -- No open fold indicator

    list = true,                                     -- Show blank characters
  }

  for opt, val in pairs(static_winlocal_opts) do
    vim.api.nvim_set_option_value(opt, val, { win = win, scope = "local" })
  end
end

-- Set adaptive window-local options
local function set_adaptive_winlocal_opts(win)
  local buf = vim.api.nvim_win_get_buf(win)

  local sw = vim.api.nvim_get_option_value("shiftwidth", { buf = buf })
  if sw == 0 then
    sw = vim.api.nvim_get_option_value("tabstop", { buf = buf })
  end

  local adaptive_winlocal_opts = {
    listchars =
        "eol:󰌑," .. -- End of line
        "tab:↦ ," .. -- Tab character

        -- Compute indentation indicators for spaces only
        "leadmultispace:" .. "│" .. string.rep(
          " ", math.max(sw - 1, 0)
        ) .. "," ..

        "trail:⋅," .. -- Trailing spaces
        "extends:," .. -- Hidden right columns when line wrapping is off
        "precedes:,", -- Hidden left columns when line wrapping is off
  }

  for opt, val in pairs(adaptive_winlocal_opts) do
    vim.api.nvim_set_option_value(opt, val, { win = win, scope = "local" })
  end
end

-- Track windows whose default local options have been set
local initialized = {}

local function mark_initialized(win, buf)
  initialized[win] = initialized[win] or {}
  initialized[win][buf] = true
end

local function is_initialized(win, buf)
  return initialized[win] and initialized[win][buf] or false
end

local function clear_win(win)
  initialized[win] = nil
end

local function clear_buf(buf)
  for win, bufs in pairs(initialized) do
    bufs[buf] = nil
    if next(bufs) == nil then
      initialized[win] = nil
    end
  end
end

local winlocal_opts_group = vim.api.nvim_create_augroup("WindowLocalOptions",
  { clear = true })

-- TODO: Optimize once the ev.win field is implemented:
-- https://github.com/neovim/neovim/issues/23581
-- Set all default window-local options for windows containing valid, normal
-- buffers
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(ev)
    for _, win in pairs(vim.fn.win_findbuf(ev.buf)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if not utils.valid_normal_buf(buf) then
        return
      end
      if not is_initialized(win, buf) then
        set_static_winlocal_opts(win)
        mark_initialized(win, buf)
      end
      set_adaptive_winlocal_opts(win)
    end
  end,
  group = winlocal_opts_group,
})

-- Refresh adaptive window-local options for all windows since OptionSet does
-- not provide an `ev.buf`.
vim.api.nvim_create_autocmd("OptionSet", {
  group = winlocal_opts_group,
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if utils.valid_normal_buf(buf) then
        set_adaptive_winlocal_opts(win)
      end
    end
  end,
})

-- Clean `initialized` table on the closing of windows and buffers
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    local win = tonumber(ev.match)
    if win then
      clear_win(win)
    end
  end,
  group = winlocal_opts_group,
})

vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
  callback = function(ev)
    clear_buf(ev.buf)
  end,
  group = winlocal_opts_group,
})
