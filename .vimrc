"
" ---------------------------------------------------------------------------------------------------
" How to setup if git is not installed
"   1. $curl https://raw.githubusercontent.com/rbtnn/vimrc/master/.vimrc        -o .vimrc
"   2. $curl https://raw.githubusercontent.com/rbtnn/vimrc/master/pkgsync.json  -o pkgsync.json
"
" How to install plugins
"   1. :PkgSyncSetup
"   2. :PkgSync update
" ---------------------------------------------------------------------------------------------------
"
scriptencoding utf-8
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/.vim')
let $VIMRC_PKGSYNC_DIR = expand('$VIMRC_VIM/github/pack/rbtnn/start/vim-pkgsync')

if &compatible
    set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

language messages C
set winaltkeys=yes
set guioptions=M
set mouse=a
set belloff=all
set clipboard=unnamed

set autoread
set cmdheight=3
set cmdwinheight=5
set complete-=t
set completeslash=slash
set expandtab shiftwidth=4 tabstop=4
set fileencodings=ucs-bom,utf-8,cp932
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set hlsearch
set incsearch
set isfname-==
set keywordprg=:help
set laststatus=2
set list listchars=tab:-->
set matchpairs+=<:>
set matchtime=1
set nobackup
set noignorecase
set nonumber norelativenumber nocursorline
set noruler rulerformat&
set noshowmode
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats&
set pumheight=10
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set showcmd
set showmatch
set showtabline=0 tabline&
set softtabstop=-1
set synmaxcol=300
set tags=./tags;
set termguicolors
set timeout timeoutlen=500 ttimeoutlen=100
set updatetime=500
set wildmenu

" https://github.com/vim/vim/commit/3908ef5017a6b4425727013588f72cc7343199b9
if has('patch-8.2.4325')
    set wildoptions=pum
endif

" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
if has('patch-8.2.0860')
    set nrformats-=octal
    set nrformats+=unsigned
endif

if has('persistent_undo')
    set undofile
    " https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
    if has('nvim')
        let &undodir = expand('$VIMRC_VIM/undofiles/neovim')
    else
        let &undodir = expand('$VIMRC_VIM/undofiles/vim')
    endif
    silent! call mkdir(&undodir, 'p')
else
    set noundofile
endif

let &cedit = "\<C-q>"

let g:vimrc = get(g:, 'vimrc', {
    \   'term_cmd': [&shell],
    \ })
let g:vim_indent_cont = &g:shiftwidth
let g:restart_sessionoptions = &sessionoptions
let g:molder_show_hidden = 1
let g:quickrun_config = {
    \   "_" : {
    \       "outputter": "error",
    \       "outputter/error/success": "buffer",
    \       "outputter/error/error": "quickfix",
    \   },
    \   "java" : {
    \       "hook/output_encode/encoding": has('win32') ? 'cp932' : &encoding,
    \   },
    \}

if has('win32') && executable('wmic') && has('gui_running')
    function! s:outcb(ch, mes) abort
        if 14393 < str2nr(trim(a:mes))
            let g:vimrc.term_cmd = ['cmd.exe', '/k', 'doskey pwd=cd && doskey ls=dir /b && set prompt=$E[32m$$$E[0m']
        endif
    endfunction
    call job_start('wmic os get BuildNumber', { 'out_cb': function('s:outcb'), })
endif

if has('tabsidebar')
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=2
    set tabsidebar=%{nr2char(0x20)}
    for s:name in ['TabSideBar', 'TabSideBarSel', 'TabSideBarFill']
        if !hlexists(s:name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', s:name)
        endif
    endfor
endif

function! s:pkgsync_setup() abort
    if !isdirectory($VIMRC_PKGSYNC_DIR)
        let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
        silent! call mkdir(path, 'p')
        call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
            \ 'cwd': path,
            \ })
        echo 'please restart Vim!'
    endif
endfunction

function! s:exists_font(fname) abort
    return filereadable(expand('$USERPROFILE/AppData/Local/Microsoft/Windows/Fonts/' .. a:fname))
        \ || filereadable(expand('C:/Windows/Fonts/' .. a:fname))
endfunction

function! s:close_terms() abort
    for x in filter(getwininfo(), {i,x -> x.tabnr == tabpagenr() && x.terminal })
        if term_getstatus(x.bufnr) == 'finished'
            call win_execute(x.winid, 'close')
        endif
    endfor
endfunction

function! s:npm_fmt() abort
    call s:close_terms()
    call term_start([has('win32') ? 'npm.cmd' : 'npm', 'run', 'fmt'], {})
endfunction

function! s:npm_jest() abort
    call s:close_terms()
    call term_start([has('win32') ? 'npm.cmd' : 'npm', 'run', 'jest'], {})
endfunction

function! s:remove_ansi_escape_codes(line) abort
    return substitute(a:line, nr2char(27) .. '[\d\+m', '', 'g')
endfunction

function! s:npm_build_out_cb(ch, msg) abort
    let m = matchlist(s:remove_ansi_escape_codes(a:msg), '\[tsl\] ERROR in \(.\+\)(\(\d\+\),\(\d\+\))$')
    if !empty(m)
        call setqflist([{
            \   'filename': m[1],
            \   'lnum': str2nr(m[2]),
            \   'col': str2nr(m[3]),
            \   'text': s:remove_ansi_escape_codes(a:msg),
            \ }], 'a')
    else
        call setqflist([{
            \   'text': s:remove_ansi_escape_codes(a:msg),
            \ }], 'a')
    endif
endfunction

function! s:npm_build_exit_cb(cmd, ch, status) abort
    echohl Title
    echo printf('%s "%s"!', (a:status == 0 ? 'Succeeded' : 'Failed'), a:cmd)
    echohl None
endfunction

let s:npm_build_job = v:null

function! s:npm_build() abort
    const cmd = 'npm run build'
    call setqflist([])
    if s:npm_build_job != v:null
        call job_stop(s:npm_build_job, 'kill')
        let s:npm_build_job = v:null
    endif
    echohl Title
    echo printf('Start "%s"!', cmd)
    echohl None
    let s:npm_build_job = job_start([has('win32') ? 'npm.cmd' : 'npm', 'run', 'build'], {
        \ 'out_io': 'pipe',
        \ 'err_io': 'out',
        \ 'out_cb': function('s:npm_build_out_cb'),
        \ 'exit_cb': function('s:npm_build_exit_cb', [cmd]),
        \ })
endfunction

function! s:vimrc_init() abort
    if !&modified && filereadable(expand('%'))
        silent! checktime
    endif

    " Can't use <S-space> at :terminal
    " https://github.com/vim/vim/issues/6040
    tnoremap <silent><S-space>           <space>

    " Smart space on wildmenu
    cnoremap <expr><space>             (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

    " Emacs key mappings
    if has('win32') && (&shell =~# '\<cmd\.exe$')
        tnoremap <silent><C-p>           <up>
        tnoremap <silent><C-n>           <down>
        tnoremap <silent><C-b>           <left>
        tnoremap <silent><C-f>           <right>
        tnoremap <silent><C-e>           <end>
        tnoremap <silent><C-a>           <home>
        tnoremap <silent><C-u>           <esc>
        tnoremap <silent><C-cr>          <cr>
    endif

    cnoremap         <C-b>    <left>
    cnoremap         <C-f>    <right>
    cnoremap         <C-e>    <end>
    cnoremap         <C-a>    <home>

    nnoremap <silent><C-j>    <Cmd>tabnext<cr>
    nnoremap <silent><C-k>    <Cmd>tabprevious<cr>
    tnoremap <silent><C-j>    <Cmd>tabnext<cr>
    tnoremap <silent><C-k>    <Cmd>tabprevious<cr>

    nnoremap <silent><C-p>    <Cmd>cprevious<cr>zz
    nnoremap <silent><C-n>    <Cmd>cnext<cr>zz

    let g:mapleader = "s"

    nnoremap     <leader>         <nop>
    nnoremap     <leader><leader> <nop>
    " https://github.com/rbtnn/vimrc/tree/adf7bb43a14aee4fa90eac8e8f14a77aa8455501/vim/local/pack/dev/start/vim-git/autoload/git
    nnoremap     <leader>d        <Cmd>GitDiff<cr>
    nnoremap     <leader>f        <Cmd>call <SID>npm_fmt()<cr>
    nnoremap     <leader>b        <Cmd>call <SID>npm_build()<cr>
    nnoremap     <leader>j        <Cmd>call <SID>npm_jest()<cr>
    nnoremap     <leader>e        <Cmd>if filereadable(expand('%')) \| e %:h \| else \| e . \| endif<cr>
    nnoremap     <leader>z        <Cmd>call term_start(g:vimrc.term_cmd, {
        \   'term_highlight' : 'Terminal',
        \   'term_finish' : 'close',
        \   'term_kill' : 'kill',
        \ })<cr>

    if get(g:, 'loaded_operator_replace', v:false)
        nmap     <silent>x        <Plug>(operator-replace)
    endif
    if get(g:, 'loaded_operator_flashy', v:false)
        map      <silent>y        <Plug>(operator-flashy)
        nmap     <silent>Y        <Plug>(operator-flashy)$
    endif
    if get(g:, 'loaded_textobj_string', v:false)
        nmap     <silent>ds       das
        nmap     <silent>ys       yas
        nmap     <silent>vs       vas
    endif
    if get(g:, 'loaded_molder', v:false)
        if &filetype == 'molder'
            nnoremap <buffer> h  <plug>(molder-up)
            nnoremap <buffer> l  <plug>(molder-open)
            nnoremap <buffer> C  <Cmd>call chdir(b:molder_dir) \| verbose pwd<cr>
            nnoremap <buffer> E  <Cmd>call term_start(['explorer', '.'], {
                \   'term_highlight' : 'Terminal',
                \   'term_finish' : 'close',
                \   'term_kill' : 'kill',
                \   'hidden' : v:true,
                \   'cwd' : b:molder_dir,
                \ })<cr>
            nnoremap <buffer> !  <Cmd>call term_start(['cmd.exe', '/K', printf('start %s', getline('.'))], {
                \   'term_highlight' : 'Terminal',
                \   'term_finish' : 'close',
                \   'term_kill' : 'kill',
                \   'hidden' : v:true,
                \   'cwd' : b:molder_dir,
                \ })<cr>
        endif
    endif
    if has('win32')
        command! -nargs=0 WinExplorer        :!start .
        command! -nargs=0 WinMaximize        :simalt~x
    endif
    if !exists(':PkgSync')
        command! -nargs=0 PkgSyncSetup :call s:pkgsync_setup()
    endif
endfunction

function! s:vimrc_colorscheme() abort
    highlight! link TabSideBarFill StatusLine
    highlight! link TabSideBar     TabSideBarFill
    highlight! link TabSideBarSel  TabSideBarFill
    highlight! Cursor              guifg=#000000 guibg=#d7d7d7
    highlight! CursorIM            guifg=NONE    guibg=#d70000
    highlight! SpecialKey          guifg=#444411
    highlight! DiffAdd             guifg=#000000    guibg=#53ff60
    highlight! DiffDelete          guifg=#000000    guibg=#ff5560
    highlight! DiffText            guifg=#000000    guibg=#aa33aa
    " itchyny/vim-parenmatch
    if get(g:, 'loaded_parenmatch', v:false)
        let g:parenmatch_highlight = 0
        highlight! link  ParenMatch  MatchParen
    endif
    " itchyny/lightline.vim
    if get(g:, 'loaded_lightline', v:false)
        let g:lightline = { 'colorscheme': 'aylin' }
        call lightline#enable()
    endif
endfunction

if has('vim_starting')
    set packpath=$VIMRC_VIM/github
    set runtimepath=$VIMRUNTIME

    if has('win32') && has('gui_running') && has('vim_starting')
        set linespace=0
        if s:exists_font('Cica-Regular.ttf')
            " https://github.com/miiton/Cica
            set guifont=Cica:h16:cSHIFTJIS:qDRAFT
        elseif s:exists_font('UDEVGothic-Regular.ttf')
            " https://github.com/yuru7/udev-gothic
            set guifont=UDEV_Gothic:h16:cSHIFTJIS:qDRAFT
        else
            set guifont=ＭＳ_ゴシック:h18:cSHIFTJIS:qDRAFT
        endif
    endif

    silent! source ~/.vimrc.local

    filetype plugin indent on
    syntax enable
    packloadall
endif

augroup vimrc
    autocmd!
    autocmd CmdlineEnter *
        \ : if getcmdtype() == ':'
        \ |     set ignorecase
        \ |     call map(['MANPAGER']
        \           + getcompletion('Textobj*','command')
        \           + getcompletion('VimTweakD*','command')
        \           + getcompletion('VimTweakE*','command')
        \           + getcompletion('Strip*','command')
        \           + getcompletion('*Whitespace','command')
        \           + getcompletion('Toggle*','command')
        \           , { i,x -> execute('silent! delcommand ' .. x) })
        \ | endif
    autocmd CmdlineLeave      *    : set noignorecase
    autocmd VimEnter,BufEnter *    : call s:vimrc_init()
    autocmd FileType          help : setlocal colorcolumn=78
    autocmd ColorScheme       *    : call s:vimrc_colorscheme()
    autocmd BufEnter *.css         : setlocal expandtab shiftwidth=2 tabstop=2
    autocmd BufEnter *.scss        : setlocal expandtab shiftwidth=2 tabstop=2
    autocmd BufEnter *.ts,*.js     : setlocal expandtab shiftwidth=2 tabstop=2
    autocmd BufEnter *.tsx,*.jsx   : setlocal expandtab shiftwidth=2 tabstop=2
augroup END

call s:vimrc_init()

try
    colorscheme aylin
catch
    colorscheme default
endtry
