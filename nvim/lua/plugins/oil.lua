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
        {
            "<C-n>",
            function()
                local oil = require("oil")

                -- find oil windows
                local oil_wins = {}

                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "oil" then
                        table.insert(oil_wins, win)
                    end
                end

                -- if Oil is open → close its window(s)
                if #oil_wins > 0 then
                    for _, win in ipairs(oil_wins) do
                        -- avoid closing last window
                        if #vim.api.nvim_list_wins() > 1 then
                            vim.api.nvim_win_close(win, true)
                        else
                            -- fallback: just leave Oil buffer instead of closing window
                            vim.cmd("b#")
                        end
                    end
                    return
                end

                -- otherwise open Oil
                oil.open()
            end,
            desc = "Toggle oil.nvim",
        },
    },

    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
}

