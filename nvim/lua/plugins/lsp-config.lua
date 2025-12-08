return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    }, {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    }, {
        "neovim/nvim-lspconfig",
        config = function()
            -- capabilities (Autocomplete etc.)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Gemeinsame Funktion für Keymaps etc.
            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, silent = true }

                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            end

            -- Dein Standard-Setup für alle Server
            local default_setup = function(server)
                vim.lsp.config[server].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                })
            end

            -- Mason-LSPConfig benutzen, um Server automatisch zu registrieren
            require("mason-lspconfig").setup({
                handlers = {
                    default_setup,

                    -- Beispiel für Lua Language Server:
                    lua_ls = function()
                        vim.lsp.config.lua_ls.setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim" },
                                    },
                                },
                            },
                        })
                    end,
                },
            })
        end,
    },
}

