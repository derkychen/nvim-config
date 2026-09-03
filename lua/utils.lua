---Miscellaneous utility functions used elsewhere.
---
---There is no setup function for this module, as it is only required by other
---modules and provides no standalone functionality.
local M = {}

---Check if a buffer is valid, normal, and from disk.
---
---For example, although help buffers are from the filesystem, they are special
---buffers, and would not be considered normal.
---
---@param buf integer Buffer ID.
---@return boolean is_valid_normal_disk_buf If the buffer meets all criteria.
function M.valid_normal_disk_buf(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.api.nvim_get_option_value('buftype', { buf = buf }) == ''
    and vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf)) ~= nil
end

---Get a relative path in a custom format.
---
---Wraps `vim.fs.relpath()` to get and process path of target relative to base,
---home directory, or root directory. Falls back to target if no relative path
---exists.
---
---@param base string Base path from which the relative path starts.
---@param target string Target path to which the relative path goes.
---@return string relpath The formatted relative path from the base to target.
function M.relpath(base, target)
  if base == '' or target == '' then
    return target
  end

  local relpath = vim.fs.relpath(base, target)

  -- Fall back to and indicate home directory.
  if relpath == nil then
    local homerelpath = vim.fs.relpath(vim.env.HOME, target)

    if homerelpath then
      relpath = '~/' .. homerelpath
    end
  end

  -- This fallback works for non-existent paths and paths that can only be
  -- resolved relative to the root directory.
  return relpath or target
end

---Get the width of a border style.
---
---Takes in a border style and outputs how much it increases size both window
---dimensions. This only works for built-in styles and does not account for
---custom border styles.
---
---@param style string Name of the border style.
---@return integer height Height added from the border style. Must be 0, 1, or 2.
---@return integer width Width added from the border style. Must be 0, 1, or 2.
function M.border_size(style)
  local size = 0

  if style == '' or style == 'none' then
    size = 0
  elseif style == 'shadow' then
    size = 1
  else
    size = 2
  end

  return size, size
end

---Get a bottom-left (SE) window-scoped small floating window configuration.
---
---This window configuration is specific to my preferences. It is slightly inset
---and occupies a small portion of the bottom-left corner of the window.
---
---@param source_win integer Source window ID.
---@return table config Window configuration.
function M.se_small_win_config(source_win)
  local source_width = vim.api.nvim_win_get_width(source_win)
  local source_height = vim.api.nvim_win_get_height(source_win)

  return {
    relative = 'win',
    win = source_win,
    anchor = 'SE',
    row = math.max(0, source_height - 1),
    col = math.max(0, source_width - 1),
    width = math.min(25, math.max(1, source_width)),
    height = math.min(30, math.max(1, source_height)),
    border = vim.o.winborder,
    style = 'minimal',
  }
end

return M
