return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<Leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<Leader>fr", builtin.oldfiles, {})
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    config = function()
      require('telescope').setup {
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      }
      require('telescope').load_extension('fzf')
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
  {
    "derkychen/dirjump.nvim",
    config = function()
      require("telescope").load_extension("dirjump")

      vim.api.nvim_create_user_command("DirjumpThenReveal", function()
        vim.api.nvim_create_autocmd("DirChanged", {
          group = vim.api.nvim_create_augroup("DirjumpThenReveal", { clear = true }),
          once = true,
          callback = function()
            vim.schedule(function()
              vim.cmd("Neotree filesystem reveal")
            end)
          end,
        })
        vim.cmd("Telescope dirjump")
      end, {})

      vim.keymap.set("n", "<Leader>fd", function()
        vim.cmd("DirjumpThenReveal")
      end, {})
    end,
  },
}
