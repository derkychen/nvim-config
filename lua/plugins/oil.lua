return {
  "stevearc/oil.nvim",
  opts = {},
  lazy = false,
  config = function()
    local oil = require("oil")
    local border = "rounded"
    oil.setup({
      win_options = {
        number = true,
        relativenumber = true,
        statuscolumn = " %l ",
        conceallevel = 0,
        cursorline = true,
        cursorcolumn = true,
      },
      watch_for_changes = true,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<Leader>ov"] = { "actions.select", opts = { vertical = true } },
        ["<Leader>os"] = { "actions.select", opts = { horizontal = true } },
        ["<Leader>ot"] = { "actions.select", opts = { tab = true } },
        ["<Leader>op"] = "actions.preview",
        ["<Leader>ox"] = { "actions.close", mode = "n" },
        ["<Leader>or"] = "actions.refresh",
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

    vim.api.nvim_create_user_command("CwdExplorer", _G.CwdExplorer, {})

    vim.api.nvim_create_autocmd("TabNew", {
      callback = function()
        vim.schedule(function()
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local bt = vim.bo[buf].buftype
          local modified = vim.bo[buf].modified
          local line_count = vim.api.nvim_buf_line_count(buf)

          if name == "" and bt == "" and not modified and line_count <= 1 then
            CwdExplorer()
          end
        end)
      end,
    })

    vim.keymap.set("n", "<Leader>oo", oil.open, {})
  end,
}
