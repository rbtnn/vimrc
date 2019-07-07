
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

set encoding=utf-8
if exists('&makeencoding')
    set makeencoding=char
endif
scriptencoding utf-8

set winaltkeys=yes guioptions=mM

let $DOTVIM = expand('~/.vim')
let $VIMTEMP = expand('$DOTVIM/temp')

silent! source $DOTVIM/gloaded.vim
silent! source $DOTVIM/tabsidebar.vim
silent! source $DOTVIM/clpum.vim

syntax on
filetype plugin indent on
set secure

set packpath=$DOTVIM

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = 's'

set autoread
set background=dark 
set clipboard=unnamed
set display=lastline
set expandtab softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set incsearch hlsearch
set keywordprg=:help
set laststatus=2 statusline&
set list listchars=tab:<->
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noignorecase
set noruler
set nowrap
set nowrapscan
set pumheight=10 completeopt=menu
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shellslash
set shortmess& shortmess+=I shortmess-=S
set showmode
set showtabline=0
set tags=./tags;
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

" swap nad backup files
silent! call mkdir(expand('$VIMTEMP/backupfiles'), 'p')
set noswapfile backup nowritebackup backupdir=$VIMTEMP/backupfiles//

" undo files
if has('persistent_undo')
    silent! call mkdir(expand('$VIMTEMP/undofiles'), 'p')
    set undofile undodir=$VIMTEMP/undofiles//
endif

inoremap <silent><nowait><tab>       <C-v><tab>
nnoremap <silent><nowait><C-j>       :<C-u>cnext<cr>zz
nnoremap <silent><nowait><C-k>       :<C-u>cprevious<cr>zz
nnoremap <silent><nowait><leader>f   :<C-u>Buffer<cr>
nnoremap <silent><nowait><leader>d   :<C-u>Diffy -w<cr>

" https://github.com/rprichard/winpty/releases/
if has('win32') && has('terminal')
    tnoremap <silent><C-p>       <up>
    tnoremap <silent><C-n>       <down>
    tnoremap <silent><C-b>       <left>
    tnoremap <silent><C-f>       <right>
    tnoremap <silent><C-e>       <end>
    tnoremap <silent><C-a>       <home>
    tnoremap <silent><C-u>       <esc>
endif

augroup vimrc
    autocmd!
    autocmd VimEnter,BufEnter * :silent! delcommand MANPAGER
    autocmd VimEnter          * :silent! colorscheme tender
augroup END

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

nohlsearch
