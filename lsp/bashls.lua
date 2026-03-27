return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
      shfmt = {
        path = "shfmt",
        ignoreEditorConfig = false,
      }
    },
  },
}
