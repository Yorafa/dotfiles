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
				-- 指示符/诊断数组必须在此定义，否则无法获得当前页色块的底色：
				hl.BufferLineIndicatorSelected = { fg = "#1f2335", bg = "#7aa2f7" }
				for _, grp in ipairs({ "Diagnostic", "Error", "Warning", "Info", "Hint" }) do
					hl["BufferLine" .. grp .. "Selected"] = { fg = "#1f2335", bg = "#7aa2f7", bold = true }
				end
				for _, grp in ipairs({ "Error", "Warning", "Info", "Hint" }) do
					hl["BufferLine" .. grp .. "DiagnosticSelected"] = { fg = "#1f2335", bg = "#7aa2f7", bold = true }
				end
			end,
		},
	},
}
