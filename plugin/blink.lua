---Configuration for the `blink.cmp` plugin.
---
---Lazy-loads `blink.cmp`, configures UI and enables documentation in the
---completion window.
vim.pack.add({
  "https://github.com/rafamadriz/friendly-snippets",
  {
    src = "https://github.com/Saghen/blink.cmp",
    version = vim.version.range("*"),
  },
}, { load = false })

local blink_lazyload_group =
  vim.api.nvim_create_augroup("BlinkLazyLoad", { clear = true })

-- Lazy load `blink.cmp` on entering INSERT or COMMAND mode.
--
-- TODO: Remove or refactor automatic command group deletion workaround when
--       this bug is fixed, since `once = true` does not ensure automatic
--       command is run once when there are multiple events:
--       https://github.com/neovim/neovim/issues/37027
vim.api.nvim_create_autocmd({
  "InsertEnter",
  "CmdlineEnter",
}, {
  callback = vim.schedule_wrap(function()
    vim.cmd.packadd("friendly-snippets")
    vim.cmd.packadd("blink.cmp")

    require("blink.cmp").setup({
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          update_delay_ms = 50,
        },
      },
    })

    vim.api.nvim_del_augroup_by_id(blink_lazyload_group)
  end),
  group = blink_lazyload_group,
  once = true,
})
