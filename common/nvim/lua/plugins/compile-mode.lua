return {
    "ej-shafran/compile-mode.nvim",
    version = "^5.0.0",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        vim.g.compile_mode = {
            default_command = "make -k ",
            focus_compilation_buffer = true,
            auto_scroll = true,
        }
    end,
    keys = {
        { "<leader>cc", "<cmd>Compile<cr>", desc = "Compile" },
        { "<leader>cr", "<cmd>Recompile<cr>", desc = "Recompile" },
        { "<leader>ck", "<cmd>CompileInterrupt<cr>", desc = "Stop compilation" },
        { "<leader>cn", "<cmd>NextError<cr>", desc = "Next compile error" },
        { "<leader>cp", "<cmd>PrevError<cr>", desc = "Previous compile error" },
    },
}
