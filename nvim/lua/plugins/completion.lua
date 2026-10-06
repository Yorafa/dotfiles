return {
	{
		"saghen/blink.cmp",
		opts = {
			keymap = {
				preset = "super-tab",
				-- 恢复上下原生功能，使用cn, cp 进行选择
				["<Up>"] = { "fallback" },
				["<Down>"] = { "fallback" },
			},
		},
	},
}
