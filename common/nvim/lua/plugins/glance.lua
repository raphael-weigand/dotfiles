return {
    {
        "DNLHC/glance.nvim",
        cmd = "Glance",
        opts = function()
            local actions = require("glance").actions

            return {
                mappings = {
                    list = {
                        ["<C-l>"] = actions.enter_win("preview"),
                    },
                    preview = {
                        ["<C-h>"] = actions.enter_win("list"),
                    },
                },
            }
        end,
        keys = {
            {
                "<leader>gp",
                "<cmd>Glance definitions<CR>",
                desc = "Peek definition",
            },
            {
                "<leader>gpi",
                "<cmd>Glance implementations<CR>",
                desc = "Peek implementation",
            },
            {
                "<leader>gpr",
                "<cmd>Glance references<CR>",
                desc = "Peek references",
            },
        },
    },
}
