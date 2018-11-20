
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

silent! source $VIMPLUGINS/vim-gloaded/gloaded.vim
silent! unlet g:loaded_matchparen

set runtimepath=
set runtimepath+=$VIMPLUGINS/vim-amethyst
set runtimepath+=$VIMPLUGINS/vim-git
set runtimepath+=$VIMPLUGINS/vim-helper
set runtimepath+=$VIMPLUGINS/vim-msbuild
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
set scrolloff=0 number norelativenumber
set sessionoptions=blank,buffers,curdir,tabpages,terminal
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

if has('tabsidebar')
    set laststatus=2
    set statusline=%#TabSideBarFill#
    set showtabline=2
    set tabline=%#StatusLine#%{getcwd()}%#StatusLineNC#
    set showtabsidebar=2
    set tabsidebarcolumns=30
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
            let lines = [printf('%%#%s#TabPage:%d', t, g:actual_curtabpage)]
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
                    let lines += [printf('%%#%s#  %d) %s', (iscurr ? 'Title' : t), x.winnr, s)]
                endif
            endfor
            return join(lines, "\n")
        catch
            return string(v:exception)
        endtry
    endfunction
endif

colorscheme amethyst

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

command! -bar -nargs=0 VimNew      :execute printf('!start %s', expand('~/Desktop/vim/src/gvim.exe'))

" https://github.com/rprichard/winpty/releases/
if has('win32') && has('terminal')
    augroup term-vimrc
        autocmd!
        autocmd TerminalOpen * :call term_sendkeys(term_list()[-1],  join(['prompt [$P]$_$$', 'cls', ''], "\r"))
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
