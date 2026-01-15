local M = {}

function M.valid_normal_buf(buf)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and buf_name ~= nil and buf_name ~= ""
end

return M
