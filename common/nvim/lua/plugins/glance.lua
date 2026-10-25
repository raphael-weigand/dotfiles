return {
    {
        "DNLHC/glance.nvim",
        cmd = "Glance",
        opts = function()
            local actions = require("glance").actions

            return {
                mappings = {
                    list = {
                        ["<C-h>"] = actions.enter_win("preview"),
                    },
                    preview = {
                        ["<C-l>"] = actions.enter_win("list"),
                    },
                },
            }
        end,
        keys = {
            {
                "gpt",
                "<cmd>Glance definitions<CR>",
                desc = "Peek definition",
            },
            {
                "gpi",
                "<cmd>Glance implementations<CR>",
                desc = "Peek implementation",
            },
            {
                "gpr",
                "<cmd>Glance references<CR>",
                desc = "Peek references",
            },
        },
    },
}
