" disable compatibility with vi
set nocompatible

" allow tab completion while opening files
set wildmenu

" show hybrid (real number for current line, others relative) line numbers
set number relativenumber

" indention with 4 white spaces
set tabstop=4
set expandtab
set shiftwidth=4

" file type specific indent
autocmd Filetype rst setlocal ts=2 sw=2 expandtab
autocmd Filetype dts setlocal ts=4 sw=4 noexpandtab

" indent new line like the line before
set autoindent

" try to guess the correct indention
set smartindent

" indent wrapped lines
set breakindent

" press f5 before pasting to stop indenting
set pastetoggle=<f5>

" remove trailing white space on save
autocmd BufWritePre * %s/\s\+$//e

" open new horizontal split below current
set splitbelow

" open new vertical split right to the current
set  splitright

" f6 opens file in new tab
nmap <f6> :browse tabe<CR>
imap <f6> <esc>:browse tabe<CR>

" f7 switches to previous tab
nmap <f7> :tabp<CR>
imap <f7> <esc>:tabp<CR>

" f8 switches to next tab
nmap <f8> :tabn<CR>
imap <f8> <esc>:tabn<CR>

" enable case insensitive search
set ignorecase

" use case sensitive search if it contains a capital letter
set smartcase

" enable spell checking
set spell spelllang=en_us

" keep this amount of context lines when scrolling
set scrolloff=10

" vim-plug plugin management (https://github.com/junegunn/vim-plug)
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

call plug#begin()

" file explorer
Plug 'preservim/nerdtree',

" easy (un)commenting
Plug 'tpope/vim-commentary',

" status line
Plug 'vim-airline/vim-airline',

" easy bracket handling
Plug 'tpope/vim-surround',

" fuzzy file search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim',

" markdown
Plug 'godlygeek/tabular',
Plug 'preservim/vim-markdown',

" restructuredText
Plug 'habamax/vim-rst',

" sensible vim defaults
Plug 'tpope/vim-sensible'

call plug#end()

" show NERDTree with CTRL-e
nnoremap <C-e> :NERDTreeToggle<CR>

" exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" if another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" disable Markdown folding
let g:vim_markdown_folding_disabled = 1
