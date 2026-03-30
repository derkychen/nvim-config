vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local parsers_by_filetype = {
  lua = { "lua" },
  tex = { "latex" },
  r = { "r" },
  c = { "c" },
  python = { "python" },
  markdown = { "markdown", "markdown_inline" },
  html = { "html" },
  css = { "css" },
  javascript = { "javascript" },
  sh = { "bash" },
  toml = { "toml" },
}

local ts = require("nvim-treesitter")

ts.setup()
for _, parsers in pairs(parsers_by_filetype) do
  for _, parser in pairs(parsers) do
    ts.install(parser)
  end
end

local filetypes = {}
for filetype, _ in pairs(parsers_by_filetype) do
  table.insert(filetypes, filetype)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
