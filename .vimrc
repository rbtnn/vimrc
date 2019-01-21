
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
set runtimepath+=$VIMPLUGINS/gruvbox
set runtimepath+=$VIMPLUGINS/vim-diffy
set runtimepath+=$VIMPLUGINS/vim-gloaded
set runtimepath+=$VIMPLUGINS/vim-qfreplace
set runtimepath+=$VIMPLUGINS/vim-readingvimrc
set runtimepath+=$VIMPLUGINS/vim-runtest
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
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shellslash
set shortmess& shortmess+=I
set tags=./tags;
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

" BALLOON
if 0
    function! MyBalloonExpr() abort
        return printf('Cursor is at line %d, column %d on word "%s"', v:beval_lnum, v:beval_col, v:beval_text)
    endfunction
    set ballooneval balloondelay& balloonexpr=MyBalloonExpr()
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

if has('timers')
    set showtabline=2
    set tabline=%!TabLine()
    function! TabLine() abort
        try
            let weeks = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][strftime('%w')]
            let date = strftime('%Y/%m/%d')
            let time = strftime('%H:%M:%S')
            let s = printf('--- %s(%s) %s ---', date, weeks, time)
            let tsbcolumns = 0
            if has('tabsidebar')
                if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
                    let tsbcolumns = &tabsidebarcolumns
                endif
            endif
            let padding = repeat(' ', (&columns - len(s)) / 2 - tsbcolumns)
            return printf('%s%%#TabLineSel#%s', padding, s)
        catch
            return string(v:exception)
        endtry
    endfunction
    function! TabLineHandler(timer) abort
        " Not redraw during prompting.
        if mode() !~# 'r'
            redrawtabline
        endif
    endfunction
    if !exists('s:timer_tabline')
        let s:timer_tabline = timer_start(1000, 'TabLineHandler', { 'repeat' : -1, })
    endif
endif

if has('tabsidebar')
    set showtabsidebar=2
    set tabsidebarcolumns=20
    set tabsidebarwrap
    set tabsidebar=%!TabSideBar()
    function! TabSideBar() abort
        try
            if g:actual_curtabpage == tabpagenr()
                let t = 'TabSideBarSel'
            else
                let t = 'TabSideBar'
            endif
            let lines = ['']
            let s = printf('TABPAGE %d', g:actual_curtabpage)
            let rest = &tabsidebarcolumns - len(s) - 2
            let lines += [printf('%%#%s#%s|%s|%s', t,
                    \ repeat('=', rest / 2),
                    \ s,
                    \ repeat('=', rest / 2 + (rest % 2)))]
            for x in getwininfo()
                if x.tabnr == g:actual_curtabpage
                    let s = '(No Name)'
                    if x.terminal
                        let s = '(Terminal)'
                    elseif x.quickfix
                        let s = '(QuickFix)'
                    elseif x.loclist
                        let s = '(LocList)'
                    elseif filereadable(bufname(x.bufnr))
                        let modi = getbufvar(x.bufnr, '&modified')
                        let read = getbufvar(x.bufnr, '&readonly')
                        let name = fnamemodify(bufname(x.bufnr), ':t')
                        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
                    else
                        let ft = getbufvar(x.bufnr, '&filetype')
                        if !empty(ft)
                            let s = printf('[%s]', ft)
                        endif
                    endif
                    let iscurr = (winnr() == x.winnr) && (g:actual_curtabpage == tabpagenr())
                    let lines += [printf('%s %s', (iscurr ? '>' : ' '), s)]
                endif
            endfor
            return join(lines, "\n")
        catch
            return string(v:exception)
        endtry
    endfunction
endif

if has('vim_starting')
    if 0 <= index(getcompletion('*', 'color'), 'gruvbox')
        let g:gruvbox_italic = 0
        set background=dark
        colorscheme gruvbox
    endif
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
        if isdirectory(expand('~/Desktop/vim/src')) && isdirectory(expand('~/vimbatchfiles'))
            command! -bar -nargs=0 VimOpen         :execute printf('!start %s', expand('~/Desktop/vim/src/gvim.exe'))
            command! -bar -nargs=* VimBuild        :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-4-build-gvim.bat'), <q-args>)
            command! -bar -nargs=* VimBuildTerm    :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-5-build-vim.bat'), <q-args>)
            command! -bar -nargs=* VimTest         :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-7-test.bat'), <q-args>)
        endif
        tnoremap <silent><C-p>       <up>
        tnoremap <silent><C-n>       <down>
        tnoremap <silent><C-b>       <left>
        tnoremap <silent><C-f>       <right>
        tnoremap <silent><C-e>       <end>
        tnoremap <silent><C-a>       <home>
        tnoremap <silent><C-u>       <esc>
    endif
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
    "if has('vim_starting')
    "    set guifont=Consolas:h14:cANSI:qDRAFT
    "    set guifontwide=MS_Gothic:h14:cSHIFTJIS:qDRAFT
    "endif
endif

nohlsearch
