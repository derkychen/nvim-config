local icons = require("icons")
local utils = require("utils")

-- <Leader> key
vim.g.mapleader = " "

-- Global UI options
vim.o.laststatus = 3
vim.o.winborder = "rounded"

-- UI2 (experimental feature) settings and setup
require("ui2").config()

-- Editing
vim.o.smarttab = true

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

-- Set default buffer-local options
local function set_default_buflocal_opts(buf)
  local default_buflocal_opts = {
    expandtab = true,                     -- Convert tabs to spaces
    tabstop = 2,                          -- Columns per tab
    softtabstop = 2,                      -- Columns per soft tab stop
    shiftwidth = 2,                       -- Columns per indentation level
    autoindent = true,                    -- Copy previous indent on new line
    spelllang = "en_ca",                  -- Spelling language and locale
    spelloptions = "camel,noplainbuffer", -- Handle camel casing and syntax
  }

  for opt, val in pairs(default_buflocal_opts) do
    vim.api.nvim_set_option_value(opt, val, { buf = buf, scope = "local" })
  end
end

-- Track buffers whose default local options have been set
local buflocal_initialized = {}

local function mark_buflocal_initialized(buf)
  buflocal_initialized[buf] = true
end

local function is_buflocal_initialized(buf)
  return buflocal_initialized[buf] or false
end

local function clear_buflocal_initialized(buf)
  buflocal_initialized[buf] = nil
end

-- Set default window-local options
local function set_default_winlocal_opts(win)
  local default_winlocal_opts = {
    number = true,                                   -- Current line number
    relativenumber = true,                           -- Relative line numbers
    cursorline = true,                               -- Highlight current line
    cursorcolumn = true,                             -- Highlight current column
    virtualedit = "block",                           -- Visual-block past text
    linebreak = true,                                -- Wrap lines at words
    breakindent = true,                              -- Indent wrapped lines
    foldmethod = "expr",                             -- Custom code folding
    foldexpr = "v:lua.vim.treesitter.foldexpr()",    -- Fold with Tree-sitter
    foldtext = "",                                   -- No text for closed fold
    foldlevel = 99,                                  -- Maximum nested folds
    foldcolumn = "1",                                -- Width of fold column
    fillchars =
        "fold: ," ..                                 -- Fill closed fold
        "foldopen:" .. icons.arrows.down .. "," ..   -- Arrow for opened fold
        "foldclose:" .. icons.arrows.right .. "," .. -- Arrow for closed fold
        "foldinner: ," ..                            -- No nesting level number
        "foldsep: ,",                                -- No open fold indicator
    list = true,
    listchars =
        "tab:↦ ," .. -- Tab character
        "trail:⋅," .. -- Trailing spaces
        "extends:," .. -- Line continuing to the right when line wrapping off
        "precedes:,", -- Line continuing to the left when line wrapping off
    spell = true, -- Enable spell-check
  }

  for opt, val in pairs(default_winlocal_opts) do
    vim.api.nvim_set_option_value(opt, val, { win = win, scope = "local" })
  end
end

-- Set adaptive window-local options: If these options are set by others, they
-- will be overridden every time an option listed in the `OptionSet` automatic
-- command is set
local function set_adaptive_override_winlocal_opts(win)
  local buf = vim.api.nvim_win_get_buf(win)

  -- Update `leadmultispace` (only for indentation with spaces)
  local sw = vim.api.nvim_get_option_value("shiftwidth", { buf = buf })
  if sw == 0 then
    sw = vim.api.nvim_get_option_value("tabstop", { buf = buf })
  end
  local leadmultispace =
      "leadmultispace:" .. "│" .. string.rep(" ", math.max(sw - 1, 0))

  local listchars = vim.api.nvim_get_option_value("listchars", {
    win = win,
    scope = "local",
  })

  -- Replace or append `leadmultispace`
  if listchars:find("leadmultispace:", 1, true) then
    listchars = listchars:gsub("leadmultispace:[^,]*", leadmultispace, 1)
  else
    if listchars ~= "" and not listchars:match(",$") then
      listchars = listchars .. ","
    end
    listchars = listchars .. leadmultispace
  end

  vim.api.nvim_set_option_value("listchars", listchars,
    { win = win, scope = "local" })
end

-- Track windows whose default local options have been set
local winlocal_initialized = {}

local function mark_winlocal_initialized(win, buf)
  winlocal_initialized[win] = winlocal_initialized[win] or {}
  winlocal_initialized[win][buf] = true
end

local function is_winlocal_initialized(win, buf)
  return winlocal_initialized[win] and winlocal_initialized[win][buf] or false
end

local function clear_winlocal_initialized_win(win)
  winlocal_initialized[win] = nil
end

local function clear_winlocal_initialized_buf(buf)
  for win, bufs in pairs(winlocal_initialized) do
    bufs[buf] = nil
    if next(bufs) == nil then
      winlocal_initialized[win] = nil
    end
  end
end

local local_opts_group = vim.api.nvim_create_augroup("LocalOptions",
  { clear = true })

-- Set all default buffer-local options for valid, normal buffers
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function(ev)
    local buf = ev.buf
    if not is_buflocal_initialized(buf) then
      set_default_buflocal_opts(buf)
      mark_buflocal_initialized(buf)
    end
  end,
  group = local_opts_group,
})

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
      if not is_winlocal_initialized(win, buf) then
        set_default_winlocal_opts(win)
        mark_winlocal_initialized(win, buf)
      end
      set_adaptive_override_winlocal_opts(win)
    end
  end,
  group = local_opts_group,
})

-- Refresh adaptive window-local options for all windows since `OptionSet` does
-- not provide an `ev.buf`
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if utils.valid_normal_buf(buf) then
        set_adaptive_override_winlocal_opts(win)
      end
    end
  end,
  group = local_opts_group,
})

-- Clean `winlocal_initialized` table on the closing of windows
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    local win = tonumber(ev.match)
    if win then
      clear_winlocal_initialized_win(win)
    end
  end,
  group = local_opts_group,
})

-- Clean `buflocal_initialized` and winlocal_initialized` tables on the closing
-- of buffers
vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
  callback = function(ev)
    local buf = ev.buf
    clear_winlocal_initialized_buf(buf)
    clear_buflocal_initialized(buf)
  end,
  group = local_opts_group,
})
