return {
	{
		"akinsho/bufferline.nvim",
		opts = {
			options = {
				always_show_bufferline = true,
			},
			highlights = {
				buffer_selected = { bg = "#7aa2f7", fg = "#1f2335", italic = false },
				separator_selected = { bg = "#7aa2f7", fg = "#7aa2f7" },
				close_button_selected = { bg = "#7aa2f7", fg = "#1f2335" },
				pick_selected = { bg = "#7aa2f7", fg = "#1f2335", italic = false },
				modified_selected = { bg = "#7aa2f7" },
				duplicate_selected = { bg = "#7aa2f7" },
				numbers_selected = { bg = "#7aa2f7" },
			},
		},
	},
	{
		"tiagovla/scope.nvim",
		-- 每个 tabpage 拥有独立的 buffer 列表，:bnext/:bprev/buffer picker 只在当前 tab 内生效
		opts = {},
	},
	{
		"folke/snacks.nvim",
		opts = {
			scroll = {
				enabled = false, -- 禁用滑动动画
			},
			dashboard = {
				preset = {
					header = [[
	        ██╗   ██╗ ██████╗ ██████╗  █████╗ ███████╗ █████╗ 
			╚██╗ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
			 ╚████╔╝ ██║   ██║██████╔╝███████║█████╗  ███████║
			  ╚██╔╝  ██║   ██║██╔══██╗██╔══██║██╔══╝  ██╔══██║
			   ██║   ╚██████╔╝██║  ██║██║  ██║██║     ██║  ██║
			   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝
   ]],
				},
			},
		},
	},
}
