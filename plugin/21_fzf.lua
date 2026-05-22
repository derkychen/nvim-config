vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf_lua = require("fzf-lua")

local opts = {
  -- Use Fzf-Lua for `vim.ui.select`, make the menu smaller
  ui_select = {
    winopts = {
      height = 0.4,
      width = 0.4,
      row = 0.5,
      col = 0.5,
    },
  },

  -- Do not darken window backdrop
  winopts = {
    backdrop = 100,
  },
}

fzf_lua.setup(opts)

-- Add a function to Fzf-Lua for finding and setting a current working directory
-- and opening `oil.nvim` in that directory
local home = vim.env.HOME

function fzf_lua.cd()
  fzf_lua.fzf_exec("fd --type d --hidden --follow --exclude .git", {
    prompt = "Directory to cd into > ",
    cwd = home,
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end

        local rel = selected[1]
        local dir = vim.fs.normalize(vim.fs.joinpath(home, rel))

        if not vim.uv.fs_stat(dir) == 0 then
          vim.notify("Not a directory: " .. dir, vim.log.levels.WARN)
          return
        end

        vim.cmd.cd(vim.fn.fnameescape(dir))

        local ok, oil = pcall(require, "oil")
        if ok then
          oil.open(dir)
        end
      end,
    },
  })
end

vim.keymap.set("n", "<Leader>ff", fzf_lua.files, { desc = "Find files" })
vim.keymap.set("n", "<Leader>fr", fzf_lua.oldfiles,
  { desc = "Find recent files" })
vim.keymap.set("n", "<Leader>fg", fzf_lua.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<Leader>fb", fzf_lua.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<Leader>ft", fzf_lua.tabs, { desc = "Find tabs" })
vim.keymap.set("n", "<Leader>fd", fzf_lua.cd,
  { desc = "Find directory and cd" })
