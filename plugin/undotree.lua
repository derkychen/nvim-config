vim.cmd.packadd("nvim.undotree")

vim.keymap.set("n", "<leader>u", function()
  vim.cmd.Undotree()
end, { desc = "Toggle undotree" })
