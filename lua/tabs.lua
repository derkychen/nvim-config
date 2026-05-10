local M = {}

local function close_current()
  if vim.fn.tabpagenr("$") > 1 then
    vim.cmd.tabclose()
  else
    vim.api.nvim_cmd({
      cmd = "qa",
      mods = {
        confirm = true,
      },
    }, {})
  end
end

function M.setup()
  vim.keymap.set("n", "<Leader>tn", vim.cmd.tabnew, {})
  vim.keymap.set("n", "<Leader>tx", close_current, {})
end

return M
