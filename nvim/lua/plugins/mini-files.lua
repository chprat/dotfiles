return {
    "nvim-mini/mini.files",
    opts = {
        options = {
            use_as_default_explorer = true,
        },
    },
    keys = {
        { "-", "<leader>fm", desc = "Open mini.files", remap = true },
    },
}
