
if has('vimscript-4')
    scriptversion 4
else
    finish
endif

set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=m

let $DOTVIM = expand('~/.vim')
let $VIMTEMP = expand('$DOTVIM/temp')

set runtimepath+=$DOTVIM

set ambiwidth=double
set autoread
set background=dark
set clipboard=unnamed
set cmdheight=3
set colorcolumn&
set display=lastline
set expandtab shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set incsearch hlsearch
set keywordprg=:help
set laststatus=2 statusline&
set nolist nowrap breakindent showbreak=\\ listchars=tab:<->
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noignorecase
set noshellslash completeslash=slash
set nowrapscan
set nrformats=
set pumheight=10 completeopt=menu
set ruler rulerformat=%{&fenc}/%{&ff}/%{&ft}
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shortmess& shortmess+=I shortmess-=S
set showmode
set showtabline=0
set tags=./tags;
set termguicolors
set title titlestring=%{bufname()}(%l,%c)\ -\ %{v:progname}[%{getpid()}]
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = '\'

source $DOTVIM/gloaded.vim
source $DOTVIM/tabsidebar.vim
source $DOTVIM/clpum.vim
source $DOTVIM/rust.vim
source $DOTVIM/quickrun.vim
source $DOTVIM/etc.vim

" swap and backup files
silent! call mkdir(expand('$VIMTEMP/backupfiles'), 'p')
set noswapfile backup nowritebackup backupdir=$VIMTEMP/backupfiles//

" undo files
if has('persistent_undo')
    silent! call mkdir(expand('$VIMTEMP/undofiles'), 'p')
    set undofile undodir=$VIMTEMP/undofiles//
endif

nnoremap <silent><nowait><C-j>       :<C-u>cnext<cr>zz
nnoremap <silent><nowait><C-k>       :<C-u>cprevious<cr>zz
nnoremap <silent><nowait><space>     :<C-u>JumpToLine<cr>
nnoremap <silent><nowait><C-f>       :<C-u>MRU<cr>

map      <silent><nowait>s           <Plug>(operator-replace)

command! -bar -nargs=0 QfConv        :call diffy#sillyiconv#qficonv()

if has('win32')
    command! -bar -nargs=0 Explorer  :!start explorer .
endif

command! -bar -nargs=0 SessionSave   :mksession! $VIMTEMP/session.vim
command! -bar -nargs=0 SessionLoad   :source $VIMTEMP/session.vim

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

call plug#begin('$VIMTEMP/plugged')
Plug 'itchyny/vim-parenmatch'
Plug 'kana/vim-operator-replace'
Plug 'kana/vim-operator-user'
Plug 'kana/vim-textobj-user'
Plug 'rbtnn/vim-coloredit'
Plug 'rbtnn/vim-diffy'
Plug 'rbtnn/vim-jumptoline'
Plug 'rbtnn/vim-mru'
Plug 'sgur/vim-textobj-parameter'
Plug 'thinca/vim-qfreplace'
call plug#end()

syntax on
filetype plugin indent on
set secure

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

augroup vimrc
    autocmd!
    autocmd VimEnter,BufEnter  * :silent! delcommand MANPAGER
augroup END

silent! colorscheme xxx

nohlsearch
