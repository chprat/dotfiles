return {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    config = function()
        local oil = require("oil")
        local keymap = vim.keymap
        keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        oil.setup()
    end,
}
