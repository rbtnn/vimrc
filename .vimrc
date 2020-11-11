set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM

let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_PLUGDIR = expand('$VIMRC_ROOT/.vim/plugged')

set ambiwidth=double
set autoread
set clipboard=unnamed
set cmdheight=3
set display=lastline
set expandtab shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set grepprg=internal
set ignorecase nosmartcase
set keywordprg=:help
set laststatus=2 statusline&
set list nowrap breakindent& showbreak& listchars=tab:\ \ \|,trail:-
set matchpairs+=<:>
set mouse=a
set nobackup nowritebackup backupdir&
set nocursorline nocursorcolumn
set nofoldenable foldcolumn& foldlevelstart& foldmethod=indent
set noruler rulerformat&
set noshellslash
set noshowmode
set noswapfile
set nowrapscan
set nrformats=unsigned
set pumheight=10 completeopt=menu
set scrolloff=0 nonumber norelativenumber
set sessionoptions=
set shortmess& shortmess-=S
set showtabline=0 tabline&
set tags=./tags;
set title titlestring=[%{getpid()}]\ %{vimrc#label#string()}
set visualbell noerrorbells t_vb=
set wildmenu wildmode&

set wildignore=*.pdb,*.obj,*.dll,*.exe,*.idb,*.ncb,*.ilk,*.plg,*.bsc,*.sbr,*.opt,*.config
set wildignore+=*.pdf,*.mp3,*.doc,*.docx,*.xls,*.xlsx,*.idx,*.jpg,*.png,*.zip,*.MMF,*.gif
set wildignore+=*.resX,*.lib,*.resources,*.ico,*.suo,*.cache,*.user,*.myapp,*.dat,*.dat01
set wildignore+=*.vbe

setglobal incsearch hlsearch

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = '\'

if has('persistent_undo')
    silent! call mkdir(expand('$VIMRC_DOTVIM/undofiles'), 'p')
    set undofile undodir=$VIMRC_DOTVIM/undofiles//
endif

if has('win32')
    if !has('nvim')
        " This is the same as stdpath('config') in nvim.
        let initdir = expand('~/AppData/Local/nvim')
        call mkdir(initdir, 'p')
        call writefile(['silent! source ~/.vimrc'], initdir .. '/init.vim')
    endif
    " https://github.com/rprichard/winpty/releases/
    tnoremap <silent><nowait><C-p>       <up>
    tnoremap <silent><nowait><C-n>       <down>
    tnoremap <silent><nowait><C-b>       <left>
    tnoremap <silent><nowait><C-f>       <right>
    tnoremap <silent><nowait><C-e>       <end>
    tnoremap <silent><nowait><C-a>       <home>
    tnoremap <silent><nowait><C-u>       <esc>
endif

set packpath=
set runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM

silent! source $VIMRC_PLUGDIR/vim-gloaded/plugin/gloaded.vim
silent! source $VIMRC_ROOT/vim-on-windows/vimbatchfiles/setup.vim

let g:pterm_options = { 'border' : [], 'borderhighlight' : ['Label'], }
let g:pterm_using_title_for_tabs = v:true
let g:pterm_width = '&columns * 4 / 5'
let g:restart_sessionoptions = 'winpos,winsize,resize,buffers,curdir,tabpages'
let g:molder_show_hidden = 1

silent! source ~/.vimrc.local

let g:plug_url_format = 'https://github.com/%s.git'
silent! call plug#begin($VIMRC_PLUGDIR)
call plug#('kana/vim-operator-replace')
call plug#('kana/vim-operator-user')
call plug#('mattn/vim-molder')
call plug#('rbtnn/vim-darkcrystal')
call plug#('rbtnn/vim-gloaded')
call plug#('rbtnn/vim-jumptoline')
call plug#('rbtnn/vim-pterm')
call plug#('rbtnn/vim-vimscript_indentexpr')
call plug#('rbtnn/vim-vimscript_lasterror')
call plug#('rbtnn/vim-vimscript_tagfunc')
call plug#('thinca/vim-qfreplace')
call plug#('tyru/restart.vim')
call plug#end()

nnoremap <silent><nowait><C-f>       :<C-u>call vimrc#git#diff(6, '-w')<cr>
nnoremap <silent><nowait><C-s>       :<C-u>call vimrc#git#lsfiles(19)<cr>
nnoremap <silent><nowait><C-j>       :<C-u>JumpToLine!<cr>
nnoremap <silent><nowait><C-n>       :<C-u>cnext<cr>
nnoremap <silent><nowait><C-p>       :<C-u>cprevious<cr>
nmap     <silent><nowait>s           <Plug>(operator-replace)

set background=dark
silent! colorscheme darkcrystal

augroup vimrc
    autocmd!
    autocmd FileType cpp  :setlocal noexpandtab
    autocmd FileType help :command! -buffer -bar -nargs=0 HelpStartEditting
        \ :setlocal colorcolumn=+1 conceallevel=0 list setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
    for s:cmdname in [
            \ 'MANPAGER', 'VimFoldh', 'TextobjVerbatimstringDefaultKeyMappings',
            \ 'PlugSnapshot', 'PlugDiff', 'PlugStatus', 'PlugInstall', 'Plug', 'PlugUpgrade']
        execute printf('autocmd CmdlineEnter * :silent! delcommand %s', s:cmdname)
    endfor
augroup END

syntax on
filetype plugin indent on
set secure
