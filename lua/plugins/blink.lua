return {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    opts = {
        keymap = {
            preset = "default",
            ["<CR>"] = { "select_and_accept", "fallback" },
            ["<Esc>"] = {
                function(cmp)
                    if cmp.is_visible and cmp.is_visible() then
                        cmp.cancel()
                        return true
                    end
                end,
                "fallback",
            },

            ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

            ["<Up>"] = {
                function(cmp)
                    cmp.cancel()
                end,
                "fallback",
            },
            ["<Down>"] = {
                function(cmp)
                    cmp.cancel()
                end,
                "fallback",
            },
            ["<Left>"] = {
                function(cmp)
                    cmp.cancel()
                end,
                "fallback",
            },
            ["<Right>"] = {
                function(cmp)
                    cmp.cancel()
                end,
                "fallback",
            },
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = { documentation = { auto_show = false } },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
}
