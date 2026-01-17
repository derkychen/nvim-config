local icons = require("icons")
local utils = require("utils")

-- <Leader> key
vim.g.mapleader = " "

-- Indentation settings
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true

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
local function winopts(winid)
  local buf = vim.api.nvim_win_get_buf(winid)

  local sw = vim.bo[buf].shiftwidth
  if sw == 0 then sw = vim.bo[buf].tabstop end

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

    fillchars = "fold: ,"
        .. "foldopen:" .. icons.arrows.down .. ","
        .. "foldclose:" .. icons.arrows.right .. ","
        -- .. "foldinner: ," -- only available next release
        .. "foldsep: ,",

    list = true,
    listchars = "tab:↦ ,"
        .. "leadmultispace:" .. "│" .. string.rep(" ", math.max(sw - 1, 0)) .. ","
        .. "trail:⋅,",
  }
end

-- Set window-local options
local function set_winlocal(winid)
  for opt, val in pairs(winopts(winid)) do
    vim.api.nvim_set_option_value(opt, val, {
      win = winid,
      scope = "local",
    })
  end
end

-- Decide what windows to apply window-local options for
local function apply_winlocal()
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(winid)
    if utils.valid_normal_buf(buf) then
      set_winlocal(winid)
    end
  end
end

-- Set window-local options when buffer is shown in window, and when filetype is set
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  callback = apply_winlocal,
})

-- Adapt window-local options when relevant options are set
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = apply_winlocal,
})
