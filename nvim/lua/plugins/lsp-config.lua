return {
    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Extend every LSP configuration with completion capabilities.
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- Lua-specific settings. Installed Mason servers are enabled by
            -- mason-lspconfig automatically.
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            })

            -- Buffer-local mappings only exist while an LSP client is attached.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
                callback = function(event)
                    local opts = { buffer = event.buf, silent = true }
                    local map = function(lhs, rhs, desc)
                        vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
                    end

                    map("<leader>gd", vim.lsp.buf.definition, "LSP: Go to definition")
                    map("<leader>gr", vim.lsp.buf.references, "LSP: References")
                    map("<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
                    map("<leader>gf", function()
                        vim.lsp.buf.format({ async = true })
                    end, "LSP: Format buffer")
                end,
            })
        end,
    },
}
