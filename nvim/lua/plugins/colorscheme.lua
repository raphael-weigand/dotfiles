return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha", 
            transparent_background = false,
            -- Weitere Optionen nach Bedarf
        })
        local function set_custom_highlights()
            local white = "#ffffff"
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
            vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { fg = white, bold = true })
            vim.api.nvim_set_hl(0, "LspCodeLens", { fg = white })
            vim.api.nvim_set_hl(0, "LspCodeLensSeparator", { fg = white })
            vim.api.nvim_set_hl(0, "LspReferenceText", { fg = white })
            vim.api.nvim_set_hl(0, "LspReferenceRead", { fg = white })
            vim.api.nvim_set_hl(0, "LspReferenceWrite", { fg = white })
            vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
            vim.api.nvim_set_hl(0, "LspCodeActionBorder", { fg = white })
            vim.api.nvim_set_hl(0, "LspRenameBorder", { fg = white })
        end
        set_custom_highlights()
    end,
}
