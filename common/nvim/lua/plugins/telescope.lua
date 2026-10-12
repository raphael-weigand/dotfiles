return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")
            local actions = require("telescope.actions")
            local themes = require("telescope.themes")

            telescope.setup({
                defaults = {
                    sorting_strategy = "ascending",
                    layout_config = { prompt_position = "top" },
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-q>"] = function(bufnr)
                                actions.smart_send_to_qflist(bufnr)
                                actions.open_qflist(bufnr)
                            end,
                            ["<M-q>"] = function(bufnr)
                                actions.send_selected_to_qflist(bufnr)
                                actions.open_qflist(bufnr)
                            end,
                            ["<Tab>"] = actions.toggle_selection,
                        },
                        n = {
                            ["<C-q>"] = function(bufnr)
                                actions.smart_send_to_qflist(bufnr)
                                actions.open_qflist(bufnr)
                            end,
                            ["<M-q>"] = function(bufnr)
                                actions.send_selected_to_qflist(bufnr)
                                actions.open_qflist(bufnr)
                            end,
                            ["<Tab>"] = actions.toggle_selection,
                        },
                    },
                },
                pickers = {
                    find_files = { theme = "dropdown", previewer = false },
                    buffers = { theme = "dropdown", previewer = false },
                },
                extensions = {
                    ["ui-select"] = themes.get_dropdown({}),
                },
            })

            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")

            local map = function(key, picker, description)
                vim.keymap.set("n", key, picker, { desc = description })
            end

            map("<C-p>", builtin.find_files, "Find files")
            map("<leader>fg", builtin.live_grep, "Live grep")
            map("<leader>fw", function()
                builtin.grep_string({ search = vim.fn.expand("<cword>") })
            end, "Find word under cursor")
            map("<leader>fb", builtin.buffers, "Find buffers")
            map("<leader>fr", builtin.oldfiles, "Recent files")
            map("<leader>fl", builtin.resume, "Resume Telescope")
            map("<leader>fs", builtin.lsp_document_symbols, "Document symbols")
            map("<leader>fS", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
            map("<leader>fd", builtin.diagnostics, "Diagnostics")
            map("<leader>fh", builtin.help_tags, "Help tags")
            map("<leader>Gc", builtin.git_commits, "Git commits")
            map("<leader>Gf", builtin.git_bcommits, "File commits")
            map("<leader>Gs", builtin.git_status, "Git status")
            map("<leader>fq", builtin.quickfix, "Search quickfix list")
        end,
    },
}
