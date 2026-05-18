-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) test',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {clear=true}),
    callback = function ()
        vim.highlight.on_yank()
    end,
})

-- Visual mode
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
