
if exists('&makeencoding')
    set makeencoding=char
endif
scriptencoding utf-8

set winaltkeys=yes guioptions=mM

let $VIMPLUGINS = expand('~/vimplugins')
let $VIMTEMP = expand('~/vimtemp')

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = ' '

set runtimepath=
set runtimepath+=$VIMPLUGINS/vim-color-spring-night
set runtimepath+=$VIMPLUGINS/vim-diffy
set runtimepath+=$VIMPLUGINS/vim-gloaded
set runtimepath+=$VIMPLUGINS/vim-qfreplace
set runtimepath+=$VIMPLUGINS/vim-readingvimrc
set runtimepath+=$VIMPLUGINS/vim-tabenhancer
set runtimepath+=$VIMRUNTIME

syntax on
filetype plugin indent on
set secure

set ambiwidth=double
set autoread
set clipboard=unnamed
set display=lastline
set equalalways
set expandtab softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set incsearch hlsearch
set keywordprg=:help
set laststatus=2 statusline&
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noignorecase
set nowrap list listchars=trail:.,tab:>-
set nowrapscan
set pumheight=10 completeopt=menu
set ruler
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shellslash
set shortmess& shortmess+=I
set tags=./tags;
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

" SWAP FILES
set noswapfile

" BACKUP FILES
silent! call mkdir(expand('$VIMTEMP/backupfiles'), 'p')
set backup
set nowritebackup
set backupdir=$VIMTEMP/backupfiles//

" UNDO FILES
if has('persistent_undo')
    silent! call mkdir(expand('$VIMTEMP/undofiles'), 'p')
    set undofile
    set undodir=$VIMTEMP/undofiles//
endif

if has('clpum')
    set wildmode=popup
    set clpumheight=10
endif

if has('vim_starting')
    let g:spring_night_kill_italic = 1
    colorscheme spring-night
endif

vnoremap <silent>p           "_dP

noremap <silent><C-u>        5k
noremap <silent><C-d>        5j

inoremap <silent><tab>       <C-v><tab>

nnoremap <nowait><C-j>       :<C-u>cnext<cr>
nnoremap <nowait><C-k>       :<C-u>cprevious<cr>

command! -bar -nargs=0 SessionLoad   :source     $VIMTEMP/session.vim
command! -bar -nargs=0 SessionSave   :mksession! $VIMTEMP/session.vim

if has('win32')
    command! -nargs=0 Explorer   :!start explorer .
    if has('gui_running')
        command! -bar -nargs=0 FullScreenToggle   :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)
        command!      -nargs=1 SetAlpha           :call libcallnr('vimtweak.dll', 'SetAlpha', <args>)
    endif
    " https://github.com/rprichard/winpty/releases/
    if has('terminal')
        tnoremap <silent><C-p>       <up>
        tnoremap <silent><C-n>       <down>
        tnoremap <silent><C-b>       <left>
        tnoremap <silent><C-f>       <right>
        tnoremap <silent><C-e>       <end>
        tnoremap <silent><C-a>       <home>
        tnoremap <silent><C-u>       <esc>
    endif
endif

augroup delmanpager
    autocmd!
    autocmd VimEnter * :delcommand MANPAGER
augroup END

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

nohlsearch
