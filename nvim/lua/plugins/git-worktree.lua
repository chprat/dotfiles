return {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local worktree = require("git-worktree")
        worktree.setup()
        local telescope = require("telescope")
        telescope.load_extension("git_worktree")
        vim.keymap.set(
            "n",
            "<leader>fw",
            require("telescope").extensions.git_worktree.git_worktrees,
            { desc = "Telescope git worktrees" }
        )
        vim.keymap.set(
            "n",
            "<leader>fwc",
            require("telescope").extensions.git_worktree.create_git_worktree,
            { desc = "Telescope create git worktree" }
        )
    end,
}
