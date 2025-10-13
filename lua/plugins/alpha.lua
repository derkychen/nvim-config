return {
  "goolord/alpha-nvim",
  config = function()
    local dashboard = require("alpha.themes.dashboard")

    -- Header
    dashboard.section.header.val = {
      "  ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆         ",
      "   ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦      ",
      "         ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄    ",
      "          ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀ ⠢⣀⡀⠈⠙⠿⠄   ",
      "         ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀  ",
      "  ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄ ",
      " ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄  ",
      "⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄ ",
      "⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄",
      "     ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆    ",
      "      ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⣿⠃    ",
      "        ⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠁      ",
    }

    -- NVIM version
    dashboard.section.nvim = {
      type = "text",
      val = ("NVIM v%d.%d.%d%s"):format(vim.version().major, vim.version().minor, vim.version().patch,
        vim.version().prerelease and "-dev" or ""),
      opts = { position = "center" },
    }

    -- Buttons
    dashboard.section.buttons.val = {
      dashboard.button("n", "+  " .. "> New file", "<cmd> ene <BAR> startinsert <cr>"),
      dashboard.button("r", "󰽙  " .. "> Recent files", "<cmd> Telescope oldfiles <cr>"),
      dashboard.button("f", "  " .. "> Find file", "<cmd> Telescope find_files <cr>"),
      dashboard.button("d", "  " .. "> Change directory", "<cmd> Telescope dirjump <cr>"),
      dashboard.button("c", "  " .. "> Config", "<cmd> e ~/.config/nvim/ <cr>"),
      dashboard.button("q", "  " .. "> Quit", "<cmd> q <cr>"),
    }

    dashboard.config.layout = {
      { type = "padding", val = 20 },
      dashboard.section.header,
      { type = "padding", val = 1 },
      dashboard.section.nvim,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
    }

    -- Setup
    require("alpha").setup(dashboard.config)

    -- Auto-open Alpha when creating a new tab (only if it's an empty scratch buffer)
    vim.api.nvim_create_autocmd("TabNew", {
      callback = function()
        -- defer so we're actually in the new tab/window
        vim.schedule(function()
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local bt = vim.bo[buf].buftype
          local modified = vim.bo[buf].modified
          local line_count = vim.api.nvim_buf_line_count(buf)

          -- Open Alpha only for a fresh, unnamed, unmodified buffer
          if name == "" and bt == "" and not modified and line_count <= 1 then
            require("alpha").start(true) -- `true` keeps layout in this tab
          end
        end)
      end,
    })
  end,
}
