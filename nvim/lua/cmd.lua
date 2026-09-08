-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Move selected lines while keeping the selection
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Show whitespace only while selecting text
local visual_list_group = vim.api.nvim_create_augroup("VisualListChars", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
    group = visual_list_group,
    pattern = "*:[vV\22]*",
    callback = function()
        vim.opt_local.list = true
    end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = visual_list_group,
    pattern = "[vV\22]*:*",
    callback = function()
        vim.opt_local.list = false
    end,
})

vim.opt.listchars = {
    space = "·",
    tab = "» ",
    trail = "·",
}
