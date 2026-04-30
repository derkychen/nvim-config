vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf_lua = require("fzf-lua")

-- Use Fzf-Lua as the interface for `vim.ui.select`
local opts = {
  ui_select = true,
}

fzf_lua.setup(opts)

-- Add a function to Fzf-Lua for finding and setting a tab working directory
local home = vim.fn.expand("~")

function fzf_lua.tcd()
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
        vim.cmd.tcd(dir)
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
vim.keymap.set("n", "<Leader>fd", fzf_lua.tcd,
  { desc = "Find directory and tcd" })
