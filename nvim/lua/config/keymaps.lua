local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- New tab
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- snacks
keymap.set("n", "<leader>h", Snacks.dashboard.open, { desc = "Dashboard" })

-- HOME/END
keymap.set("n", "<Find>", "0", opts)
keymap.set("n", "<Select>", "$", opts)
keymap.set("v", "<Find>", "0", opts)
keymap.set("v", "<Select>", "$", opts)
keymap.set("i", "<Find>", "<Esc>0i", opts)
keymap.set("i", "<Select>", "<Esc>$a", opts)

-- insert move
keymap.set("i", "<C-h>", "<C-o>b", opts)
keymap.set("i", "<C-l>", "<C-o>w", opts)
