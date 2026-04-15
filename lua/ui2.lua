local ui2 = require("vim._core.ui2")

-- Enable UI2
ui2.enable({
  msg = {
    targets = "msg", -- Messages appear in a floating window at the bottom right
  },
})

-- Defensively load `cmdline` module
local ok, cmdline = pcall(require, "vim._core.ui2.cmdline")
if not ok then
  return
end

-- Floating command-line
-- Based on and many thanks to tiny-cmdline.nvim:
-- https://github.com/rachartier/tiny-cmdline.nvim
local cmdline_config = {
  width = {
    value = "60%",
    min = 40,
    max = 80,
  },
  position = {
    x = "50%",
    y = "50%",
  },
  border = vim.o.winborder,
  title = "Command-line",
  title_pos = "center",
  menu_col_offset = 3,
}

-- Construct `winhighlight` option from map of highlights
local function make_winhighlight(win_hl_map)
  local win_hls = {}
  for dest_hl, src_hl in pairs(win_hl_map) do
    table.insert(win_hls, dest_hl .. ":" .. src_hl)
  end
  return table.concat(win_hls, ",")
end

-- Highlights for floating command-line window
local cmdline_float_winhighlight = make_winhighlight({
  Normal = "CmdlineFloatNormal",
  FloatBorder = "CmdlineFloatBorder",
  Search = "None",
  CurSearch = "None",
  IncSearch = "None",
})

-- Highlights for regular command-line window
local cmdline_bottom_winhighlight = make_winhighlight({
  Normal = "CmdlineBottomNormal",
  FloatBorder = "CmdlineFloatBorder",
  Search = "None",
  CurSearch = "None",
  IncSearch = "None",
})

-- Determine dimension from percentage of available screen dimensions or number
-- of terminal cells
local function parse_dimension(value, available)
  if type(value) == "string" then
    return math.floor(available * tonumber(value:match("^(%d+)%%$")) / 100)
  end
  return math.floor(value)
end

-- Size and position of window
local function geometry(content_height)
  local cols, lines = vim.o.columns, vim.o.lines
  local b = (cmdline_config.border == "" or cmdline_config.border == "none")
      and 0
      or 1

  local width = math.max(
    cmdline_config.width.min,
    math.min(
      cmdline_config.width.max,
      parse_dimension(cmdline_config.width.value, cols)
    )
  )
  width = math.min(width, cols - 4)

  local row = math.max(
    0,
    parse_dimension(cmdline_config.position.y, lines - content_height - b * 2)
  )
  local col = math.max(
    0,
    parse_dimension(cmdline_config.position.x, cols - width - b * 2)
  )

  return width, row, col, b
end

-- State storing variables
local cmdline_type = nil ---@type string|nil
local original_ui_cmdline_pos = vim.g.ui_cmdline_pos ---@type table|nil
local orig_cmd_win_config = nil ---@type table|nil

local function get_cmd_win()
  if not ui2 then
    return
  end
  local win = ui2.wins and ui2.wins.cmd
  return (win and vim.api.nvim_win_is_valid(win)) and win or nil
end

local function reposition()
  if not cmdline_type then
    return
  end

  local win = get_cmd_win()
  if not win then
    return
  end

  if not orig_cmd_win_config then
    orig_cmd_win_config = vim.api.nvim_win_get_config(win)
  end

  vim.wo[win].winhighlight = cmdline_float_winhighlight

  local content_height = math.max(1, vim.api.nvim_win_get_height(win))
  local width, row, col, b = geometry(content_height)

  pcall(vim.api.nvim_win_set_config, win, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    title = cmdline_config.title,
    title_pos = cmdline_config.title_pos,
    border = cmdline_config.border,
  })

  -- `vim.g.ui_cmdline_pos` is used by blink.cmp for anchoring
  vim.g.ui_cmdline_pos = {
    row + b + 1,
    col + b + cmdline_config.menu_col_offset + 1,
  }
end

-- Wrap the `cmdline_show` function
local orig = cmdline.cmdline_show
cmdline.cmdline_show = function(...)
  local ret = orig(...)

  if not cmdline_type then
    return ret
  end
  reposition()

  return ret
end

local group =
    vim.api.nvim_create_augroup("UI2FloatingCmdline", { clear = true })

-- Set highlights on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "CmdlineFloatNormal", {
      fg = vim.api.nvim_get_hl(0, { name = "MsgArea" }).fg,
      bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg,
    })
    vim.api.nvim_set_hl(
      0,
      "CmdlineBottomNormal",
      { link = "MsgArea", default = true }
    )
    vim.api.nvim_set_hl(
      0,
      "CmdlineFloatBorder",
      { link = "FloatBorder", default = true }
    )
  end,
  group = group,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function()
    cmdline_type = vim.fn.getcmdtype()
  end,
  group = group,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function()
    cmdline_type = nil
    vim.g.ui_cmdline_pos = original_ui_cmdline_pos
    local win = get_cmd_win()
    if win and orig_cmd_win_config then
      pcall(vim.api.nvim_win_set_config, win, orig_cmd_win_config)
      vim.wo[win].winhighlight = cmdline_bottom_winhighlight
    end
  end,
  group = group,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = vim.schedule_wrap(reposition),
  group = group,
  pattern = "cmd",
})

vim.api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
  callback = vim.schedule_wrap(reposition),
  group = group,
})
