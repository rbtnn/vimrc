try
    set encoding=utf-8
    set makeencoding=char
    scriptencoding utf-8

    set langmenu=en_gb.latin1
    set winaltkeys=yes guioptions=mM

    let $VIMRC_ROOT = expand('<sfile>:h')
    let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')

    set ambiwidth=double
    set autoread
    set clipboard=unnamed
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
    set nobackup nowritebackup backupdir&
    set nocursorline nocursorcolumn
    set nofoldenable foldcolumn& foldlevelstart& foldmethod=indent
    set noignorecase nosmartcase
    set noshellslash
    set noshowmode
    set nowrapscan
    set nrformats=unsigned
    set pumheight=10 completeopt=menu
    set ruler rulerformat&
    set scrolloff=0 nonumber norelativenumber
    set sessionoptions=buffers,curdir,tabpages
    set shortmess& shortmess-=S
    set showtabline=0 tabline&
    set swapfile
    set tags=./tags;
    set title titlestring=%{v:progname}[%{getpid()}]
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
    silent! source $VIMRC_DOTVIM/pack/minpac/start/vim-gloaded/plugin/gloaded.vim

    set packpath=$VIMRUNTIME,$VIMRC_DOTVIM
    silent! packadd minpac

    if exists('*minpac#init')
        call minpac#init({ 'dir' : $VIMRC_DOTVIM })

        call minpac#add('haya14busa/vim-asterisk')
        call minpac#add('itchyny/vim-parenmatch')
        call minpac#add('k-takata/minpac', { 'type' : 'opt', 'branch' : 'devel' })
        call minpac#add('kana/vim-operator-replace')
        call minpac#add('kana/vim-operator-user')
        call minpac#add('kana/vim-textobj-user')
        call minpac#add('rbtnn/vim-diffy')
        call minpac#add('rbtnn/vim-gloaded')
        call minpac#add('rbtnn/vim-jumptoline')
        call minpac#add('rbtnn/vim-tabsidebar')
        call minpac#add('rbtnn/vim-textobj-verbatimstring')
        call minpac#add('rbtnn/vim-vb')
        call minpac#add('rbtnn/vim-vimbuild')
        call minpac#add('thinca/vim-qfreplace')
        call minpac#add('tyru/restart.vim')

        nnoremap <silent><nowait><space>   :<C-u>JumpToLine<cr>
        nnoremap <silent><nowait><C-n>     :<C-u>cnext<cr>zz
        nnoremap <silent><nowait><C-p>     :<C-u>cprevious<cr>zz
        map      <silent><nowait>*         <Plug>(asterisk-z*)
        map      <silent><nowait>g*        <Plug>(asterisk-gz*)
        nmap     <silent><nowait>s         <Plug>(operator-replace)

        tnoremap <silent><nowait>gT     <C-w>gT
        tnoremap <silent><nowait>gt     <C-w>gt

        let g:restart_sessionoptions = 'winpos,resize'
    endif

    augroup vimrc
        autocmd!
        for s:cmdname in [ 'MANPAGER', 'VimFoldh', ]
            execute printf('autocmd CmdlineEnter * :silent! delcommand %s', s:cmdname)
        endfor
        autocmd TerminalWinOpen   *       :nnoremap <buffer><nowait>q      :<C-u>quit!<cr>
        autocmd FileType          help,qf :nnoremap <buffer><nowait>q      :<C-u>quit!<cr>
    augroup END

    if filereadable(expand('~/.vimrc.local'))
        source ~/.vimrc.local
    endif

    if get(g:, 'vimrc_extra', v:true)
        command! -bar -nargs=0     HelpStartEditting    :setlocal colorcolumn=+1 conceallevel=0 list
            \  |setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
        command! -bar -nargs=0     SessionSave   :mksession! $VIMRC_DOTVIM/session.vim
        command! -bar -nargs=0     SessionLoad   :source $VIMRC_DOTVIM/session.vim
        command! -bar -nargs=0     TermKillAll   :call map(term_list(), { i,x -> job_stop(term_getjob(x)) })
    endif

    syntax on
    filetype plugin indent on
    set secure

    if has_key(minpac#getpluglist(), 'vim-tabsidebar')
        silent! colorscheme tabsidebar
    endif
catch
    echomsg v:throwpoint
    echomsg v:exception
endtry
