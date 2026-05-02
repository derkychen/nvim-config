local M = {}

-- Check if a buffer is valid and normal
function M.valid_normal_buf(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

  -- TODO: Remove once this Oil bug is fixed:
  -- https://github.com/stevearc/oil.nvim/issues/710
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
  local other_conds = filetype ~= "oil" and not bufname:match("^oil://")

  return vim.api.nvim_buf_is_valid(buf)
      and buftype == ""
      and bufname ~= nil
      and bufname ~= ""
      and other_conds
end

-- Get path of buffer relative to window current working directory, falls back
-- to buffer name if the buffer is not valid and normal
function M.winrelpath(winid)
  local path, bufname
  local buf = vim.api.nvim_win_get_buf(winid)
  if vim.api.nvim_win_is_valid(winid) then
    bufname = vim.api.nvim_buf_get_name(buf)
  end
  if M.valid_normal_buf(buf) then
    path = vim.fs.relpath(vim.fn.getcwd(winid), bufname)
    if path == nil then
      path = vim.fs.relpath(vim.env.HOME, bufname)
    end
  end
  if path == nil then
    path = bufname
  end
  return path
end

return M
