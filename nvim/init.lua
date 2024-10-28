-- workaround: https://github.com/neovim/neovim/issues/29900#issuecomment-2345824245
vim.g.bigfile_size = 1024 * 1024 * 1 -- 1M

require("config.lazy")
