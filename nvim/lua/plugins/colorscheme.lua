-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
    {
        "blazkowolf/gruber-darker.nvim",
        priority = 1000, -- sollte früh geladen werden
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
            -- aktuelle Zeilennummer gelb machen
            vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#52494e', bold=false })
            vim.api.nvim_set_hl(0, "LineNr", {
                fg = "#ffdd33",
                bold = true,
            })
            vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#52494e', bold=false })

            -- vim.api.nvim_set_hl(0, "Comment", { fg = "#75715e", italic = true })

            -- Tree-sitter Highlights nach Colorscheme neu setzen
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    vim.cmd("TSBufEnable highlight")
                end,
            })
        end,
    },
}
