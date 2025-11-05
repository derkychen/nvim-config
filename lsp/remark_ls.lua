return {
    settings = { remark = { requireConfig = false } },
    cmd = { "remark-language-server", "--stdio" },
    filetypes = { "markdown" },
    root_markers = {
        ".remarkrc",
        ".remarkrc.json",
        ".remarkrc.js",
        ".remarkrc.cjs",
        ".remarkrc.mjs",
        ".remarkrc.yml",
        ".remarkrc.yaml",
        ".remarkignore",
    },
}
