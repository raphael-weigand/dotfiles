-- Grundeinstellungen
vim.opt.compatible = false
vim.opt.syntax = "on"
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.swapfile = false

-- Einrückung und Tabs
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4

-- Dateityp-Erkennung
vim.cmd("filetype indent on")
vim.cmd("filetype on")

-- Rücktaste
vim.opt.backspace = {"indent", "eol", "start"}

-- Navigation & UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showcmd = true
vim.opt.ruler = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "no"
vim.opt.termguicolors = false

-- Highlight für colorcolumn
vim.cmd("highlight ColorColumn ctermbg=darkgray guibg=#2c2c2c")

-- Suche
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Historie
vim.opt.history = 300

-- Zwischenablage
vim.opt.clipboard:prepend({"unnamed", "unnamedplus"})

-- Statuszeile
vim.opt.showmode = true
vim.opt.laststatus = 2

-- Dateipfade und Wildmenu
vim.opt.wildmenu = true
vim.opt.wildmode = {"longest:full", "full"}
vim.opt.path:append("**")

-- Folding basierend auf Syntax/Sprache
vim.opt.foldmethod = "indent"     -- Folding basierend auf Indent
vim.opt.foldlevelstart = 99       -- Beim Öffnen alle Folds geöffnet
vim.opt.foldenable = true         -- Folding aktivieren
vim.opt.foldnestmax = 10          -- Maximale Verschachtelungstiefe

-- Optional: Fallback auf indent für Sprachen ohne Syntax-Folding
vim.cmd([[
  augroup FoldingSettings
    autocmd!
    " Für Sprachen mit guter Syntax-Unterstützung
    autocmd FileType javascript,typescript,python,java,cpp,rust,go setlocal foldmethod=syntax
    " Für markup/config Dateien - indent-basiert
    autocmd FileType yaml,json,xml,html setlocal foldmethod=indent
    " Für Markdown - expr-basiert (falls verfügbar)
    " autocmd FileType markdown setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^#'
  augroup END
]])

-- Shada (Session Data)
vim.opt.shada = "!,'1000,<50,s10,h"

-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Blinking cursor
vim.opt.guicursor = "n-v-i:block,a:blinkwait700-blinkoff400-blinkon250"

-- Show diagnostic
vim.diagnostic.config({
    virtual_text = true,  -- Zeigt Errors/Warnings inline
    signs = true,         -- Zeigt Icons in der sign column
    underline = true,     -- Unterstreicht problematische Stellen
    update_in_insert = false,  -- Nicht während Insert Mode updaten
    float = {
        border = "single"   -- Weiße Rahmen für Diagnostic Popups
    }
})

-- Finally an article showing how to enable borders: https://samuellawrentz.com/blog/vim-lsp-hover-borders/
vim.o.winborder = 'rounded'

