return {
    {
        "blazkowolf/gruber-darker.nvim",
        priority = 1000,
        opts = {
            bold = false,
            italic = {
                strings = false,
                comments = true,
                operators = false,
                folds = true,
            },
            undercurl = true,
            underline = true,
            invert = {
                signs = false,
                tabline = false,
                visual = false,
            },
            inverse = true,
            transparent = false,
        },
        config = function(_, opts)
            require("gruber-darker").setup(opts)
            vim.o.background = "dark"
            vim.cmd.colorscheme("gruber-darker")

            vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#52494e", bold = false })
            vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffdd33", bold = true })
            vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#52494e", bold = false })
        end,
    },
}
