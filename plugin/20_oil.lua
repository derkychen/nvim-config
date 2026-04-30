vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

local oil = require("oil")

local opts = {
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
  win_options = {
    conceallevel = 0,
    cursorline = true,
    cursorcolumn = true,
  },
  watch_for_changes = true,
  view_options = {
    show_hidden = true,
  },
}

oil.setup(opts)

vim.keymap.set("n", "<Leader>eo", oil.open, { desc = "Open Oil" })

-- Open Oil on a new tab page
local oil_open_group = vim.api.nvim_create_augroup("OilOpen", { clear = true })

vim.api.nvim_create_autocmd("TabNew", {
  callback = function()
    vim.schedule(function()
      local win = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
      local modified = vim.api.nvim_get_option_value("modified", { buf = buf })
      local line_count = vim.api.nvim_buf_line_count(buf)

      if name == "" and buftype == "" and not modified and line_count <= 1 then
        oil.open(vim.fn.getcwd())
      end
    end)
  end,
  group = oil_open_group,
})
