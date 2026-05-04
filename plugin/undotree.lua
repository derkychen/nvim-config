local undotree_lazyload_group = vim.api.nvim_create_augroup("UndoTreeLazyLoad",
  { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  callback = vim.schedule_wrap(function()
    vim.cmd.packadd("nvim.undotree")

    vim.keymap.set("n", "<leader>u", function()
      vim.cmd.Undotree()
    end, { desc = "Toggle undotree" })
  end),
  group = undotree_lazyload_group,
  once = true,
})
