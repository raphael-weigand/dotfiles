-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) test',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {clear=true}),
    callback = function ()
        vim.highlight.on_yank()
    end,
})

-- Copy to clipboard over SSH
vim.g.clipboard = 'osc52'
