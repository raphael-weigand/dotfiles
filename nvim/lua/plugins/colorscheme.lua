return {
    {
        "blazkowolf/gruber-darker.nvim",
        priority = 1000,
        opts = {
            -- Tsoding's original Emacs theme uses bold keywords, but otherwise
            -- keeps the syntax styling deliberately simple.
            bold = true,
            italic = {
                strings = false,
                comments = false,
                operators = false,
                folds = false,
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

            -- Faithful mappings from rexim/gruber-darker-theme.el.
            local colors = {
                fg = "#e4e4ef",
                fg1 = "#f4f4ff",
                bg = "#181818",
                bg1 = "#282828",
                bg3 = "#484848",
                bg4 = "#52494e",
                red = "#f43841",
                green = "#73c936",
                yellow = "#ffdd33",
                brown = "#cc8c3c",
                quartz = "#95a99f",
                niagara = "#96a6c8",
                wisteria = "#9e95c7",
            }

            local set = vim.api.nvim_set_hl

            -- Core editor UI.
            set(0, "Normal", { fg = colors.fg, bg = colors.bg })
            set(0, "Cursor", { bg = colors.yellow })
            set(0, "CursorLine", { bg = colors.bg1 })
            set(0, "Visual", { bg = colors.bg3 })
            set(0, "Search", { bg = colors.bg4 })
            set(0, "IncSearch", { fg = colors.bg, bg = colors.yellow })
            set(0, "LineNrAbove", { fg = colors.bg4 })
            set(0, "LineNr", { fg = colors.yellow })
            set(0, "LineNrBelow", { fg = colors.bg4 })

            -- Classic Emacs font-lock palette.
            set(0, "Comment", { fg = colors.brown })
            set(0, "String", { fg = colors.green })
            set(0, "Function", { fg = colors.niagara })
            set(0, "Keyword", { fg = colors.yellow, bold = true })
            set(0, "Statement", { fg = colors.yellow, bold = true })
            set(0, "PreProc", { fg = colors.quartz })
            set(0, "Type", { fg = colors.quartz })
            set(0, "Constant", { fg = colors.quartz })
            set(0, "Identifier", { fg = colors.fg1 })

            -- Tree-sitter equivalents so modern Neovim syntax follows the
            -- same semantic palette as the Emacs font-lock faces.
            set(0, "@comment", { link = "Comment" })
            set(0, "@string", { link = "String" })
            set(0, "@function", { link = "Function" })
            set(0, "@function.call", { link = "Function" })
            set(0, "@method", { link = "Function" })
            set(0, "@method.call", { link = "Function" })
            set(0, "@keyword", { link = "Keyword" })
            set(0, "@type", { link = "Type" })
            set(0, "@type.builtin", { link = "Type" })
            set(0, "@constant", { link = "Constant" })
            set(0, "@variable", { link = "Identifier" })

            -- Diagnostics use the same warning/error/success colors as the
            -- original theme's compilation and Flymake faces.
            set(0, "DiagnosticError", { fg = colors.red })
            set(0, "DiagnosticWarn", { fg = colors.yellow })
            set(0, "DiagnosticInfo", { fg = colors.green })
            set(0, "DiagnosticHint", { fg = colors.niagara })
            set(0, "Special", { fg = colors.wisteria })
        end,
    },
}
