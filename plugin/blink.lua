require("lazyload").add_spec({
  "https://github.com/rafamadriz/friendly-snippets",
  {
    src = "https://github.com/Saghen/blink.cmp",
    version = vim.version.range("*"),
  },
}, {
  event = { "InsertEnter", "CmdlineEnter" },
  group_name = "BlinkLazyLoad",
  config = function()
    require("blink.cmp").setup({
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          update_delay_ms = 50,
        },
      },
    })
  end,
})
