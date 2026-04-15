local ui2 = require("vim._core.ui2")

-- Enable UI2
ui2.enable({
  msg = {
    targets = "msg", -- Messages appear in a floating window at the bottom right
  },
})

-- Floating command-line
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

local cmdline_type = nil
local original_ui_cmdline_pos = vim.g.ui_cmdline_pos
local cmd_win_saved = nil
local wrapped = false

local function get_blink_anchor(row, col, content_height, border, offset)
  local popup_col = col + border + offset
  local below_row = row + content_height + border * 2
  local above_row = math.max(0, row + border)

  local space_below = vim.o.lines - below_row
  local space_above = row

  if space_below >= 8 or space_below >= space_above then
    return { below_row, popup_col }
  end

  return { above_row, popup_col }
end

local function parse_dimension(value, available)
  if type(value) == "string" then
    local pct = tonumber(value:match("^(%d+)%%$"))
    if pct then
      return math.floor(available * pct / 100)
    end
  end
  return math.floor(value)
end

local function geometry(content_height)
  local cols, lines = vim.o.columns, vim.o.lines
  local b = cmdline_config.border == "" and 0 or 1

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

local function get_cmd_win()
  if not ui2 then
    return
  end
  local win = ui2.wins and ui2.wins.cmd
  return (win and vim.api.nvim_win_is_valid(win)) and win or nil
end

local function reposition_blink()
  local ok, menu = pcall(require, "blink.cmp.completion.windows.menu")
  if ok and menu.win and menu.win:is_open() then
    pcall(menu.update_position)
  end

  local ok_docs, docs =
      pcall(require, "blink.cmp.completion.windows.documentation")
  if ok_docs and docs.win and docs.win:is_open() then
    pcall(docs.update_position)
  end
end

local function make_winhighlight(map)
  local parts = {}

  for from, to in pairs(map) do
    parts[#parts + 1] = ("%s:%s"):format(from, to)
  end

  table.sort(parts)
  return table.concat(parts, ",")
end

local cmdline_float_winhighlight = make_winhighlight({
  Normal = "CmdlineFloatNormal",
  FloatBorder = "CmdlineFloatBorder",
  Search = "None",
  CurSearch = "None",
  IncSearch = "None",
})

local cmdline_bottom_winhighlight = make_winhighlight({
  Normal = "CmdlineBottomNormal",
  FloatBorder = "CmdlineFloatBorder",
  Search = "None",
  CurSearch = "None",
  IncSearch = "None",
})

local function reposition()
  if not cmdline_type then
    return
  end

  local win = get_cmd_win()
  if not win then
    return
  end

  if not cmd_win_saved then
    local cfg = vim.api.nvim_win_get_config(win)
    cmd_win_saved = {
      anchor = cfg.anchor,
      border = cfg.border,
      col = cfg.col,
      relative = cfg.relative,
      row = cfg.row,
      title = cfg.title,
      title_pos = cfg.title_pos,
      width = cfg.width,
    }
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

  -- completion popup anchor used by blink
  vim.g.ui_cmdline_pos = get_blink_anchor(
    row,
    col,
    content_height,
    b,
    cmdline_config.menu_col_offset
  )

  reposition_blink()
end

local function wrap_cmdline_show()
  if wrapped then
    return
  end

  local ok, cmdline = pcall(require, "vim._core.ui2.cmdline")
  if not ok then
    return
  end

  local orig = cmdline.cmdline_show
  cmdline.cmdline_show = function(...)
    local ret = orig(...)

    if not cmdline_type then
      return ret
    end
    reposition()

    return ret
  end

  wrapped = true
end

local function wrap_and_reposition()
  wrap_cmdline_show()
  reposition()
end

local function set_hls()
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
end

local group =
    vim.api.nvim_create_augroup("UI2FloatingCmdline", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_hls,
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
    if win and cmd_win_saved then
      pcall(vim.api.nvim_win_set_config, win, cmd_win_saved)
      vim.wo[win].winhighlight = cmdline_bottom_winhighlight
    end
  end,
  group = group,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = vim.schedule_wrap(wrap_and_reposition),
  group = group,
  pattern = "cmd",
})

vim.api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
  callback = vim.schedule_wrap(reposition),
  group = group,
})
