--- Configuration for the `nvim-autopairs` plugin.
---
--- Lazy-loads `nvim-autopairs`.
vim.pack.add({
  'https://github.com/windwp/nvim-autopairs',
}, { load = false })

-- Lazy-load `nvim-autopairs` when entering INSERT mode.
require('lazyload').register({
  augroup_name = 'AutopairsLazyLoad',
  events = 'InsertEnter',
  name = 'nvim-autopairs',
  config = function()
    vim.cmd.packadd('nvim-autopairs')

    local Rule = require('nvim-autopairs.rule')
    local npairs = require('nvim-autopairs')

    npairs.setup()

    -- LaTeX rules.
    npairs.add_rules({
      Rule('\\(', '\\)', 'tex'),
      Rule('\\[', '\\]', 'tex'),
    })
  end,
})
