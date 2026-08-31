---Configuration for the `nvim-autopairs` plugin.
---
---Lazy-loads `nvim-autopairs`.
vim.pack.add({
  'https://github.com/windwp/nvim-autopairs',
}, { load = false })

local autopairs_lazyload_group =
  vim.api.nvim_create_augroup('AutopairsLazyLoad', { clear = true })

-- Lazy-load `nvim-autopairs` when entering INSERT mode.
vim.api.nvim_create_autocmd('InsertEnter', {
  callback = vim.schedule_wrap(function()
    vim.cmd.packadd('nvim-autopairs')

    local Rule = require('nvim-autopairs.rule')
    local npairs = require('nvim-autopairs')

    npairs.setup()

    -- LaTeX rules.
    npairs.add_rules({
      Rule('\\(', '\\)', 'tex'),
      Rule('\\[', '\\]', 'tex'),
    })
  end),
  group = autopairs_lazyload_group,
  once = true,
})
