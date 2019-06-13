
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

set encoding=utf-8
if exists('&makeencoding')
    set makeencoding=char
endif
scriptencoding utf-8

if has('vim_starting') && has('win32')
    set guifont=Cica:h14:cSHIFTJIS:qDRAFT
endif 

set winaltkeys=yes guioptions=mM

let $DOTVIM = expand('~/.vim')
let $VIMTEMP = expand('$DOTVIM/temp')

silent! source $DOTVIM/gloaded.vim

syntax on
filetype plugin indent on
set secure

set packpath=$DOTVIM

silent! packadd vim-diffy
silent! packadd vim-popup_signature

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = ' '

set ambiwidth=double
set autoread
set clipboard=unnamed
set display=lastline
set expandtab softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set incsearch hlsearch
set keywordprg=:help
set laststatus=2 statusline&
set nolist listchars=trail:.,tab:<->
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noignorecase
set noshowmode
set nowrap
set nowrapscan
set pumheight=10 completeopt=menu
set ruler rulerformat=%{&fileformat}/%{&fileencoding}
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shellslash
set shortmess& shortmess+=I shortmess-=S
set tags=./tags;
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

set showtabline=0

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

vnoremap <silent>p           "_dP

noremap  <silent><C-u>       15k
noremap  <silent><C-d>       15j

noremap  <silent>j           gj
noremap  <silent>k           gk

inoremap <silent><tab>       <C-v><tab>

nnoremap <nowait><C-j>       :<C-u>cnext<cr>zz
nnoremap <nowait><C-k>       :<C-u>cprevious<cr>zz

if has('win32')
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
    autocmd VimEnter,BufEnter *    :silent! delcommand MANPAGER
augroup END

if has('tabsidebar')
    function! Tabsidebar() abort
        try
            let t = (g:actual_curtabpage == tabpagenr()) ? 'TabSideBarSel' : 'TabSideBar'
            if 1 == g:actual_curtabpage
                let g:tabsidebar_count = get(g:, 'tabsidebar_count', 0) + 1
                let lines = [printf('+%d+', g:tabsidebar_count)]
            else
                let lines = []
            endif
            let lines += [printf('%%#%s#-TABPAGE %d-', t, g:actual_curtabpage)]
            for x in getwininfo()
                if x.tabnr == g:actual_curtabpage
                    let iscurr = (winnr() == x.winnr) && (g:actual_curtabpage == tabpagenr())
                    let s = '(No Name)'
                    if x.terminal
                        let s = '(Terminal)'
                    elseif x.quickfix
                        let s = '(QuickFix)'
                    elseif x.loclist
                        let s = '(LocList)'
                    elseif iscurr && !empty(getcmdwintype())
                        let s = '(CmdLineWindow)'
                    elseif filereadable(bufname(x.bufnr))
                        let modi = getbufvar(x.bufnr, '&modified')
                        let read = getbufvar(x.bufnr, '&readonly')
                        let name = fnamemodify(bufname(x.bufnr), ':t')
                        let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
                    else
                        let sline = getwinvar(x.winnr, '&statusline')
                        let ft = getbufvar(x.bufnr, '&filetype')
                        if !empty(sline)
                            let s = sline
                        elseif !empty(ft)
                            let s = printf('[%s]', ft)
                        endif
                    endif
                    let lines += [printf('  %s %s', (iscurr ? '*' : ' '), s)]
                endif
            endfor
            return join(lines, "\n")
        catch
            return string(v:exception)
        endtry
    endfunction
    set showtabsidebar=2
    set tabsidebarcolumns=20
    set notabsidebarwrap
    set tabsidebar=%!Tabsidebar()
endif

if has('vim_starting')
    if has('win32')
        set termguicolors
    endif
    let g:gruvbox_italic = 0
    set background=dark
    colorscheme gruvbox
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

nohlsearch
