return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"echasnovski/mini.icons",
	},
	lazy = false,
	config = function()
		vim.keymap.set("n", "<C-n>", function()
			vim.cmd("Neotree reveal toggle")
		end, {})
	end,
}
