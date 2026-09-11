-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Files and buffers
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.swapfile = false

-- Indentation
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- UI and navigation
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Clipboard
vim.opt.clipboard:prepend({ "unnamed", "unnamedplus" })
vim.g.clipboard = "osc52"

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.path:append("**")

-- Persistent session data
vim.opt.shada = "!,'1000,<50,s10,h"

-- Cursor
vim.opt.guicursor = "n-v-i:block,a:blinkwait700-blinkoff400-blinkon250"

-- Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
})
