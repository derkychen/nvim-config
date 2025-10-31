return {
  "goolord/alpha-nvim",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- NVIM version
    dashboard.section.header.val = { ("NVIM v%d.%d.%d%s"):format(vim.version().major, vim.version().minor,
      vim.version().patch,
      vim.version().prerelease and "-dev" or "") }

    -- Buttons
    dashboard.section.buttons.val = {
      dashboard.button("n", "  " .. "> New file", "<cmd> ene <BAR> startinsert <cr>"),
      dashboard.button("r", "󰽙  " .. "> Recent files", "<cmd> Telescope oldfiles <cr>"),
      dashboard.button("f", "  " .. "> Find file", "<cmd> Telescope find_files <cr>"),
      dashboard.button("d", "  " .. "> Change directory", function()
        vim.cmd("DirjumpThenReveal")
      end),
      dashboard.button("c", "  " .. "> Config", "<cmd> tcd ~/.config/nvim/ <BAR> Neotree reveal left <cr>"),
      dashboard.button("q", "  " .. "> Quit", "<cmd> q <cr>"),
    }

    -- Setup
    alpha.setup(dashboard.config)

    -- Vertical centering
    local function vert_center()
      local content_height = #dashboard.section.header.val + (#dashboard.section.buttons.val * 2 - 1) + 3
      dashboard.opts.layout[1].val = vim.fn.floor((vim.fn.winheight(0) - content_height + 2) / 2)
      pcall(alpha.redraw)
    end

    vim.api.nvim_create_autocmd({ "VimEnter", "VimResized", "WinResized" }, {
      callback = vert_center
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = vert_center,
    })

    -- Open Alpha when creating empty new tab
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
            vim.cmd(":Alpha")
          end
        end)
      end,
    })
  end,
}

