local icons = require("icons")

-- <Leader> key
vim.g.mapleader = " "

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

-- Window-local options for windows onto buffers loaded from disk
local file_winopts = {
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
  listchars = function(win_id)
    local sw = vim.bo.shiftwidth
    if sw == 0 then sw = vim.bo.tabstop end
    return {
      tab = "↦ ",
      leadmultispace = "│" .. string.rep(" ", math.max(sw - 1, 0)),
      trail = "⋅",
    }
  end,
}

-- Set window-local options
local function set_winlocal(win_id, winopts)
  vim.api.nvim_win_call(win_id, function()
    for opt, val in pairs(winopts) do
      if type(val) == "function" then
        val = val(win_id)
      end
      vim.opt_local[opt] = val
    end
  end)
end

-- Decide what window-local options to apply
local function apply_winlocal(buf)
  local buf_name = vim.api.nvim_buf_get_name(buf)

  -- Apply window-local options for files if buffer in window is from disk
  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and buf_name ~= "" and buf_name ~= nil then
    set_winlocal(vim.api.nvim_get_current_win(), file_winopts)
  end
end

-- Set window-local options when buffer is shown in window, and when filetype is set
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  callback = function(ev) apply_winlocal(ev.buf) end,
})

-- Adapt window-local options when relevant options are set
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = function(ev) apply_winlocal(ev.buf) end,
})
