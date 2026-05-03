require("lazyload").add_spec({
  "https://github.com/windwp/nvim-autopairs",
}, {
  event = "InsertEnter",
  group_name = "AutopairsLazyLoad",
  config = function()
    local Rule = require("nvim-autopairs.rule")
    local npairs = require("nvim-autopairs")

    npairs.setup()

    -- Equation brackets in LaTeX
    npairs.add_rules({
      Rule("\\(", "\\)", "tex"),
      Rule("\\[", "\\]", "tex"),
    })
  end,
})
