local diag_icons = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌶 " }

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = diag_icons.error,
            [vim.diagnostic.severity.WARN] = diag_icons.warn,
            [vim.diagnostic.severity.INFO] = diag_icons.info,
            [vim.diagnostic.severity.HINT] = diag_icons.hint,
        },
    },
})
