return {
    "neovim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    priority = 1000,
    lazy = false,
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
            end,
        })

        -- Tree-sitter based folding lives here so it has a single owner.
        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldlevel = 99
        vim.opt.foldlevelstart = 99
        vim.opt.foldenable = true
        vim.opt.foldnestmax = 10
    end,
}
