return {
    {
        "DNLHC/glance.nvim",
        cmd = "Glance",
        opts = {},
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
