-- set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- clear search results
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

-- indention with 4 white spaces
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.shiftround = true -- makes < and > indent to multiples of shiftwidth

-- try to guess the correct indention
vim.opt.smartindent = true

-- indent wrapped lines
vim.opt.breakindent = true

-- remove trailing white space on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})

-- show hybrid (real number for current line, others relative) line numbers
vim.wo.relativenumber = true

-- open new horizontal split below current
vim.opt.splitbelow = true

-- open new vertical split right to the current
vim.opt.splitright = true

-- keep this amount of context lines when scrolling
vim.opt.scrolloff = 10

-- enable mouse support in all modes
vim.opt.mouse = "a"

-- enable case insensitive search
vim.opt.ignorecase = true

-- use case sensitive search if it contains a capital letter
vim.opt.smartcase = true

-- enable spell checking
vim.opt.spelllang = "en_us"
vim.opt.spell = true
