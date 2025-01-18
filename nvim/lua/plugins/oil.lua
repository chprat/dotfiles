return {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local oil = require("oil")
        local keymap = vim.keymap
        keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        oil.setup()
    end,
}
