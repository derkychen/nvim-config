---Configuration for the `aerial.nvim` plugin.
---
---`mini.icons` must be set up before this configuration is sourced.
local utils = require("utils")

vim.pack.add({ "https://github.com/stevearc/aerial.nvim" })

local aerial = require("aerial")

aerial.setup({
  -- Open `aerial.nvim` in a floating window.
  layout = {
    win_opts = {
      cursorline = true,
    },
    default_direction = "float",
  },
  show_guides = true,
  float = {
    relative = "win",

    -- Floating window appears on the bottom left.
    override = function(conf, source_winid)
      return vim.tbl_extend(
        "force",
        conf,
        utils.se_small_win_config(source_winid)
      )
    end,
  },
})

-- Keymaps.
vim.keymap.set(
  "n",
  "<Leader>a",
  aerial.toggle,
  { desc = "Toggle Aerial window" }
)
vim.keymap.set(
  "n",
  "<Leader>fs",
  aerial.fzf_lua_picker,
  { desc = "Find symbol" }
)
