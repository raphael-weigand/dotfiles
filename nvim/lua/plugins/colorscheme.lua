return {
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000, 
    config = function()
        require("catppuccin").setup({
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            transparent_background = false,
            -- Weitere Optionen nach Bedarf
        })
        -- 1. Kein Farbschema laden
        vim.cmd.colorscheme = ''

        -- 2. Terminal-Farben explizit aktivieren
        vim.o.termguicolors = false
    end,
}

