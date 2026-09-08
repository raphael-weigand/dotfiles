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
                fg2 = "#f5f5f5",
                white = "#ffffff",
                black = "#000000",
                bg0 = "#101010",
                bg = "#181818",
                bg1 = "#282828",
                bg2 = "#453d41",
                bg3 = "#484848",
                bg4 = "#52494e",
                red1 = "#c73c3f",
                red = "#f43841",
                red_plus = "#ff4f58",
                green = "#73c936",
                yellow = "#ffdd33",
                brown = "#cc8c3c",
                quartz = "#95a99f",
                niagara1 = "#565f73",
                niagara = "#96a6c8",
                wisteria = "#9e95c7",
            }

            local set = vim.api.nvim_set_hl

            -- Core editor UI.
            set(0, "Normal", { fg = colors.fg, bg = colors.bg })
            set(0, "NormalNC", { fg = colors.fg, bg = colors.bg })
            set(0, "Cursor", { bg = colors.yellow })
            set(0, "CursorLine", { bg = colors.bg1 })
            set(0, "CursorColumn", { bg = colors.bg1 })
            set(0, "ColorColumn", { bg = colors.bg1 })
            set(0, "Visual", { bg = colors.bg3 })
            set(0, "LineNrAbove", { fg = colors.bg4 })
            set(0, "LineNr", { fg = colors.yellow })
            set(0, "LineNrBelow", { fg = colors.bg4 })
            set(0, "SignColumn", { fg = colors.bg2, bg = colors.bg })
            set(0, "WinSeparator", { fg = colors.bg2 })
            set(0, "NonText", { fg = colors.bg4 })
            set(0, "Whitespace", { fg = colors.bg4 })
            set(0, "EndOfBuffer", { fg = colors.bg })

            -- Search follows Emacs isearch/lazy-highlight faces.
            set(0, "IncSearch", { fg = colors.black, bg = colors.fg2 })
            set(0, "CurSearch", { fg = colors.black, bg = colors.fg2 })
            set(0, "Search", { fg = colors.fg1, bg = colors.niagara1 })
            set(0, "Substitute", { fg = colors.black, bg = colors.fg2 })

            -- Matching and selection.
            set(0, "MatchParen", { bg = colors.bg4 })
            set(0, "QuickFixLine", { bg = colors.bg1 })
            set(0, "Folded", { fg = colors.quartz, bg = colors.bg1 })
            set(0, "FoldColumn", { fg = colors.bg4, bg = colors.bg })

            -- Floating windows and completion menus approximate Emacs tooltip
            -- and Helm selection faces using the same original palette.
            set(0, "NormalFloat", { fg = colors.white, bg = colors.bg4 })
            set(0, "FloatBorder", { fg = colors.bg2, bg = colors.bg4 })
            set(0, "FloatTitle", { fg = colors.yellow, bg = colors.bg4, bold = true })
            set(0, "Pmenu", { fg = colors.fg, bg = colors.bg })
            set(0, "PmenuSel", { fg = colors.fg, bg = colors.bg1 })
            set(0, "PmenuKind", { fg = colors.niagara, bg = colors.bg })
            set(0, "PmenuExtra", { fg = colors.bg4, bg = colors.bg })
            set(0, "PmenuSbar", { bg = colors.bg1 })
            set(0, "PmenuThumb", { bg = colors.bg4 })

            -- Statusline/tabline keep the low-contrast Gruber UI with yellow
            -- used only for the active/current element.
            set(0, "StatusLine", { fg = colors.fg, bg = colors.bg2 })
            set(0, "StatusLineNC", { fg = colors.bg4, bg = colors.bg1 })
            set(0, "TabLine", { fg = colors.bg4, bg = colors.bg1 })
            set(0, "TabLineFill", { fg = colors.bg4, bg = colors.bg })
            set(0, "TabLineSel", { fg = colors.yellow, bg = colors.bg2, bold = true })

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
            set(0, "Directory", { fg = colors.niagara, bold = true })
            set(0, "Special", { fg = colors.wisteria })

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

            -- Diff and diagnostics mirror the original Diff/Compilation/Flymake faces.
            set(0, "DiffAdd", { fg = colors.green, bg = colors.bg })
            set(0, "DiffDelete", { fg = colors.red_plus, bg = colors.bg })
            set(0, "DiffChange", { fg = colors.brown, bg = colors.bg })
            set(0, "DiffText", { fg = colors.yellow, bg = colors.bg1, bold = true })

            set(0, "DiagnosticError", { fg = colors.red })
            set(0, "DiagnosticWarn", { fg = colors.yellow })
            set(0, "DiagnosticInfo", { fg = colors.green })
            set(0, "DiagnosticHint", { fg = colors.niagara })
            set(0, "DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
            set(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = colors.yellow })
            set(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = colors.green })
            set(0, "DiagnosticUnderlineHint", { undercurl = true, sp = colors.niagara })

            -- Telescope: the original Helm theme uses bg+1 for selection,
            -- Niagara for directories/prompts, and yellow for source headers.
            set(0, "TelescopeNormal", { fg = colors.fg, bg = colors.bg })
            set(0, "TelescopeBorder", { fg = colors.bg2, bg = colors.bg })
            set(0, "TelescopePromptNormal", { fg = colors.fg, bg = colors.bg })
            set(0, "TelescopePromptBorder", { fg = colors.bg2, bg = colors.bg })
            set(0, "TelescopePromptPrefix", { fg = colors.niagara })
            set(0, "TelescopeSelection", { fg = colors.fg, bg = colors.bg1 })
            set(0, "TelescopeMatching", { fg = colors.yellow, bold = true })
            set(0, "TelescopeTitle", { fg = colors.yellow, bg = colors.bg, bold = true })
        end,
    },
}
