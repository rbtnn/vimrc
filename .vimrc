
set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=m

" for less on windows
let $LESSCHARSET = 'utf-8'

let $VIMRC_ROOT = expand('<sfile>:h') 
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_TEMP = expand('$VIMRC_DOTVIM/temp')

set runtimepath+=$VIMRC_DOTVIM

set ambiwidth=double
set autoread
set background=dark
set clipboard=unnamed
set display=lastline
set expandtab shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set ignorecase nosmartcase
set keywordprg=:help
set laststatus=2 statusline&
set list nowrap breakindent& showbreak& listchars=tab:<->,trail:-
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noshellslash completeslash=slash
set nowrapscan
set nrformats=
set pumheight=10 completeopt=menu
set ruler rulerformat=%{&fenc}/%{&ff}/%{&ft}
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shortmess& shortmess-=S
set showmode
set showtabline=0 tabline&
set tags=./tags;
set termguicolors
set title titlestring=%{v:progname}[%{getpid()}]
set visualbell noerrorbells t_vb=
set wildmenu wildmode&

set wildignore=*.pdb,*.obj,*.dll,*.exe,*.idb,*.ncb,*.ilk,*.plg,*.bsc,*.sbr,*.opt,*.config
set wildignore+=*.pdf,*.mp3,*.doc,*.docx,*.xls,*.xlsx,*.idx,*.jpg,*.png,*.zip,*.MMF
set wildignore+=*.resX,*.lib,*.resources,*.ico,*.suo,*.cache,*.user,*.myapp,*.dat,*.dat01

setglobal incsearch hlsearch

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = '\'

source $VIMRC_DOTVIM/gloaded.vim
source $VIMRC_DOTVIM/tabsidebar.vim
source $VIMRC_DOTVIM/etc.vim

" swap and backup files
silent! call mkdir(expand('$VIMRC_TEMP/backupfiles'), 'p')
set noswapfile backup nowritebackup backupdir=$VIMRC_TEMP/backupfiles//

" undo files
if has('persistent_undo')
    silent! call mkdir(expand('$VIMRC_TEMP/undofiles'), 'p')
    set undofile undodir=$VIMRC_TEMP/undofiles//
endif

nnoremap <silent><nowait><C-j>       :<C-u>cnext<cr>zz
nnoremap <silent><nowait><C-k>       :<C-u>cprevious<cr>zz

command! -bar -nargs=0 SessionSave   :mksession! $VIMRC_TEMP/session.vim
command! -bar -nargs=0 SessionLoad   :source $VIMRC_TEMP/session.vim

if has('win32')
    command! -complete=file -nargs=* WinExplorer  :silent! execute printf('!start explorer %s', (empty(<q-args>) ? '.' : <q-args>))

    " https://github.com/rprichard/winpty/releases/
    tnoremap <silent><C-p>       <up>
    tnoremap <silent><C-n>       <down>
    tnoremap <silent><C-b>       <left>
    tnoremap <silent><C-f>       <right>
    tnoremap <silent><C-e>       <end>
    tnoremap <silent><C-a>       <home>
    tnoremap <silent><C-u>       <esc>
endif

if filereadable(expand('$VIMRC_DOTVIM/autoload/plug.vim'))
    call plug#begin('$VIMRC_TEMP/plugged')
    Plug 'haya14busa/vim-asterisk'
    Plug 'rbtnn/vim-coloredit'
    Plug 'rbtnn/vim-diffy'
    Plug 'rbtnn/vim-jumptoline'
    Plug 'rbtnn/vim-tagfunc-for-vimscript'
    Plug 'rbtnn/vim-vimbuild'
    Plug 'thinca/vim-qfreplace'
    call plug#end()

    source $VIMRC_DOTVIM/asterisk.vim
    source $VIMRC_DOTVIM/diffy.vim
    source $VIMRC_DOTVIM/jumptoline.vim
    source $VIMRC_DOTVIM/vimbuild.vim
endif

syntax on
filetype plugin indent on
set secure

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

augroup vimrc
    autocmd!
    autocmd VimEnter,BufEnter  * :silent! delcommand MANPAGER
    autocmd VimEnter,BufEnter  * :silent! delcommand VimFoldh
augroup END

silent! colorscheme xxx
