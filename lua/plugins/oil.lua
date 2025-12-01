return {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  config = function()
    local oil = require("oil")
    local border = "rounded"
    oil.setup({
      win_options = {
        number = true,
        relativenumber = true,
        cursorline = true,
      },
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
        ["-"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
      float = {
        border = border,
      },
      preview_win = {
        win_options = {
          number = true,
        },
      },
      confirmation = {
        border = border,
      },
      progress = {
        border = border,
      },
      ssh = {
        border = border,
      },
      keymaps_help = {
        border = border,
      },
    })

    _G.CwdExplorer = function()
      oil.open(vim.fn.getcwd())
    end

    vim.keymap.set("n", "<Leader>o", oil.open, {})
  end,
}
