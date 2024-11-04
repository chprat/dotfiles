return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    path_display = { "smart" },
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                            ["<C-j>"] = actions.move_selection_next, -- move to next result
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        },
                    },
                },
            })

            telescope.load_extension("fzf")

            local builtin = require("telescope.builtin")
            local keymap = vim.keymap

            keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
            keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Telescope live grep" })
            keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
            keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
            keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope recent files" })
            keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Telescope live grep for string under cursor" })
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })
            require("telescope").load_extension("ui-select")
        end,
    },
}
