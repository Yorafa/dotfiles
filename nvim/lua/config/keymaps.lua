local keymap = vim.keymap
local opts = { silent = true }

-- Same as vim.keymap.set(opts) plus a description: which-key reads `desc` from the
-- mapping, so instead of a bare rhs these show up with a readable label in the popup.
local function map(mode, lhs, rhs, desc)
	keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
end

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select All" })

-- snacks
keymap.set("n", "<leader>h", Snacks.dashboard.open, { desc = "Dashboard" })

-- HOME/END
map("n", "<Find>", "0", "Line Start")
map("n", "<Select>", "$", "Line End")
map("v", "<Find>", "0", "Line Start")
map("v", "<Select>", "$", "Line End")
map("i", "<Find>", "<Esc>0i", "Line Start")
map("i", "<Select>", "<Esc>$a", "Line End")

-- insert move
map("i", "<C-h>", "<C-o>b", "Move to Prev Word")
map("i", "<C-l>", "<C-o>w", "Move to Next Word")

-- tabs
local function tab_label(tab, index)
	local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
	if ok and name ~= "" then
		return string.format("%d: %s", index, name)
	end
	local win = vim.api.nvim_tabpage_get_win(tab)
	local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
	local label = bufname == "" and "[No Name]" or vim.fn.fnamemodify(bufname, ":t")
	return string.format("%d: %s", index, label)
end

-- rename current tab (shown in bufferline's right custom area, see plugins/ui.lua)
keymap.set("n", "<leader><tab>r", function()
	local tab = vim.api.nvim_get_current_tabpage()
	local ok, current = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
	vim.ui.input({ prompt = "Rename tab: ", default = ok and current or "" }, function(input)
		if input == nil then
			return
		end
		input = vim.trim(input)
		if input == "" then
			vim.api.nvim_tabpage_del_var(tab, "name")
		else
			vim.api.nvim_tabpage_set_var(tab, "name", input)
		end
		-- repaint the tabline (same refresh bufferline uses for its own rename)
		vim.schedule(function()
			vim.cmd.redrawtabline()
		end)
	end)
end, { desc = "Rename Tab" })

-- switch tab left/right (wraps around, unlike :tabnext/:tabprevious which error at the ends)
local function goto_tab(offset)
	local tabs = vim.api.nvim_list_tabpages()
	if #tabs < 2 then
		return
	end
	vim.api.nvim_set_current_tabpage(tabs[(vim.fn.tabpagenr() - 1 + offset) % #tabs + 1])
end

keymap.set("n", "<A-h>", function()
	goto_tab(-1)
end, { desc = "Previous Tab" })
keymap.set("n", "<A-l>", function()
	goto_tab(1)
end, { desc = "Next Tab" })

-- jump to a tab by fuzzy-searching its name (or its current buffer)
keymap.set("n", "<leader><tab>j", function()
	local tabs = vim.api.nvim_list_tabpages()
	local labels = {}
	for i, tab in ipairs(tabs) do
		labels[i] = tab_label(tab, i)
	end
	vim.ui.select(labels, { prompt = "Jump to tab" }, function(_, choice)
		if choice then
			vim.api.nvim_set_current_tabpage(tabs[choice])
		end
	end)
end, { desc = "Jump to Tab" })
