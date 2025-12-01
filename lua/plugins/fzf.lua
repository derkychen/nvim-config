return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {},
  config = function()
    local fzf_lua = require("fzf-lua")

    fzf_lua.setup()
    fzf_lua.register_ui_select()

    vim.keymap.set("n", "<Leader>ff", fzf_lua.files, {})
    vim.keymap.set("n", "<Leader>fg", fzf_lua.live_grep, {})
    vim.keymap.set("n", "<Leader>fr", fzf_lua.oldfiles, {})

    local home = vim.fn.expand("~")

    local function fzf_tcd(opts)
      opts = opts or {}
      local on_done = opts.on_done

      fzf_lua.fzf_exec("fd --type d --hidden --follow --exclude .git", {
        prompt = "Directory to tcd into > ",
        cwd = home,
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then
              return
            end
            local rel = selected[1]
            local dir = vim.fn.fnamemodify(home .. "/" .. rel, ":p")
            if vim.fn.isdirectory(dir) == 0 then
              vim.notify("Not a directory: " .. dir, vim.log.levels.WARN)
              return
            end

            vim.cmd("tcd " .. vim.fn.fnameescape(dir))

            if on_done then
              vim.schedule(function()
                on_done(dir)
              end)
            end
          end,
        },
      })
    end

    vim.api.nvim_create_user_command("TcdThenCwdExplorer", function()
      fzf_tcd({
        on_done = function(_dir)
          _G.CwdExplorer()
        end,
      })
    end, {})

    vim.keymap.set("n", "<Leader>fd", function()
      vim.cmd("TcdThenCwdExplorer")
    end, {})
  end,
}
