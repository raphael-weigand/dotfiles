set nocompatible

" Dateiverwaltung
syntax on
set autoread
set hidden
set autoindent
set tabstop=4
set shiftwidth=4
filetype indent on
filetype on

" Rücktaste
set backspace=indent,eol,start

" Cursor Position wird gemerkt
if has("autocmd")
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Navigation & UI
set number
set relativenumber
set showcmd
set ruler
set nowrap
set scrolloff=8
set colorcolumn=80
highlight ColorColumn ctermbg=darkgray guibg=#2c2c2c
" set termguicolors

" Suche
set ignorecase
set smartcase
set incsearch
set hlsearch

" Kommando Historie
set history=300

" Zwischenablage
set clipboard^=unnamed
set clipboard^=unnamedplus

" Statuszeile 
set showmode
set laststatus=2

" Dateipfade
set wildmenu
set wildmode=longest:full,full
set path+=**   

" Call the .vimrc.plug file
if filereadable(expand("~/.vimrc.plug"))
	source ~/.vimrc.plug
endif

