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

                    -- Keep the same navigation muscle memory as VsVim.
                    map("gd", vim.lsp.buf.definition, "LSP: Go to definition")
                    map("gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
                    map("gr", vim.lsp.buf.references, "LSP: References")
                    map("K", vim.lsp.buf.hover, "LSP: Hover")

                    map("<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
                    map("<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
                    map("<leader>gf", function()
                        vim.lsp.buf.format({ async = true })
                    end, "LSP: Format buffer")

                    -- Tsoding formats whole C-family buffers with astyle. Keep
                    -- the same workflow, but use the attached LSP/clangd so
                    -- project .clang-format settings are respected.
                    if vim.bo[event.buf].filetype == "c" or vim.bo[event.buf].filetype == "cpp" then
                        map("<leader>cf", function()
                            vim.lsp.buf.format({
                                async = false,
                                bufnr = event.buf,
                                filter = function(client)
                                    return client.name == "clangd"
                                end,
                            })
                        end, "C/C++: Format buffer")
                    end
                end,
            })
        end,
    },
}
