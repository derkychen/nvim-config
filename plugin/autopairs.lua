vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
}, { load = false })

local autopairs_lazyload_group = vim.api.nvim_create_augroup(
  "AutopairsLazyLoad", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = vim.schedule_wrap(function()
    vim.cmd.packadd("nvim-autopairs")

    local Rule = require("nvim-autopairs.rule")
    local npairs = require("nvim-autopairs")

    npairs.setup()

    -- Equation brackets in LaTeX
    npairs.add_rules({
      Rule("\\(", "\\)", "tex"),
      Rule("\\[", "\\]", "tex"),
    })
  end),
  group = autopairs_lazyload_group,
  once = true,
})
