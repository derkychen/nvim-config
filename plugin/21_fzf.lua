--- Configuration for the Fzf-Lua plugin.
---
--- `mini.icons` and `oil.nvim` must be set up before this configuration is
--- sourced.
local oil = require('oil')

vim.pack.add({ 'https://github.com/ibhagwan/fzf-lua' })

local fzf = require('fzf-lua')

fzf.setup({
  winopts = {
    -- Match the floating window borders to the global one.
    border = vim.o.winborder,
    -- Do not darken window backdrop.
    backdrop = 100,
    -- Match the preview window borders to the global one.
    preview = {
      border = vim.o.winborder,
    },
  },
  -- Use Fzf-Lua for `vim.ui.select`.
  ui_select = {
    -- Make the menu smaller.
    winopts = {
      height = 0.4,
      width = 0.4,
      row = 0.5,
      col = 0.5,
    },
  },
})

local home = vim.env.HOME

--- Fuzzy finds a directory and opens `oil.nvim` in it.
---
--- This is not a built-in function. It searches only from the home directory.
function fzf.dirs()
  fzf.fzf_exec('fd --type d --hidden --follow --exclude .git', {
    prompt = 'Directory > ',
    cwd = home,
    actions = {
      ['default'] = function(selected)
        if not selected or #selected == 0 then
          return
        end

        local rel = selected[1]
        local dir = vim.fs.normalize(vim.fs.joinpath(home, rel))
        local stat = vim.uv.fs_stat(dir)

        if not stat or stat.type ~= 'directory' then
          vim.notify('Not a directory: ' .. dir, vim.log.levels.WARN)
          return
        end

        oil.open(dir)
      end,
    },
  })
end

-- Keymaps.
vim.keymap.set('n', '<Leader>ff', fzf.files, { desc = 'Find files' })
vim.keymap.set('n', '<Leader>fr', fzf.oldfiles, { desc = 'Find recent files' })
vim.keymap.set('n', '<Leader>fg', fzf.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<Leader>fb', fzf.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<Leader>ft', fzf.tabs, { desc = 'Find tabs' })
vim.keymap.set('n', '<Leader>fd', fzf.dirs, { desc = 'Find directory' })
