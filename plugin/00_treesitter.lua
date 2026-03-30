vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local ensure_languages = {
  "lua",
  "latex",
  "r",
  "c",
  "python",
  "markdown",
  "html",
  "css",
  "javascript",
  "bash",
  "toml",
}

local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
if #to_install > 0 then require("nvim-treesitter").install(to_install) end

local filetypes = vim.iter(ensure_languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
vim.list_extend(filetypes, { "markdown", "quarto" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
