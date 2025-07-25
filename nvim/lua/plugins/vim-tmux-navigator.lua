return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
    },
    keys = {
        { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "TmuxNavigateLeft" },
        { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "TmuxNavigateDown" },
        { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "TmuxNavigateUp" },
        { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "TmuxNavigateRight" },
    },
}
