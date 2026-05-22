-- `~/.arduino15/arduino-cli.yaml` must be created in order for this
-- configuration to work
return {
  filetypes = { "arduino" },

  -- Changed to avoid the calling of `lspconfig.util` function which was present
  -- in the original configuration from `nvim-lspconfig`
  root_dir = function(buf, on_dir)
    local path = vim.api.nvim_buf_get_name(buf)

    local root = vim.fs.root(path, {
      "sketch.yaml",
      "arduino-cli.yaml",
      ".git",
    })

    if root then
      on_dir(root)
    elseif path:match("%.ino$") then
      on_dir(vim.fs.dirname(path))
    end
  end,

  cmd = { "arduino-language-server" },

  capabilities = {
    textDocument = {
      semanticTokens = vim.NIL,
    },
    workspace = {
      semanticTokens = vim.NIL,
    },
  },
}
