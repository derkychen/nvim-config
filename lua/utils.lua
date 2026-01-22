local M = {}

function M.valid_normal_buf(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_option_value("buftype", { buf = buf }) == "" and bufname ~= nil and bufname ~= ""
end

return M
