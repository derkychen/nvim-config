return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<Leader>fg", builtin.live_grep, {})
    vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<Leader>fr", builtin.oldfiles, {})
  end,
}
