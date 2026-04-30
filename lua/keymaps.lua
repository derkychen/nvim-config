local sessions = require("sessions")

-- Sessions
vim.keymap.set("n", "<Leader>ss", sessions.save_current,
  { desc = "Save current session" })
vim.keymap.set("n", "<Leader>sa", sessions.save_to_name,
  { desc = "Save current session to name" })
vim.keymap.set("n", "<Leader>sl", sessions.load_by_name,
  { desc = "Load session by name" })
vim.keymap.set("n", "<Leader>sdc", sessions.delete_current,
  { desc = "Delete current session" })
vim.keymap.set("n", "<Leader>sdn", sessions.delete_by_name,
  { desc = "Delete session by name" })
vim.keymap.set("n", "<Leader>src", sessions.rename_current,
  { desc = "Rename current session" })
vim.keymap.set("n", "<Leader>srn", sessions.rename_by_name,
  { desc = "Rename session by name" })

-- Tab page controls
vim.keymap.set("n", "<Leader>tn", vim.cmd.tabnew, {})
vim.keymap.set("n", "<Leader>tx", function()
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
end, {})

-- LSP
vim.keymap.set("n", "<Leader>lh", vim.lsp.buf.hover,
  { desc = "LSP buffer hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition,
  { desc = "LSP goto definition" })
vim.keymap.set("n", "<Leader>la", vim.lsp.buf.code_action,
  { desc = "LSP code action" })
vim.keymap.set("n", "<Leader>lf", vim.lsp.buf.format,
  { desc = "LSP format buffer" })

-- Diagnostics
vim.keymap.set("n", "<Leader>do", vim.diagnostic.open_float,
  { noremap = true, silent = true, desc = "Open diagnostic" })
vim.keymap.set("n", "<Leader>dt",
  function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
  { desc = "Toggle diagnostics" })
