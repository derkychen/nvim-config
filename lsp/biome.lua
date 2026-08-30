return {
  cmd = function(dispatchers, config)
    local cmd = "biome"
    local local_cmd = (config or {}).root_dir
      and config.root_dir .. "/node_modules/.bin/biome"

    if local_cmd and vim.fn.executable(local_cmd) == 1 then
      cmd = local_cmd
    end

    return vim.lsp.rpc.start({ cmd, "lsp-proxy" }, dispatchers)
  end,
  filetypes = {
    "astro",
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "svelte",
    "typescript",
    "typescriptreact",
    "vue",
  },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      {
        "package-lock.json",
        "yarn.lock",
        "pnpm-lock.yaml",
        "bun.lockb",
        "bun.lock",
        "deno.lock",
      },
      {
        ".git",
      },
    }) or vim.fn.getcwd()
    on_dir(root)
  end,
}
