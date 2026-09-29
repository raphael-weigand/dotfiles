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

            telescope.setup({
                defaults = {
                    sorting_strategy = "ascending",
                    preview = false,
                    layout_config = {
                        prompt_position = "top",
                    },
                    mappings = {
                        i = {
                            ["<C-k>"] = "move_selection_previous",
                            ["<C-j>"] = "move_selection_next",
                        },
                    },
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                        previewer = false,
                    },
                    buffers = {
                        theme = "dropdown",
                        previewer = false,
                    },
                },
                extensions = {
                    ["ui-select"] = require("telescope.themes").get_dropdown({}),
                },
            })

            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")

            vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
        end,
    },
}
