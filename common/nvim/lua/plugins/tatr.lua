return {
    dir = vim.fn.expand("~/Programming/tatr.nvim"),
    cmd = { "Tatr", "TatrNew", "TatrInit" },
    keys = {
        {
            "<leader>tt",
            "<cmd>Tatr<cr>",
            desc = "TATR: Aufgaben",
        },
        {
            "<leader>ti",
            "<cmd>TatrInit<cr>",
            desc = "TATR: Projekt initialisieren",
        },
        {
            "<leader>tn",
            "<cmd>TatrNew<cr>",
            desc = "TATR: Neues ToDo erstellen",
        },
        {
            "<leader>tc",
            function()
                require("tatr").from_comment()
            end,
            mode = "n",
            desc = "TATR: Task aus TODO-Kommentar",
        },
        {
            "<leader>tc",
            function()
                vim.cmd("normal! <Esc>")
                require("tatr").from_comment({ visual = true })
            end,
            mode = "x",
            desc = "TATR: Task aus markierten Kommentaren",
        },
    },
}
