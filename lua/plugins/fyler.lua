return {
  "A7Lavinraj/fyler.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  branch = "stable", -- Use stable branch for production
  opts = {},
  config = function()
    local fyler = require("fyler")
    fyler.setup({
      views = {
        finder = {
          close_on_select = false,
          default_explorer = true,
          delete_to_trash = true,
          mappings = {
            ["Q"] = "CloseView",
            ["<CR>"] = "Select",
            ["<C-t>"] = "SelectTab",
            ["|"] = "SelectVSplit",
            ["-"] = "SelectSplit",
            ["^"] = "GotoParent",
            ["="] = "GotoCwd",
            ["."] = "GotoNode",
            ["#"] = "CollapseAll",
            ["<BS>"] = "CollapseNode",
          },
          win = {
            kinds = {
              split_left_most = {
                width = "20%",
              },
            },
            win_opts = {
              cursorline = true,
              number = true,
              relativenumber = true,
              wrap = false,
            },
          },
        },
      },
    })
    vim.keymap.set(
      "n",
      "<leader>eo",
      function()
        fyler.open({
          kind = "replace",
        })
      end,
      {}
    )
    vim.keymap.set(
      "n",
      "<leader>et",
      function()
        fyler.toggle({
          kind = "split_left_most",
        })
      end,
      {}
    )
  end
}
