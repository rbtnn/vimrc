
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
set runtimepath+=$VIMPLUGINS/vim-gloaded
set runtimepath+=$VIMPLUGINS/vim-various
set runtimepath+=$VIMPLUGINS/iceberg.vim
set runtimepath+=$VIMPLUGINS/vim-qfreplace
set runtimepath+=$VIMRUNTIME

syntax on
filetype plugin indent on
set secure

set ambiwidth=double
set autoread
set clipboard=unnamed
set cursorline nocursorcolumn
set display=lastline
set equalalways
set expandtab softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set ignorecase
set incsearch hlsearch
set keywordprg=:help
set matchpairs+=<:>
set noshellslash
set nowrap list listchars=trail:.,tab:>-
set nowrapscan
set pumheight=10 completeopt=menu
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shortmess& shortmess+=I
set tags=./tags;
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

" BALLOON
function! MyBalloonExpr() abort
	return printf('Cursor is at line %d, column %d on word "%s"', v:beval_lnum, v:beval_col, v:beval_text)
endfunction
set ballooneval balloondelay& balloonexpr=MyBalloonExpr()

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

if has('tabsidebar')
    set laststatus=2
    set statusline=%#TabLineFill#
    set showtabline=2
    set tabline=%#TabLine#%{getcwd()}%#TabLineFill#
    set showtabsidebar=2
    set tabsidebarcolumns=20
    set tabsidebarwrap
    set tabsidebar=%!TabSideBar()
    function! TabSideBar() abort
        try
            if g:actual_curtabpage == tabpagenr()
                let t = 'TabSideBarSel'
            elseif g:actual_curtabpage % 2 == 0
                let t = 'TabSideBarEven'
            else
                let t = 'TabSideBarOdd'
            endif
            let lines = [printf('%%#%s#Tab page %d', t, g:actual_curtabpage)]
            for x in getwininfo()
                if x.tabnr == g:actual_curtabpage
                    let s = '[No Name]'
                    if x.terminal
                        let s = '[Terminal]'
                    elseif x.quickfix
                        let s = '[QuickFix]'
                    elseif x.loclist
                        let s = '[LocList]'
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

augroup iceberg-additional
    autocmd!
    autocmd ColorScheme * :highlight! VertSplit          guifg=#818596 guibg=#818596
    autocmd ColorScheme * :highlight! StatusLine         guifg=NONE    guibg=#818596
    autocmd ColorScheme * :highlight! StatusLineNC       guifg=#818596 guibg=#818596
    autocmd ColorScheme * :highlight! StatusLineTermNC   guifg=#818596 guibg=#818596
augroup END

colorscheme iceberg

vnoremap <silent>p           "_dP

noremap <silent><C-u>        15k
noremap <silent><C-d>        15j

inoremap <silent><tab>       <C-v><tab>

nnoremap <nowait><C-j>       :<C-u>cnext<cr>
nnoremap <nowait><C-k>       :<C-u>cprevious<cr>

if has('win32') && has('gui_running')
    command! -bar -nargs=0 FullScreenToggle   :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)
    command!      -nargs=1 SetAlpha           :call libcallnr('vimtweak.dll', 'SetAlpha', <args>)
endif

command! -bar -nargs=0 SessionLoad   :source     $VIMTEMP/session.vim
command! -bar -nargs=0 SessionSave   :mksession! $VIMTEMP/session.vim

" https://github.com/rprichard/winpty/releases/
if has('win32') && has('terminal')
    if isdirectory(expand('~/Desktop/vim/src')) && isdirectory(expand('~/vimbatchfiles'))
        command! -bar -nargs=0 VimOpen         :execute printf('!start %s', expand('~/Desktop/vim/src/gvim.exe'))
        command! -bar -nargs=* VimFetch        :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-1-fetch.bat'), <q-args>)
        command! -bar -nargs=* VimTabSideBar   :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-2-tabsidebar.bat'), <q-args>)
        command! -bar -nargs=* VimClpumAndTab  :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-3-clpum_and_tabsidebar.bat'), <q-args>)
        command! -bar -nargs=* VimBuildgVim    :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-4-build-gvim.bat'), <q-args>)
        command! -bar -nargs=* VimBuildVim     :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-5-build-vim.bat'), <q-args>)
        command! -bar -nargs=* VimTest         :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-7-test.bat'), <q-args>)
        command! -bar -nargs=* VimPushToGithub :execute printf('terminal cmd /C "%s" %s', expand('~/vimbatchfiles/vim-8-push_to_github.bat'), <q-args>)
    endif
    function! TerminalOpenEvent() abort
        let last_term = term_list()[-1]
        let job = job_info(term_getjob(last_term))
        if fnamemodify(get(job.cmd, 0, ''), ':t') == 'cmd.exe'
            call term_sendkeys(last_term,  join(['prompt [$P]$_$$', 'cls', ''], "\r"))
        endif
    endfunction
    augroup term-vimrc
        autocmd!
        autocmd TerminalOpen * :call TerminalOpenEvent()
    augroup END
    tnoremap <silent><C-p>       <up>
    tnoremap <silent><C-n>       <down>
    tnoremap <silent><C-b>       <left>
    tnoremap <silent><C-f>       <right>
    tnoremap <silent><C-e>       <end>
    tnoremap <silent><C-a>       <home>
    tnoremap <silent><C-u>       <esc>
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
    "if has('vim_starting')
    "    set guifont=Consolas:h14:cANSI:qDRAFT
    "    set guifontwide=MS_Gothic:h14:cSHIFTJIS:qDRAFT
    "endif
endif

nohlsearch
