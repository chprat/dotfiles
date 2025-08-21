return {
    "2kabhishek/exercism.nvim",
    cmd = { "Exercism" },
    keys = {
        { "<leader>es", "<cmd>Exercism submit<cr>", desc = "Exercism Submit" },
        { "<leader>et", "<cmd>Exercism test<cr>", desc = "Exercism Test" },
    },
    dependencies = {
        "2kabhishek/utils.nvim",
    },
    opts = {
        exercism_workspace = "~/Exercism",
        default_language = "go",
        add_default_keybindings = true,
        use_new_command = true,
        max_recents = 30,
        icons = {
            concept = "",
            practice = "",
        },
    },
}
