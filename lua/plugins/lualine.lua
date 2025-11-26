return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  config = function()
    local function set_tab_hl()
      local tabline = vim.api.nvim_get_hl(0, { name = "TabLine", link = false })
      local tablinesel = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
      local tablinefill = vim.api.nvim_get_hl(0, { name = "TabLineFill", link = false })

      local label_hl = {
        active = tablinesel,
        inactive = tabline,
      }

      local sep_hl = {
        active = {
          fg = tablinesel.bg,
          bg = tablinefill.bg
        },
        inactive = {
          fg = tabline.bg,
          bg = tablinefill.bg
        },
      }

      vim.api.nvim_set_hl(0, "LabelActive", label_hl.active)
      vim.api.nvim_set_hl(0, "LabelInactive", label_hl.inactive)
      vim.api.nvim_set_hl(0, "SepActive", sep_hl.active)
      vim.api.nvim_set_hl(0, "SepInactive", sep_hl.inactive)
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

      local cur = vim.fn.tabpagenr()
      local tabline = {}

      for i = 1, tabsnr do
        local winnr = vim.fn.tabpagewinnr(i)
        local buflist = vim.fn.tabpagebuflist(i)
        local bufnr = buflist[winnr]

        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
        if name == "" then
          name = "[No Name]"
        end

        local label = string.format(" %d  %s ", i, name)

        local is_current = (i == cur)

        local left_sep, right_sep
        if is_current then
          left_sep, right_sep = "", ""
        elseif i < cur then
          left_sep, right_sep = "", ""
        else
          left_sep, right_sep = "", ""
        end

        local label_hl = is_current and "%#LabelActive#" or "%#LabelInactive#"
        local sep_hl = is_current and "%#SepActive#" or "%#SepInactive#"

        local tab = sep_hl ..
            left_sep ..
            label_hl ..
            "%" ..
            i ..
            "@v:lua.TablineSwitch@" ..
            label .. "%X" .. "%" .. i .. "@v:lua.TablineClose@" .. "  " .. "%X" .. sep_hl .. right_sep

        table.insert(tabline, tab)
      end

      table.insert(tabline, "%#TabLineFill#")
      return table.concat(tabline, "")
    end

    require("lualine").setup({
      options = {
        always_divide_middle = false,
      },
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
            "aerial",
            sep = "  ",
            separator = { left = "", right = "" },
          },
        },
      },
    })
  end,
}
