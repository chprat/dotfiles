return {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        -- no carets in statusline: https://vi.stackexchange.com/questions/15873/carets-in-status-line
        vim.opt.fillchars = "stl: "
        vim.opt.termguicolors = true
        vim.o.background = "light"
        require("solarized").setup()
        vim.cmd.colorscheme("solarized")
    end,
}
