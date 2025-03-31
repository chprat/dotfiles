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
vim.keymap.set("n", "<space><space>e", "<cmd>source %<CR>", { desc = "Source current LUA file" })
vim.keymap.set("n", "<space>e", ":.lua<CR>", { desc = "Execute current LUA line" })
vim.keymap.set("v", "<space>e", ":lua<CR>", { desc = "Execute current LUA highligh" })

-- terminal
keymap.set("n", "<leader>ts", function()
    vim.cmd.new()
    vim.cmd.term()
    vim.api.nvim_win_set_height(0, 15)
    vim.opt.spell = false
    vim.cmd.startinsert()
end, { desc = "Open terminal" })
keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Close terminal" })
keymap.set("t", "jj", "<c-\\><c-n>", { desc = "Close terminal" })
keymap.set("n", "<leader>tf", "<cmd>Floaterminal<cr>", { desc = "Open floating terminal" })
