return {
	{
		"saghen/blink.cmp",
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
		},
	},
}
