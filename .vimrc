
set encoding=utf-8
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
for s:path in split(globpath($VIMPLUGINS, '*'), "\n")
    if isdirectory(s:path)
        execute ('set runtimepath+=' . s:path)
        let s:docpath = printf('%s/doc', s:path)
        if isdirectory(s:docpath)
            silent! execute ('helptags ' . s:docpath)
        endif
    endif
endfor
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
set grepprg=git\ grep\ -I\ -n\ --no-color
set incsearch hlsearch
set keywordprg=:help
set laststatus=2 statusline&
set list listchars=trail:.,tab:>-
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noignorecase
set nowrap
set nowrapscan
set pumheight=10 completeopt=menu
set ruler
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shellslash
set shortmess& shortmess+=I
set tags=./tags;
set termwintype=winpty
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

set path=.,~,$VIMPLUGINS/**
if isdirectory(expand('~/Desktop/vim/src'))
    set path+=~/Desktop/vim/src
endif

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
    augroup override-colorscheme
        autocmd!
        autocmd ColorScheme *    :highlight TabLine     ctermfg=245 ctermbg=24 guifg=#8a8a8a guibg=#005f87
        autocmd ColorScheme *    :highlight TabLineSel  ctermfg=255 ctermbg=31 guifg=#eeeeee guibg=#0087af
        autocmd ColorScheme *    :highlight TabLineFill ctermfg=255 ctermbg=24 guifg=#eeeeee guibg=#005f87
    augroup END
    set background=light
    colorscheme PaperColor
endif

vnoremap <silent>p           "_dP

noremap  <silent><C-u>       5k
noremap  <silent><C-d>       5j

inoremap <silent><tab>       <C-v><tab>

function s:run_vimscript_on_srcvim() abort
    let vim = 'vim'
    let src = expand('%')
    if filereadable(expand('~/Desktop/vim/src/vim'))
        let vim = expand('~/Desktop/vim/src/vim')
    endif
    if executable(vim) && filereadable(src)
        let cmd = [ vim, '-X', '-N', '-u', 'NONE', '-i', 'NONE', '-V1', '-e', '-s', '-S', src, '+qall!', ]
        call jobrunner#new(cmd, getcwd(), function('jobrunner#new_window'))
    endif
endfunction

augroup run-vimscript
    autocmd!
    autocmd FileType vim    :nnoremap <buffer><nowait><space>       :<C-u>call <SID>run_vimscript_on_srcvim()<cr>
augroup END

nnoremap <nowait><C-j>         :<C-u>cnext<cr>zz
nnoremap <nowait><C-k>         :<C-u>cprevious<cr>zz

if has('win32')
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

augroup delete-commands
    autocmd!
    autocmd VimEnter *    :silent! delcommand MANPAGER
    autocmd VimEnter *    :silent! delcommand PaperColor
augroup END

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

nohlsearch
