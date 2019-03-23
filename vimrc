call plug#begin('~/.vim/plugged')
Plug 'https://github.com/dracula/vim.git'
Plug 'https://github.com/scrooloose/nerdtree'
Plug 'https://github.com/kien/ctrlp.vim'
Plug 'https://github.com/vim-airline/vim-airline'
Plug 'https://github.com/tpope/vim-fugitive'
call plug#end()

syntax on
filetype indent plugin on
filetype detect
color dracula
set nocompatible
set nowrap
set autoindent
set background=dark
set encoding=utf-8
set clipboard=unnamed
set showmatch
set ignorecase
set smarttab
set hlsearch
set incsearch
set number
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set scrolloff=3
set laststatus=2
set cursorline
set belloff=all

let NERDTreeShowHidden=1

let g:airline_powerline_fonts = 1
let g:airline_theme = 'dracula'
"let g:airline#extensions#tabline#enabled = 0 
let g:airline#extensions#branch#enabled = 1 
"let g:airline_section_warning = '' 
"set laststatus=2 " for airline

let mapleader=","
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

map <C-n> :NERDTreeToggle<CR>
map <C-t> <C-w><C-w>
nnoremap <CR> G
" switch to left / right split (mostly for Nerd Tree)
map <C-h> <C-W>h
map <C-l> <C-W>l

" move between buffers
map <C-Left> <Esc>:bprev<CR>
map <C-Right> <Esc>:bnext<CR>

set nobackup
set noswapfile
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " autoquit if only nerdtree is open







