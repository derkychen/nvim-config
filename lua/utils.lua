local M = {}

function M.valid_normal_buf(buf)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and buf_name ~= nil and buf_name ~= ""
end

function M.winrelpath(winid)
  local path, filename
  local buf = vim.api.nvim_win_get_buf(winid)
  if vim.api.nvim_win_is_valid(winid) then
    filename = vim.api.nvim_buf_get_name(buf)
  end
  if M.valid_normal_buf(buf) then
    path = vim.fs.relpath(vim.fn.getcwd(winid), filename)
    if path == nil then
      path = vim.fs.relpath(vim.env.HOME, filename)
    end
  end
  if path == nil then
    path = filename
  end
  return path
end

return M
