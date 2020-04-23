
set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM

" for less.exe on windows
let $LESSCHARSET = 'utf-8'

let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')

set ambiwidth=double
set autoread
set background=dark
set clipboard=unnamed
set cursorline nocursorcolumn
set display=lastline
set expandtab shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set grepprg=internal
set keywordprg=:help
set laststatus=2 statusline&
set list nowrap breakindent& showbreak& listchars=tab:\ \ \|,trail:-
set matchpairs+=<:>
set mouse=a
set nofoldenable foldcolumn& foldlevelstart& foldmethod&
set noignorecase nosmartcase
set noshellslash
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

if exists('+completeslash')
    set completeslash=slash
endif

set wildignore=*.pdb,*.obj,*.dll,*.exe,*.idb,*.ncb,*.ilk,*.plg,*.bsc,*.sbr,*.opt,*.config
set wildignore+=*.pdf,*.mp3,*.doc,*.docx,*.xls,*.xlsx,*.idx,*.jpg,*.png,*.zip,*.MMF,*.gif
set wildignore+=*.resX,*.lib,*.resources,*.ico,*.suo,*.cache,*.user,*.myapp,*.dat,*.dat01
set wildignore+=*.vbe

setglobal incsearch hlsearch

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = '\'

source $VIMRC_DOTVIM/tabsidebar.vim
source $VIMRC_DOTVIM/rust.vim
source $VIMRC_DOTVIM/vb.vim

" swap and backup files
silent! call mkdir(expand('$VIMRC_DOTVIM/backupfiles'), 'p')
set noswapfile backup nowritebackup backupdir=$VIMRC_DOTVIM/backupfiles//

" undo files
if has('persistent_undo')
    silent! call mkdir(expand('$VIMRC_DOTVIM/undofiles'), 'p')
    set undofile undodir=$VIMRC_DOTVIM/undofiles//
endif

command! -bar -nargs=0 SessionSave       :mksession! $VIMRC_DOTVIM/session.vim
command! -bar -nargs=0 SessionLoad       :source $VIMRC_DOTVIM/session.vim

command! -bar -nargs=0 TermKillAll       :call map(term_list(), { i,x -> job_stop(term_getjob(x)) })

command! -bar -nargs=0 AllWindowsTheSame
    \ : call map(range(1, winnr('$')), { i,x -> setwinvar(x, '&winfixheight', 0) && setwinvar(x, '&winfixwidth', 0) })
    \ | set equalalways
    \ | wincmd =

if has('win32')
    function! s:start(progpath, args) abort
        silent! execute printf('!start %s %s', a:progpath, a:args)
    endfunction
    command! -complete=file -nargs=* WinExplorer  :call <SID>start('explorer', (empty(<q-args>) ? '.' : <q-args>))
    command! -complete=file -nargs=* NewVim       :call <SID>start(v:progpath, <q-args>)

    " https://github.com/rprichard/winpty/releases/
    tnoremap <silent><C-p>       <up>
    tnoremap <silent><C-n>       <down>
    tnoremap <silent><C-b>       <left>
    tnoremap <silent><C-f>       <right>
    tnoremap <silent><C-e>       <end>
    tnoremap <silent><C-a>       <home>
    tnoremap <silent><C-u>       <esc>
endif

set runtimepath+=$VIMRC_DOTVIM
runtime! plugin/gloaded.vim

set packpath=$VIMRUNTIME,$VIMRC_DOTVIM
silent! packadd minpac

if exists('*minpac#init')
    call minpac#init({ 'dir' : $VIMRC_DOTVIM })
    call minpac#add('bluz71/vim-nightfly-guicolors')
    call minpac#add('haya14busa/vim-asterisk')
    call minpac#add('k-takata/minpac', { 'type' : 'opt', 'branch' : 'devel' })
    call minpac#add('kana/vim-operator-replace')
    call minpac#add('kana/vim-operator-user')
    call minpac#add('rbtnn/vim-coloredit')
    call minpac#add('rbtnn/vim-diffy')
    call minpac#add('rbtnn/vim-jumptoline')
    call minpac#add('rbtnn/vim-mrw')
    call minpac#add('rbtnn/vim-vimscript_formatter')
    call minpac#add('rbtnn/vim-vimscript_lasterror')
    call minpac#add('rbtnn/vim-vimscript_tagfunc')
    call minpac#add('thinca/vim-qfreplace')
    call minpac#add('tyru/restart.vim')
    command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
    command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
    nnoremap <silent><nowait><space>   :<C-u>JumpToLine<cr>
    nnoremap <silent><nowait><C-j>     :<C-u>MRW<cr>
    nnoremap <silent><nowait><C-f>     :<C-u>Diffy<cr>
    nnoremap <silent><nowait><C-n>     :<C-u>cnext<cr>zz
    nnoremap <silent><nowait><C-p>     :<C-u>cprevious<cr>zz
    map      <silent><nowait>*         <Plug>(asterisk-z*)
    map      <silent><nowait>g*        <Plug>(asterisk-gz*)
    nmap     <silent><nowait>s         <Plug>(operator-replace)
    let g:diffy_default_args_git = '-w'
    let g:diffy_default_args_svn = '-x -w'
    let g:restart_sessionoptions = 'winpos,resize'
    let g:nightflyItalics = 0
endif

augroup vimrc
    autocmd!
    for s:cmdname in [ 'MANPAGER', 'VimFoldh', ]
        execute printf('autocmd CmdlineEnter * :silent! delcommand %s', s:cmdname)
    endfor
    autocmd VimEnter,WinEnter *    :AllWindowsTheSame
    autocmd TerminalWinOpen   *    :nnoremap <buffer><nowait>q   :<C-u>quit!<cr>
    autocmd FileType          help :nnoremap <buffer><nowait>q   :<C-u>quit!<cr>
    autocmd ColorScheme       *    :highlight SpecialKey guifg=#032645
    autocmd ColorScheme       *    :highlight Comment    guifg=#053867
augroup END

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

syntax on
filetype plugin indent on
set secure

silent! colorscheme nightfly

