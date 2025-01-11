vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" })

keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- split management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sm", "<C-w>_", { desc = "Maximize current split" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- LUA execution/source
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Source current LUA file" })
vim.keymap.set("n", "<space>x", ":.lua<CR>", { desc = "Execute current LUA line" })
vim.keymap.set("v", "<space>x", ":lua<CR>", { desc = "Execute current LUA highligh" })
