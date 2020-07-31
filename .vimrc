try
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
    set noshellslash
    set noshowmode
    set noswapfile
    set nowrapscan
    set pumheight=10 completeopt=menu
    set ruler rulerformat&
    set scrolloff=0 nonumber norelativenumber
    set sessionoptions=buffers,curdir,tabpages,help
    set shortmess& shortmess-=S
    set showtabline=0 tabline&
    set tags=./tags;
    set title titlestring=%{v:progname}[%{getpid()}]
    set visualbell noerrorbells t_vb=
    set wildmenu wildmode&

    set nrformats=
    if has('patch-8.2.0860')
        set nrformats+=unsigned
    endif

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

    tnoremap <silent><nowait>gT     <C-w>gT
    tnoremap <silent><nowait>gt     <C-w>gt

    if has('win32')
        " https://github.com/rprichard/winpty/releases/
        tnoremap <silent><C-p>       <up>
        tnoremap <silent><C-n>       <down>
        tnoremap <silent><C-b>       <left>
        tnoremap <silent><C-f>       <right>
        tnoremap <silent><C-e>       <end>
        tnoremap <silent><C-a>       <home>
        tnoremap <silent><C-u>       <esc>
    endif

    set packpath=
    set runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM

    call plug#begin($VIMRC_PLUGDIR)

    silent! source $VIMRC_PLUGDIR/vim-gloaded/plugin/gloaded.vim
    silent! source $VIMRC_ROOT/vim-on-windows/vimbatchfiles/setup.vim
    silent! source ~/.vimrc.local

    " ------------------
    " Textobj/Operator
    " ------------------
    Plug 'kana/vim-operator-replace'
    Plug 'kana/vim-operator-user'
    Plug 'kana/vim-textobj-user'
    Plug 'rbtnn/vim-textobj-verbatimstring'

    " ------------------
    " ColorScheme
    " ------------------
    Plug 'rbtnn/vim-darkcrystal'

    " ------------------
    " Others
    " ------------------
    Plug 'lambdalisue/nerdfont-palette.vim'
    Plug 'lambdalisue/nerdfont.vim'
    Plug 'rbtnn/vim-close_scratch'
    Plug 'rbtnn/vim-gloaded'
    Plug 'rbtnn/vim-jumptoline'
    Plug 'rbtnn/vim-vimscript_lasterror'
    Plug 'rbtnn/vim-vimscript_tagfunc'
    Plug 'rbtnn/vim-wizard'
    Plug 'thinca/vim-qfreplace'
    Plug 'tyru/restart.vim'

    call plug#end()

    if !has('nvim')
        nnoremap <silent><nowait><space>     :<C-u>Wizard<cr>
    endif
    nnoremap <silent><nowait><C-n>       :<C-u>cnext<cr>
    nnoremap <silent><nowait><C-p>       :<C-u>cprevious<cr>
    nmap     <silent><nowait>s           <Plug>(operator-replace)

    let g:restart_sessionoptions = 'winpos,winsize,resize,' .. &sessionoptions
    let g:close_scratch_define_augroup = 1

    silent! colorscheme darkcrystal

    augroup vimrc
        autocmd!
        for s:cmdname in [ 'MANPAGER', 'VimFoldh', 'TextobjVerbatimstringDefaultKeyMappings', ]
            execute printf('autocmd CmdlineEnter * :silent! delcommand %s', s:cmdname)
        endfor
    augroup END

    if !has('nvim') && has('win32')
        " This is the same as stdpath('config') in nvim.
        let initdir = expand('~/AppData/Local/nvim')
        call mkdir(initdir, 'p')
        call writefile(['silent! source ~/.vimrc'], initdir .. '/init.vim')
    endif

    syntax on
    filetype plugin indent on
    set secure
catch
    echoerr v:exception
endtry
