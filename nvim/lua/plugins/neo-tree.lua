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
            sources = {
                "filesystem",
                "buffers",
                "git_status",
            },
            close_if_last_window = true, -- Schließt Neo-tree, wenn es das letzte Fenster ist
            enable_git_status = true,
            enable_diagnostics = true,
            enable_modified_markers = true,
            enable_opened_markers = true,
            enable_refresh_on_write = true, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.
            enable_cursor_hijack = false, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
            git_status_async = true,
            check_gitignore_in_search = false,
            window = {
                position = "right", -- left, right, top, bottom, float, current
                width = 40,
            },
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_gitignored = false,
                    hide_hidden = false,
                    hide_dotfiles = false,
                    never_show = {
                        ".DS_Store",
                        "node_modules",
                        "Thumbs.db",
                        ".git"
                    },
                    never_show_by_pattern = {
                        "*.swp",
                    },
                    hide_by_pattern = {
                        "*.pyc",
                        "__pycache__",
                    }
                },
            },
            git_status = {
                window = {
                    mappings = {
                        ["A"] = "git_add_all",
                        ["gu"] = "git_unstage_file",
                        ["gU"] = "git_undo_last_commit",
                        ["ga"] = "git_add_file",
                        ["gt"] = "git_toggle_file_stage",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push",
                        ["i"] = "show_file_details", -- see `:h neo-tree-file-actions` for options to customize the window.
                        ["b"] = "rename_basename",
                        ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                        ["oc"] = { "order_by_created", nowait = false },
                        ["od"] = { "order_by_diagnostics", nowait = false },
                        ["om"] = { "order_by_modified", nowait = false },
                        ["on"] = { "order_by_name", nowait = false },
                        ["os"] = { "order_by_size", nowait = false },
                        ["ot"] = { "order_by_type", nowait = false },
                    },
                },
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
