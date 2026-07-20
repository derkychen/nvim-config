local M = {}

-- Set up all options.
function M.setup()
  require("options.global").setup()
  require("options.buflocal").setup()
  require("options.winlocal").setup()
end

return M
