return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Buttons
    dashboard.section.buttons.val = {
      dashboard.button("n", "+  " .. "> New file", "<cmd> ene <BAR> startinsert <cr>"),
      dashboard.button("r", "󰽙  " .. "> Recent files", "<cmd> Telescope old_files <cr>"),
      dashboard.button("f", "  " .. "> Find file", "<cmd> Telescope find_files <cr>"),
      dashboard.button("d", "  " .. "> Change directory", "<cmd> Telescope dirjump <cr>"),
      dashboard.button("c", "  " .. "> Config", "<cmd> e ~/.config/nvim/ <cr>"),
      dashboard.button("q", "  " .. "> Quit", "<cmd> q <cr>"),
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
          "  ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆         ",
          "   ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦      ",
          "         ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄    ",
          "          ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄   ",
          "         ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀  ",
          "  ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄ ",
          " ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄  ",
          "⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄ ",
          "⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄",
          "     ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆    ",
          "      ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⣿⠃    ",
          "        ⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠉       ",
        }
        local banner = hydra

        local v = vim.version()
        local nvim = ("NVIM v%d.%d.%d%s"):format(v.major, v.minor, v.patch, v.prerelease and "-dev" or "")

        -- Centering
        local b = vim.fn.strdisplaywidth(banner[1])
        local n = vim.fn.strdisplaywidth(nvim)
        local left = math.floor(math.abs((b - n) / 2));
        if b > n then
          nvim = string.rep(" ", left) .. nvim
        elseif n > b then
          for i, s in ipairs(banner) do
            banner[i] = string.rep(" ", left) .. s
          end
        end

        local header = {}
        table.move(banner, 1, #banner, #header + 1, header)
        table.insert(header, "")
        table.insert(header, nvim)

        dashboard.section.header.val = header
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
