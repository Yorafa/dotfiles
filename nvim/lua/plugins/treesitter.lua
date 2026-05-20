return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {},
		config = function(_, opts)
			require("nvim-treesitter.config").setup(opts)
		end,
	},
}
