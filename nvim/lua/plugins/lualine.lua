return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        extensions = { "nvim-tree" },
        sections = {
            lualine_c = {
                {
                    "filename",
                    path = 1,
                },
            },
        },
    },
}
