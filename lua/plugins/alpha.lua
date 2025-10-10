return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Buttons
    dashboard.section.buttons.val = {
      dashboard.button("n", "+ " .. " New file", "<cmd> ene <BAR> startinsert <cr>"),
      dashboard.button("r", " " .. " Recent files", "<cmd> Telescope old_files <cr>"),
      dashboard.button("f", " " .. " Find file", "<cmd> Telescope find_files <cr>"),
      dashboard.button("d", " " .. " Change directory", "<cmd> Telescope dirjump <cr>"),
      dashboard.button("c", " " .. " Config", "<cmd> e ~/.config/nvim/ <cr>"),
      dashboard.button("q", " " .. " Quit", "<cmd> q <cr>"),
    }
    dashboard.opts.layout[1].val = 20

    -- Setup
    alpha.setup(dashboard.opts)

    vim.keymap.set("n", "<Leader>ta", ":tabnew | Alpha<CR>", {})

    -- Header and footer
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      once = true,
      callback = function()
        local hydra = {
          "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
          "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
          "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
          "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
          "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
          "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
          "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
          " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
          " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
          "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
          "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
          "         ⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠉      ",
        }
        local header = hydra

        local v = vim.version()
        local nvim = ("NVIM v%d.%d.%d%s"):format(v.major, v.minor, v.patch, v.prerelease and "-dev" or "")
        local left = math.floor((vim.fn.strdisplaywidth(header[1]) - vim.fn.strdisplaywidth(nvim)) / 2);

        table.insert(header, "")
        table.insert(header, string.rep(" ", left) .. nvim)

        dashboard.section.header.val = header
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
