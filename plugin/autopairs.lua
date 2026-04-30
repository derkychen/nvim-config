vim.pack.add({ "https://github.com/windwp/nvim-autopairs" })

local Rule = require("nvim-autopairs.rule")
local npairs = require("nvim-autopairs")

npairs.setup()

-- Equation brackets in LaTeX
npairs.add_rules({
  Rule("\\(", "\\)", "tex"),
  Rule("\\[", "\\]", "tex")
})
