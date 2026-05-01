local lazyload = require("lazyload")

lazyload.lazyadd("nvim.undotree", {
  event = "BufEnter",
  group_name = "UndoTreeLazyLoad",
  config = function()
    vim.keymap.set("n", "<leader>u", function()
      vim.cmd.Undotree()
    end, { desc = "Toggle undotree" })
  end,
})
