return {
	"nvim-mini/mini.icons",
	version = "*",
	config = function()
		require("mini.icons").mock_nvim_web_devicons()
	end,
}
