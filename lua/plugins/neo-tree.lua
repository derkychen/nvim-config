return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-mini/mini.icons",
    },
    lazy = false,
    config = function()
        vim.keymap.set("n", "<C-e>", function()
            vim.cmd("Neotree reveal toggle")
        end)

        require("neo-tree").setup({
            -- Show hidden files by default
            filesystem = {
                filtered_items = {
                    visible = true,
                },
            },

            -- Line numbers
            event_handlers = {
                {
                    event = "neo_tree_buffer_enter",
                    handler = function()
                        vim.opt_local.relativenumber = true
                        vim.opt_local.cursorline = true
                        vim.opt_local.number = true
                        vim.opt_local.cursorlineopt = "both"
                    end,
                },
            },

            -- Using mini.icons
            default_component_configs = {
                icon = {
                    provider = function(icon, node)
                        local text, hl
                        local mini_icons = require("mini.icons")
                        if node.type == "file" then
                            text, hl = mini_icons.get("file", node.name)
                        elseif node.type == "directory" then
                            text, hl = mini_icons.get("directory", node.name)
                            if node:is_expanded() then
                                text = nil
                            end
                        end
                        if text then
                            icon.text = text
                        end
                        if hl then
                            icon.highlight = hl
                        end
                    end,
                },
            },
        })
    end,
}
