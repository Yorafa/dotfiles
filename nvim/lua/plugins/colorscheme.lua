return {
	{
		"folke/tokyonight.nvim",
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
			on_highlights = function(hl)
				hl.Comment = { fg = "#e6ffff", italic = true }
			end,
		},
	},
}
