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

return M
