return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {},
  config = function()
    local fzf_lua = require("fzf-lua")

    vim.keymap.set("n", "<Leader>ff", fzf_lua.files, {})
    vim.keymap.set("n", "<Leader>fg", fzf_lua.live_grep, {})
    vim.keymap.set("n", "<Leader>fr", fzf_lua.oldfiles, {})

    local home = vim.fn.expand("~")

    local function fzf_tcd()
      fzf_lua.fzf_exec("fd --type d --hidden --follow --exclude .git", {
        prompt = "Select directory to tcd into > ",
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
            print("tcd " .. dir)
          end,
        },
      })
    end

    vim.api.nvim_create_user_command("DirjumpThenExplorer", function()
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("DirjumpThenExplorer", { clear = true }),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("Fyler open kind=split_left_most")
          end)
        end,
      })
      fzf_tcd()
    end, {})

    vim.keymap.set("n", "<Leader>fd", function()
      vim.cmd("DirjumpThenExplorer")
    end, {})
  end,
}
