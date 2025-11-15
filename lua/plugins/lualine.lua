return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  config = function()
    local function set_tab_hl()
      local tabline    = vim.api.nvim_get_hl(0, { name = "TabLine", link = false })
      local tablinesel = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })

      vim.api.nvim_set_hl(0, "TabActive", {
        fg = tabline.fg or tablinesel.fg,
        bg = tablinesel.bg or tabline.bg,
      })

      vim.api.nvim_set_hl(0, "TabInactive", {
        fg = tabline.fg,
        bg = tabline.bg,
      })

      vim.api.nvim_set_hl(0, "TabSepActive", {
        fg = tablinesel.bg or tabline.bg,
        bg = tabline.bg,
      })

      vim.api.nvim_set_hl(0, "TabSepInactive", {
        fg = tabline.bg,
        bg = tabline.bg,
      })
      vim.api.nvim_set_hl(0, "TabLineFill", { fg = tabline.fg, bg = tabline.bg })
    end

    vim.schedule(set_tab_hl)

    local grp = vim.api.nvim_create_augroup("TablineHL", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = grp,
      callback = function()
        vim.schedule(set_tab_hl)
      end,
    })

    _G.TablineSwitch = function(tabnr, clicks, button, mods)
      if button ~= "l" then
        return
      end
      vim.cmd(tabnr .. "tabnext")
    end

    _G.TablineClose = function(tabnr, clicks, button, mods)
      if button ~= "l" then
        return
      end

      if vim.fn.tabpagenr("$") <= 1 then
        vim.cmd("confirm qa")
        return
      end

      if tabnr ~= vim.fn.tabpagenr() then
        vim.cmd(tabnr .. "tabclose")
        return
      end

      vim.cmd("tabclose")
    end

    local function tabs()
      local tabsnr = vim.fn.tabpagenr("$")
      if tabsnr == 0 then
        return ""
      end

      local tabline   = {}
      local left_sep  = ""
      local right_sep = ""

      for i = 1, tabsnr do
        local winnr   = vim.fn.tabpagewinnr(i)
        local buflist = vim.fn.tabpagebuflist(i)
        local bufnr   = buflist[winnr]

        local name    = vim.api.nvim_buf_get_name(bufnr)
        name          = vim.fn.fnamemodify(name, ":t")
        if name == "" then
          name = "[No Name]"
        end

        local label = string.format(" %d  %s ", i, name)
        local label_hl
        local sep_hl

        if i == vim.fn.tabpagenr() then
          label_hl = "%#TabActive#"
          sep_hl   = "%#TabSepActive#"
        else
          label_hl = "%#TabInactive#"
          sep_hl   = "%#TabSepInactive#"
        end

        local tab =
            sep_hl .. left_sep ..
            label_hl .. "%" .. i .. "@v:lua.TablineSwitch@" .. label .. "%X" ..
            "%" .. i .. "@v:lua.TablineClose@" .. "  " .. "%X" ..
            sep_hl .. right_sep

        table.insert(tabline, tab)
      end

      table.insert(tabline, "%#TabLineFill#")

      return table.concat(tabline, "")
    end

    local function show_winbar()
      local win = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(win)

      local cfg = vim.api.nvim_win_get_config(win)
      if cfg and cfg.relative ~= '' then
        return false
      end

      if vim.fn.win_gettype(win) ~= '' then
        return false
      end

      local bt = vim.bo[buf].buftype
      if bt ~= '' then
        return false
      end

      if not vim.bo[buf].buflisted then
        return false
      end

      return true
    end
    require("lualine").setup({
      tabline = {
        lualine_a = {
          {
            function()
              return ""
            end,
            separator = { right = "" },
          },
        },
        lualine_c = {
          {
            tabs,
            mode = 2,
            max_length = vim.o.columns,
            separator = { left = "", right = "" },
          },
        },
      },
      winbar = {
        lualine_b = {
          {
            "filename",
            path = 0,
            cond = show_winbar,
          },
        },
        lualine_c = {
          {
            "aerial",
            sep = "  ",
            sep_icon = "",
            cond = show_winbar
          },
        }
      },
    })
  end,
}
