return {
	-- 保留 tokyonight 作为备选
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = { style = "moon", light_style = "day" },
	},

	-- 添加 matugen.nvim
	{
		"Senal-D-A-Gunaratna/matugen.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			palette_path = "~/.cache/matugen/nvim-colors.json",
		},
	},
}
