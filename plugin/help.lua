---Configuration for built-in help functionality.
---
---Mainly just floats the window.
local utils = require('utils')

---Float the help window in the bottom right of the editor, slightly inset.
---
---@param win integer Help window ID.
local function float_help(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local width = math.min(80, math.floor(vim.o.columns * 0.5))
  local height = math.min(30, math.floor(vim.o.lines * 0.5))

  local border_height, border_width = utils.border_size(vim.o.winborder)

  vim.api.nvim_win_set_config(win, {
    relative = 'editor',
    row = vim.o.lines - height - vim.o.cmdheight - border_height - 1,
    col = vim.o.columns - width - 2 * border_width,
    width = width,
    height = height,
    border = vim.o.winborder,
    title = 'Help',
    title_pos = 'left',
    style = 'minimal',
  })

  vim.api.nvim_set_option_value('winfixbuf', true, { win = win })
end

-- Float the window help appears in.
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= 'help' then
      return
    end

    local win = vim.api.nvim_get_current_win()

    vim.schedule(function()
      if
        vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) == ev.buf
      then
        float_help(win)
      end
    end)
  end,
})
