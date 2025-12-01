return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-mini/mini.icons",
  },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      view = {
        width = 35,
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          git_placement = "right_align",
          diagnostics_placement = "right_align",
          modified_placement = "right_align",
          hidden_placement = "right_align",
          bookmarks_placement = "right_align",
          glyphs = {
            git = {
              untracked = ""
            },
          },
        },
      },
      update_focused_file = {
        enable = true,
      },
    })

    vim.keymap.set("n", "<Leader>e", function()
      vim.cmd("NvimTreeToggle")
    end)
  end,
}
