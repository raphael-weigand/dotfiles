return {
    {
        "DNLHC/glance.nvim",
        cmd = "Glance",
        opts = {},
        keys = {
            {
                "gp",
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
