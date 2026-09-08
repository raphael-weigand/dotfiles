return {
    {
        "nvim-lualine/lualine.nvim",
        priority = 1010,
        config = function()
            local colors = {
                fg = "#e4e4ef",
                bg = "#181818",
                bg1 = "#282828",
                bg2 = "#453d41",
                yellow = "#ffdd33",
                green = "#73c936",
                red = "#f43841",
                niagara = "#96a6c8",
                quartz = "#95a99f",
                wisteria = "#9e95c7",
            }

            local theme = {
                normal = {
                    a = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
                    b = { fg = colors.fg, bg = colors.bg2 },
                    c = { fg = colors.quartz, bg = colors.bg },
                },
                insert = {
                    a = { fg = colors.bg, bg = colors.green, gui = "bold" },
                },
                visual = {
                    a = { fg = colors.bg, bg = colors.wisteria, gui = "bold" },
                },
                replace = {
                    a = { fg = colors.bg, bg = colors.red, gui = "bold" },
                },
                command = {
                    a = { fg = colors.bg, bg = colors.niagara, gui = "bold" },
                },
                inactive = {
                    a = { fg = colors.quartz, bg = colors.bg1 },
                    b = { fg = colors.quartz, bg = colors.bg },
                    c = { fg = colors.quartz, bg = colors.bg },
                },
            }

            require("lualine").setup({
                options = {
                    theme = theme,
                    globalstatus = true,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
            })
        end,
    },
}
