return {
    {
        "mason-org/mason.nvim",
        optional = true,
        opts = { ensure_installed = { "luacheck" } },
    },
    {
        "mfussenegger/nvim-lint",
        optional = true,
        opts = {
            linters_by_ft = {
                lua = { "luacheck" },
            },
        },
    },
}
