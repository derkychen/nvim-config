-- UI2 setup and floating command-line.
--
-- Based on and thanks to Raphaël Chartier's tiny-cmdline.nvim:
-- https://github.com/rachartier/tiny-cmdline.nvim
local utils = require("utils")
local ui2 = require("vim._core.ui2")
local cmdline = require("vim._core.ui2.cmdline")

local M = {}

-- State storing variables.
local cmdline_type = nil
local orig_cmdline_show = nil
local orig_ui_cmdline_pos = vim.g.ui_cmdline_pos
local orig_cmd_win_config = nil

-- Construct `winhighlight` option from map of highlights.
local function make_winhighlight(win_hl_map)
  local win_hls = {}
  for dest_hl, src_hl in pairs(win_hl_map) do
    table.insert(win_hls, dest_hl .. ":" .. src_hl)
  end
  return table.concat(win_hls, ",")
end

-- Highlights for floating command-line window.
local cmdline_float_winhighlight = make_winhighlight({
  Normal = "CmdlineFloatNormal",
  FloatBorder = "CmdlineFloatBorder",
  Search = "None",
  CurSearch = "None",
  IncSearch = "None",
})

-- Highlights for regular command-line window.
local cmdline_regular_winhighlight = make_winhighlight({
  Normal = "CmdlineNormal",
  Search = "None",
  CurSearch = "None",
  IncSearch = "None",
})

local function set_hls()
  vim.api.nvim_set_hl(0, "CmdlineFloatNormal", {
    fg = vim.api.nvim_get_hl(0, { name = "MsgArea" }).fg,
    bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg,
  })
  vim.api.nvim_set_hl(0, "CmdlineNormal", { link = "MsgArea", default = true })
  vim.api.nvim_set_hl(
    0,
    "CmdlineFloatBorder",
    { link = "FloatBorder", default = true }
  )
end

-- Determine dimension from percentage of available screen dimensions or number
-- of terminal cells.
local function parse_dimension(value, available)
  if type(value) == "string" then
    return math.floor(available * tonumber(value:match("^(%d+)%%$")) / 100)
  end
  return math.floor(value)
end

-- Size and position of window.
local function geometry(content_height)
  local min_width = 40
  local max_width = 80
  local percent_width = "50%"

  local cols = vim.o.columns
  local lines = vim.o.lines

  local bw = utils.winborder_width()

  local width = math.min(
    math.max(
      min_width,
      math.min(max_width, parse_dimension(percent_width, cols))
    ),
    cols - 4
  )

  local x_position = "50%"
  local y_position = "50%"

  local row =
    math.max(0, parse_dimension(y_position, lines - content_height - bw * 2))
  local col = math.max(0, parse_dimension(x_position, cols - width - bw * 2))

  return width, row, col, bw
end

-- Return command-line window ID.
local function get_cmdline_win()
  if not ui2 then
    return
  end
  local win = ui2.wins and ui2.wins.cmd
  return (win and vim.api.nvim_win_is_valid(win)) and win or nil
end

-- Configure command-line window and provide anchor for completion.
local function float_cmdline()
  if not cmdline_type then
    return
  end

  local win = get_cmdline_win()
  if not win then
    return
  end

  -- Store original window configuration.
  if not orig_cmd_win_config then
    orig_cmd_win_config = vim.api.nvim_win_get_config(win)
  end

  vim.api.nvim_set_option_value("winfixbuf", true, { win = win })
  vim.api.nvim_set_option_value("wrap", false, { win = win })
  vim.api.nvim_set_option_value("sidescrolloff", 10, { win = win })
  vim.api.nvim_set_option_value(
    "winhighlight",
    cmdline_float_winhighlight,
    { win = win }
  )

  local content_height = math.max(1, vim.api.nvim_win_get_height(win))
  local width, row, col, bw = geometry(content_height)

  pcall(vim.api.nvim_win_set_config, win, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    border = vim.o.winborder,
    title = "Command-line",
    title_pos = "center",
    style = "minimal",
  })

  -- Used by `blink.cmp` for anchoring.
  vim.g.ui_cmdline_pos = {
    row + bw + 1,
    col + bw + 1,
  }
end

function M.setup()
  -- Enable UI2.
  ui2.enable({
    msg = {
      targets = "msg", -- Messages appear in a floating window at the bottom right.
    },
  })

  -- Wrap the `cmdline_show` function once.
  --
  -- While this file should only be sourced once, being defensive does prevent
  -- silently wrapping multiple times.
  if not orig_cmdline_show then
    orig_cmdline_show = cmdline.cmdline_show
    cmdline.cmdline_show = function(...)
      local ret = orig_cmdline_show(...)

      if not cmdline_type then
        return ret
      end

      float_cmdline()
      return ret
    end
  end

  local group =
    vim.api.nvim_create_augroup("UI2FloatingCmdline", { clear = true })

  -- Set highlights, and reset on colour scheme change.
  set_hls()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = set_hls,
    group = group,
  })

  -- Update the command-line window on entering and leaving.
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
      cmdline_type = vim.fn.getcmdtype()
    end,
    group = group,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      cmdline_type = nil
      vim.g.ui_cmdline_pos = orig_ui_cmdline_pos
      local win = get_cmdline_win()

      if win and orig_cmd_win_config then
        pcall(vim.api.nvim_win_set_config, win, orig_cmd_win_config)
        vim.api.nvim_set_option_value(
          "winhighlight",
          cmdline_regular_winhighlight,
          { win = win }
        )
      end
    end,
    group = group,
  })
end

return M
