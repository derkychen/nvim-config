return {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  config = function()
    require("oil").setup({
      win_options = {
        number = true,
        relativenumber = true,
        cursorline = true,
      },
      delete_to_trash = true,
      watch_for_changes = true,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<Leader>v"] = { "actions.select", opts = { vertical = true } },
        ["<Leader>s"] = { "actions.select", opts = { horizontal = true } },
        ["<Leader>t"] = { "actions.select", opts = { tab = true } },
        ["<Leader>p"] = "actions.preview",
        ["<Leader>x"] = { "actions.close", mode = "n" },
        ["<Leader>r"] = "actions.refresh",
      },
      use_default_keymaps = true,
      view_options = {
        show_hidden = true,
      },
    })

    _G.Explorer = function()
      vim.cmd("Oil")
    end

    vim.keymap.set("n", "<Leader>o", _G.Explorer, {})
  end,
}
