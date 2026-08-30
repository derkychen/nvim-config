---Local window option setting.
---
---Configures default local window options for normal, disk buffers.
local icons = require("icons")
local utils = require("utils")

local opts_initialized = {}

---Check if default local window options are initialized.
---
---@param win integer Neovim window identifier.
---@param buf integer Neovim buffer identifier.
---@return boolean initialized Whether local window options are initialized.
local function is_opts_initialized(win, buf)
  return opts_initialized[win] and opts_initialized[win][buf] or false
end

---Mark default local window options as initialized for a window and buffer.
---
---@param win integer Neovim window identifier.
---@param buf integer Neovim buffer identifier.
local function mark_opts_initialized(win, buf)
  opts_initialized[win] = opts_initialized[win] or {}
  opts_initialized[win][buf] = true
end

---Clear tracking of default local window options for a window.
---
---@param win integer Neovim window identifier.
local function clear_opts_initialized_win(win)
  opts_initialized[win] = nil
end

---Clear tracking of default local window options for a buffer.
---
---@param buf integer Neovim buffer identifier.
local function clear_opts_initialized_buf(buf)
  for win, bufs in pairs(opts_initialized) do
    bufs[buf] = nil

    if next(bufs) == nil then
      opts_initialized[win] = nil
    end
  end
end

---Set the local window options.
---
---@param win integer Neovim window identifier.
local function set_default_opts(win)
  local fillchars = table.concat({
    "fold: ",
    "foldopen:" .. icons.arrows.down,
    "foldclose:" .. icons.arrows.right,
    "foldinner: ",
    "foldsep: ",
  }, ",")
  local listchars = table.concat({
    "tab:↦ ",
    "trail:⋅",
    "extends:",
    "precedes:",
  }, ",")

  local default_opts_opts = {
    number = true,
    relativenumber = true,
    cursorline = true,
    cursorcolumn = true,
    scrolloff = 10,
    sidescrolloff = 10,
    virtualedit = "block",
    linebreak = true,
    breakindent = true,
    foldmethod = "expr",
    foldexpr = "v:lua.vim.treesitter.foldexpr()",
    foldtext = "",
    foldlevel = 99,
    foldcolumn = "1",
    fillchars = fillchars,
    list = true,
    listchars = listchars,
    spell = true,
  }

  for opt, val in pairs(default_opts_opts) do
    vim.api.nvim_set_option_value(opt, val, { win = win, scope = "local" })
  end
end

---Set `listchars` option as it should adapt to other changed options.
---
---If these options are set by others, they will be overridden every time an
---option listed in the `OptionSet` automatic command is set.
---
---@param win integer Neovim window identifier.
local function update_listchars(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local sw = vim.api.nvim_get_option_value("shiftwidth", { buf = buf })

  if sw == 0 then
    sw = vim.api.nvim_get_option_value("tabstop", { buf = buf })
  end

  -- Update `leadmultispace`.
  --
  -- NOTE: These indentation guides only show when spaces are used.
  local leadmultispace = "leadmultispace:"
    .. "│"
    .. string.rep(" ", math.max(sw - 1, 0))

  local listchars = vim.api.nvim_get_option_value("listchars", {
    win = win,
    scope = "local",
  })

  if listchars:find("leadmultispace:", 1, true) then
    listchars = listchars:gsub("leadmultispace:[^,]*", leadmultispace, 1)
  else
    if listchars ~= "" and not listchars:match(",$") then
      listchars = listchars .. ","
    end

    listchars = listchars .. leadmultispace
  end

  vim.api.nvim_set_option_value(
    "listchars",
    listchars,
    { win = win, scope = "local" }
  )
end

local local_win_opts_group =
  vim.api.nvim_create_augroup("WinLocalOptions", { clear = true })

-- Set all default window-local options for windows containing valid, normal
-- buffers from or written to disk.
--
-- TODO: Optimize once the ev.win field is implemented:
--       https://github.com/neovim/neovim/issues/25844
vim.api.nvim_create_autocmd({
  "BufWinEnter",
  "BufWritePost",
}, {
  callback = function(ev)
    for _, win in pairs(vim.fn.win_findbuf(ev.buf)) do
      local buf = vim.api.nvim_win_get_buf(win)

      if not utils.valid_normal_disk_buf(buf) then
        return
      end

      if not is_opts_initialized(win, buf) then
        set_default_opts(win)
        mark_opts_initialized(win, buf)
      end

      update_listchars(win)
    end
  end,
  group = local_win_opts_group,
})

-- Clean `opts_initialized` table on the closing of windows.
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    local win = tonumber(ev.match)

    if win then
      clear_opts_initialized_win(win)
    end
  end,
  group = local_win_opts_group,
})

-- Clean `opts_initialized` table on the closing of buffers.
vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
  callback = function(ev)
    clear_opts_initialized_buf(ev.buf)
  end,
  group = local_win_opts_group,
})

-- Refresh `listchars` option.
--
-- Iterates over all windows since `OptionSet` does not provide an `ev.buf`.
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "shiftwidth", "tabstop", "list" },
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)

      if utils.valid_normal_disk_buf(buf) then
        update_listchars(win)
      end
    end
  end,
  group = local_win_opts_group,
})
