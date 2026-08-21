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
---@param buf integer Neovim buffer identifier.
---@return boolean is_valid_normal_disk_buf If the buffer meets all criteria.
function M.valid_normal_disk_buf(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.api.nvim_get_option_value("buftype", { buf = buf }) == ""
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
  local relpath = vim.fs.relpath(base, target)

  -- Fall back to and indicate home directory.
  if relpath == nil then
    local homerelpath = vim.fs.relpath(vim.env.HOME, target)

    if homerelpath then
      relpath = "~/" .. homerelpath
    end
  end

  -- This fallback works for non-existent paths and paths that can only be
  -- resolved relative to the root directory.
  return relpath or target
end

---Get width of floating window borders.
---
---@return integer width Width of the window borders. Must be zero or one.
function M.winborder_width()
  return (vim.o.winborder == "" or vim.o.winborder == "none") and 0 or 1
end

return M
