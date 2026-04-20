return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    lazy = false, -- neo-tree will lazily load itself
    opts = { },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true, -- Schließt Neo-tree, wenn es das letzte Fenster ist
            enable_git_status = true,
            enable_diagnostics = true,

            window = {
                position = "right", -- left, right, top, bottom, float, current
                width = 40,
            },
        })

        -- Transparente Hintergründe für Neo-tree setzen
        vim.cmd([[
      augroup NeotreeTransparent
      autocmd!
      autocmd FileType neo-tree hi! NeoTreeNormal guibg=NONE ctermbg=NONE
      autocmd FileType neo-tree hi! NeoTreeNormalNC guibg=NONE ctermbg=NONE
      autocmd FileType neo-tree hi! NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
      augroup END
      ]])

        -- Eine Toggle-Funktion für Neo-tree
        local function toggle_neotree_right()
            if vim.bo.filetype == "neo-tree" then
                vim.cmd("Neotree close")
            else
                vim.cmd("Neotree filesystem reveal right")
            end
        end

        -- Tastenkombination für den Toggle
        vim.keymap.set("n", "<C-n>", toggle_neotree_right, { desc = "Toggle Neo-tree" })
    end,
}
