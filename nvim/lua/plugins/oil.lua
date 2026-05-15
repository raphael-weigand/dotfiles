return {
    "stevearc/oil.nvim",
    opts = {
        columns = {
            "permissions",
            "size",
            "mtime",
        },
        keymaps = {
            -- ["<C-n>"] = "actions.select",
            ["<C-s>"] = { "actions.select", opts = { vertical = true } },
            ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
            ["<C-t>"] = { "actions.select", opts = { tab = true } },
            ["<C-p>"] = "actions.preview",
            ["-"] = { "actions.parent", mode = "n" },
            ["_"] = { "actions.open_cwd", mode = "n" },
        },
        view_options = {
            show_hidden = false,

            is_hidden_file = function(name, bufnr)
                local hidden = {
                    [".git"] = true,
                    ["__pycache__"] = true,
                    [".pytest_cache"] = true,
                    [".mypy_cache"] = true,
                    [".ruff_cache"] = true,
                    [".venv"] = true,
                    ["venv"] = true,
                    ["dist"] = true,
                    ["build"] = true,
                }

                return hidden[name]
                -- python files
                or name:match("%.egg%-info$")
                or name:match("%.pyc$")
                or name:match("%.pyo$")

                -- c specific files
                or name:match("%.o$")
            end,
        },
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = false,
    },
    keys = {
        { "<C-n>", "<CMD>Oil<CR>", desc = "Open oil.nvim" },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
}

