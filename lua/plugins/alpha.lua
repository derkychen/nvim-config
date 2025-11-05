return {
    "goolord/alpha-nvim",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- NVIM version
        dashboard.section.header.val = { ("NVIM v%d.%d.%d%s"):format(vim.version().major, vim.version().minor,
            vim.version().patch, vim.version().prerelease and "-dev" or "") }

        -- Buttons
        dashboard.section.buttons.val = {
            dashboard.button("n", "  " .. "> New file", "<cmd> ene <BAR> startinsert <cr>"),
            dashboard.button("r", "󰽙  " .. "> Recent files", "<cmd> Telescope oldfiles <cr>"),
            dashboard.button("f", "  " .. "> Find file", "<cmd> Telescope find_files <cr>"),
            dashboard.button("g", "󱎸  " .. "> Live grep", "<cmd> Telescope live_grep <cr>"),
            dashboard.button("d", "  " .. "> Change directory", function()
                vim.cmd("DirjumpThenReveal")
            end),
            dashboard.button("c", "  " .. "> Config", "<cmd> tcd ~/.config/nvim/ <BAR> Neotree reveal left <cr>"),
        }

        -- Setup
        alpha.setup(dashboard.config)

        -- Vertical centering
        local function vert_center()
            if vim.bo.filetype == "alpha" then
                local function height(elem)
                    if elem.type == "padding" then
                        return elem.val
                    elseif elem.type == "text" then
                        if type(elem.val) == "string" then
                            return #vim.split(elem.val, "\n", { plain = true })
                        elseif type(elem.val) == "table" then
                            return #elem.val
                        end
                    elseif elem.type == "button" then
                        return 1
                    elseif elem.type == "group" then
                        local total, n = 0, 0
                        for _, child in ipairs(elem.val or {}) do
                            total = total + height(child)
                            n = n + 1
                        end
                        local spacing = (elem.opts and elem.opts.spacing) or 0
                        if n > 1 then total = total + spacing * (n - 1) end
                        return total
                    else
                        return 0
                    end
                end

                local content_height = 0
                for i, elem in ipairs(dashboard.opts.layout or {}) do
                    if (i ~= 1) then
                        content_height = content_height + height(elem)
                    end
                end
                dashboard.opts.layout[1].val = math.max(0,
                    math.floor((vim.api.nvim_win_get_height(0) - content_height) / 2))
                pcall(alpha.redraw)
            end
        end

        vim.api.nvim_create_autocmd({ "VimEnter", "VimResized", "WinResized" }, {
            callback = vert_center
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "AlphaReady",
            callback = vert_center,
        })

        -- Open Alpha when creating empty new tab
        vim.api.nvim_create_autocmd("TabNew", {
            callback = function()
                vim.schedule(function()
                    local win = vim.api.nvim_get_current_win()
                    local buf = vim.api.nvim_win_get_buf(win)
                    local name = vim.api.nvim_buf_get_name(buf)
                    local bt = vim.bo[buf].buftype
                    local modified = vim.bo[buf].modified
                    local line_count = vim.api.nvim_buf_line_count(buf)

                    if name == "" and bt == "" and not modified and line_count <= 1 then
                        vim.cmd(":Alpha")
                    end
                end)
            end,
        })
    end,
}
