--- MATLAB LSP configuration.
---
--- Based on:
--- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#matlab_ls

--- @type vim.lsp.Config
return {
  cmd = { 'matlab-language-server', '--stdio' },
  filetypes = { 'matlab' },
  root_dir = function(bufnr, on_dir)
    local root_dir = vim.fs.root(bufnr, '.git')
    on_dir(root_dir or vim.fn.getcwd())
  end,
  settings = {
    MATLAB = {
      indexWorkspace = true,
      installPath = '/Applications/MATLAB_R2026a.app/bin/matlab',
      matlabConnectionTiming = 'onStart',
      telemetry = true,
    },
  },
}
