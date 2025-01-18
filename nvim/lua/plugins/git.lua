return {
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local keymap = vim.keymap
            local neogit = require("neogit")
            neogit.setup({})
            keymap.set("n", "<leader>gg", "<cmd> Neogit <cr>", { desc = "Neogit open" })
            keymap.set("n", "<leader>gl", "<cmd> NeogitLogCurrent <cr>", { desc = "Neogit log current file" })
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },
}
