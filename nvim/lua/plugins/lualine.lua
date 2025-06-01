return {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
        opts.options.component_separators = { left = "", right = "" }
        opts.options.section_separators = { left = "", right = "" }
        opts.options.theme = "rose-pine-alt"
        table.insert(opts.sections.lualine_c, 1, { "fileformat" })
        table.insert(opts.sections.lualine_c, 2, { "encoding" })
        opts.sections.lualine_z = {}
    end,
}
