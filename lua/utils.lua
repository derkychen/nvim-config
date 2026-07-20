local M = {}

-- Check if a buffer is valid, normal, and from disk.
function M.valid_normal_disk_buf(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

  return vim.api.nvim_buf_is_valid(buf)
      and buftype == ""
      and vim.uv.fs_stat(bufname) ~= nil
end

-- Wrap `vim.fs.relpath()` to get and process path of target relative to base,
-- home directory, or root directory. Falls back to target if no relative path
-- exists.
function M.relpath(base, target)
  local path

  path = vim.fs.relpath(base, target)

  -- Fall back to and indicate home directory.
  if path == nil then
    local homerelpath = vim.fs.relpath(vim.env.HOME, target)

    if homerelpath then
      path = "~/" .. homerelpath
    end
  end

  -- This fallback works for non-existent paths and paths that can only be
  -- resolved relative to the root directory.
  return path or target
end

return M
