local M = {}

-- Check if a buffer is valid, normal, and from disk
function M.valid_normal_disk_buf(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

  return vim.api.nvim_buf_is_valid(buf)
      and buftype == ""
      and vim.uv.fs_stat(bufname) ~= nil
end

-- Get and process path of buffer relative to current working directory of
-- window, home directory, or root directory, and fall back to buffer name
function M.winrelpath(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local path

  local buf = vim.api.nvim_win_get_buf(win)
  local bufname = vim.api.nvim_buf_get_name(buf)

  if M.valid_normal_disk_buf(buf) then
    path = vim.fs.relpath(vim.fn.getcwd(win), bufname)

    -- Fall back to and indicate home directory
    if path == nil then
      local homerelpath = vim.fs.relpath(vim.env.HOME, bufname)

      if homerelpath then
        path = "~/" .. homerelpath
      end
    end
  end

  -- Fallback that works for both special buffers and buffers whose relative
  -- paths can only be resolved from the root directory
  return path or bufname
end

return M
