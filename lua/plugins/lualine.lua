return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    config = function()
        require("lualine").setup()
    end,
}
