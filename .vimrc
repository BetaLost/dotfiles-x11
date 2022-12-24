" Vim Plug
call plug#begin('~/.vim/plugged')

" HTML Emmet
Plug 'mattn/emmet-vim'

" Autocomplete
Plug 'ycm-core/YouCompleteMe'
Plug 'ervandew/supertab'

" Close tags
Plug 'spf13/vim-autoclose'
Plug 'alvan/vim-closetag'

" File Explorer
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Colors
Plug 'dracula/vim', { 'name': 'dracula' }
Plug 'lilydjwg/colorizer'
Plug 'vim-python/python-syntax'
Plug 'yuezk/vim-js'
Plug 'rust-lang/rust.vim'
Plug 'bfrg/vim-cpp-modern'

call plug#end()

" General configuration
filetype indent on
syntax on
set number
set ts=4 sw=4
set signcolumn=no
set pastetoggle=<F2>
set ttimeoutlen=0
set completeopt=menu
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[5 q"

" Dracula Color Scheme
colorscheme dracula
hi Normal ctermbg=none
hi NonText ctermbg=none
hi LineNr ctermbg=none

" NERDTree
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
let NERDTreeMinimalUI = 1
let NERDTreeWinSize = 20

" Build System
autocmd FileType python map <C-b> :w<CR>:!clear && python3 % && clear<CR>
autocmd FileType rust map <C-b> :w<CR>:!clear && cargo run<CR>

" Status Bar
let g:currentmode={
       \ 'n': 'NORMAL ',
       \ 'v': 'VISUAL ',
       \ 'V': 'V·LINE ',
       \ "\<C-V>": 'V·BLOCK ',
       \ 'i': 'INSERT ',
       \ 'R': 'REPLACE ',
       \ 'Rv': 'V·REPLACE ',
       \ 'c': 'COMMAND ',
       \}

let g:R_ARROW="\uE0B0"
let g:L_ARROW="\uE0B2"

"Green BG
hi User1 ctermfg=0 ctermbg=49

" Arrow 1
hi User5 ctermfg=49 ctermbg=39

" Arrow 2
hi User6 ctermfg=39 ctermbg=220

" Arrow 3
hi User7 ctermfg=220 ctermbg=0

" Green FG
hi User2 ctermfg=49 ctermbg=0

" Blue BG
hi User3 ctermfg=0 ctermbg=39

" Yellow BG
hi User4 ctermfg=0 ctermbg=220

set laststatus=2
set noshowmode
set statusline=

set statusline+=%1*
set statusline+=\ %{g:currentmode[mode()]}

set statusline+=%5*
set statusline+=%{g:R_ARROW}

set statusline+=%3*\ 
set statusline+=%{&modified?'MODIFIED\ ':'UNMODIFIED\ '}

set statusline+=%6*
set statusline+=%{g:R_ARROW}

set statusline+=%4*\ 
set statusline+=%{&readonly?'LOCKED\ ':'UNLOCKED\ '}

set statusline+=%7*
set statusline+=%{g:R_ARROW}

set statusline+=%2*
set statusline+=\ %F
set statusline+=\%=

set statusline+=%7*
set statusline+=%{g:L_ARROW}

set statusline+=%4*
set statusline+=\ %l/%L\ 

set statusline+=%6*
set statusline+=%{g:L_ARROW}

set statusline+=%3*
set statusline+=\ %{&filetype}\ 

set statusline+=%5*
set statusline+=%{g:L_ARROW}

set statusline+=%1*
set statusline+=\ %{&fenc}\ 

" Python Syntax Highlighting
let g:python_highlight_all = 1
