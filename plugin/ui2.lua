---UI2 setup and floating command-line.
---
---Based on and thanks to Raphaël Chartier's tiny-cmdline.nvim:
---https://github.com/rachartier/tiny-cmdline.nvim
local ui2 = require('vim._core.ui2')
local cmdline = require('vim._core.ui2.cmdline')
local utils = require('utils')

local orig_cmd_win_config

---Get command-line window ID.
---
---@return integer|nil win Window ID of the command-line if it is valid.
local function get_cmdline_win()
  local win = ui2.wins.cmd

  return (win and vim.api.nvim_win_is_valid(win)) and win or nil
end

---Construct `winhighlight` option from map of highlights.
---
---@param win_hl_map table<string, string> Table of window highlights.
---@return string winhighlight Neovim `winhighlight` option.
local function make_winhighlight(win_hl_map)
  local win_hls = {}

  for dest_hl, src_hl in pairs(win_hl_map) do
    table.insert(win_hls, dest_hl .. ':' .. src_hl)
  end

  return table.concat(win_hls, ',')
end

-- Highlights for floating command-line window.
local cmdline_float_winhighlight = make_winhighlight({
  Normal = 'CmdlineFloatNormal',
  FloatBorder = 'CmdlineFloatBorder',
  Search = 'None',
  CurSearch = 'None',
  IncSearch = 'None',
})

-- Highlights for regular command-line window.
local cmdline_regular_winhighlight = make_winhighlight({
  Normal = 'CmdlineNormal',
  Search = 'None',
  CurSearch = 'None',
  IncSearch = 'None',
})

---Set command-line highlights.
local function set_hls()
  vim.api.nvim_set_hl(0, 'CmdlineFloatNormal', {
    fg = vim.api.nvim_get_hl(0, { name = 'MsgArea' }).fg,
    bg = vim.api.nvim_get_hl(0, { name = 'NormalFloat' }).bg,
  })
  vim.api.nvim_set_hl(0, 'CmdlineNormal', { link = 'MsgArea', default = true })
  vim.api.nvim_set_hl(
    0,
    'CmdlineFloatBorder',
    { link = 'FloatBorder', default = true }
  )
end

---Float the command-line window.
local function float_cmdline()
  local win = get_cmdline_win()

  if not win then
    return
  end

  -- Store original window configuration.
  if not orig_cmd_win_config then
    orig_cmd_win_config = vim.api.nvim_win_get_config(win)
  end

  vim.api.nvim_set_option_value('winfixbuf', true, { win = win })
  vim.api.nvim_set_option_value('wrap', false, { win = win })
  vim.api.nvim_set_option_value('sidescrolloff', 10, { win = win })
  vim.api.nvim_set_option_value(
    'winhighlight',
    cmdline_float_winhighlight,
    { win = win }
  )

  -- Size and position of window.
  local width_frac = 0.5
  local min_width = 40
  local max_width = 80
  local x_frac = 0.5
  local y_frac = 0.5

  local rows = vim.o.lines
  local cols = vim.o.columns

  local width = math.min(
    math.max(min_width, math.min(max_width, math.floor(width_frac * cols))),
    cols - 4
  )
  local border_size = utils.border_size(vim.o.winborder)
  local row = math.max(
    0,
    math.floor(
      y_frac * (rows - math.max(1, vim.api.nvim_win_get_height(win)) - border_size)
    )
  )
  local col = math.max(0, math.floor(x_frac * (cols - width - border_size)))

  pcall(vim.api.nvim_win_set_config, win, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    border = vim.o.winborder,
    title = 'Command-line',
    title_pos = 'center',
    style = 'minimal',
  })
end

---Restore the normal UI2 command-line window.
local function restore_cmdline()
  local win = get_cmdline_win()

  if not win or not orig_cmd_win_config then
    return
  end

  vim.api.nvim_win_set_config(win, orig_cmd_win_config)

  vim.api.nvim_set_option_value(
    'winhighlight',
    cmdline_regular_winhighlight,
    { win = win }
  )

  orig_cmd_win_config = nil
end

-- Wrap the `cmdline_show` function.
local orig_cmdline_show = cmdline.cmdline_show

cmdline.cmdline_show = function(...)
  if not orig_cmd_win_config then
    local win = get_cmdline_win()

    if win then
      orig_cmd_win_config = vim.api.nvim_win_get_config(win)
    end
  end

  local ret = orig_cmdline_show(...)

  float_cmdline()

  return ret
end

-- Wrap the `cmdline_hide` function.
local orig_cmdline_hide = cmdline.cmdline_hide

cmdline.cmdline_hide = function(...)
  local ret = orig_cmdline_hide(...)

  if cmdline.level == 0 then
    restore_cmdline()
  end

  return ret
end

local ui2_group = vim.api.nvim_create_augroup('UI2', { clear = true })

-- Enable the experimental UI2.
--
-- Messages appear in a floating window at the bottom right.
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    ui2.enable({ msg = { targets = 'msg' } })
  end,
  group = ui2_group,
})

-- Set highlights, and reset on colour scheme change.
set_hls()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_hls,
  group = ui2_group,
})
