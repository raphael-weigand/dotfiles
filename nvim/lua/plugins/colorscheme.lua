return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha", 
            transparent_background = false,
        })
        
        local function set_custom_highlights()
            local white = "#ffffff"
            
            -- Weiße Overlay-Rahmen
            vim.api.nvim_set_hl(0, "FloatBorder", { fg = white })
            vim.api.nvim_set_hl(0, "LspInfoBorder", { fg = white })
            vim.api.nvim_set_hl(0, "PmenuBorder", { fg = white })
            vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = white })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = white })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = white })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = white })
            vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = white })
            vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = white })
            vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = white })
            vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = white })
        end
        
        -- Setze die Custom Highlights sofort
        set_custom_highlights()
    end,
}
