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
        vim.cmd.colorscheme "catppuccin"
    end,
}

