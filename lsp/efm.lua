local tclint = {
    lintCommand = "tclint --stdin-path ${INPUT} -",
    lintStdin = true,
    lintFormats = { "%f:%l:%c: %t%*[^:]: %m" }, -- tclint uses readable messages; format is conservative
    formatCommand = "tclfmt",                 -- provided by tclint
    formatStdin = true,
}

return {
    cmd = { "efm-langserver" },
    filetypes = { "modelsim" },
    init_options = { documentFormatting = true, documentRangeFormatting = true },
    settings = {
        rootMarkers = { ".git", "tclint.toml", ".tclint" },
        languages = {
            modelsim = { tclint, tclint }, -- first = linter, second = formatter
        },
    },
}
