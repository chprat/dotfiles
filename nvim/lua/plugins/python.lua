return {
    {
        "mason-org/mason.nvim",
        optional = true,
        opts = { ensure_installed = { "flake8", "isort" } },
    },
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = function(_, opts)
            opts.formatters_by_ft["python"] = opts.formatters_by_ft["python"] or {}
            table.insert(opts.formatters_by_ft["python"], 1, "isort")
        end,
    },
    {
        "mfussenegger/nvim-lint",
        optional = true,
        opts = {
            linters_by_ft = {
                python = { "flake8" },
            },
        },
    },
}
