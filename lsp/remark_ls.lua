return {
  cmd = { "remark-language-server", "--stdio" },
  filetypes = { "markdown" },
  settings = {
    remark = {
      requireConfig = false,
    },
  },
  root_dir = function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    local path = name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
    local root = vim.fs.find({
      ".remarkrc",
      ".remarkrc.json",
      ".remarkrc.js",
      ".remarkrc.cjs",
      ".remarkrc.mjs",
      ".remarkrc.yml",
      ".remarkrc.yaml",
      ".remarkignore",
    }, {
      path = path,
      upward = true,
    })[1]
    on_dir(root and vim.fs.dirname(root) or path)
  end,
}
