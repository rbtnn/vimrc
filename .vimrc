
scriptversion 2

set encoding=utf-8
if exists('&makeencoding')
    set makeencoding=char
endif
scriptencoding utf-8

if ('utf-8' == &encoding) && has('vim_starting') && has('win32')
    set renderoptions=type:directx,renmode:5
    " https://github.com/tonsky/FiraCode
    set guifont=Fira_Code:h12:cANSI:qDRAFT
    set guifontwide=MS_Gothic:h12:cSHIFTJIS:qDRAFT
endif 

set winaltkeys=yes guioptions=mM

let g:loaded_2html_plugin      = 1 "$VIMRUNTIME/plugin/tohtml.vim
let g:loaded_getscript         = 1 "$VIMRUNTIME/autoload/getscript.vim
let g:loaded_getscriptPlugin   = 1 "$VIMRUNTIME/plugin/getscriptPlugin.vim
let g:loaded_gzip              = 1 "$VIMRUNTIME/plugin/gzip.vim
let g:loaded_logipat           = 1 "$VIMRUNTIME/plugin/logiPat.vim
let g:loaded_logiPat           = 1 "$VIMRUNTIME/plugin/logiPat.vim
let g:loaded_matchparen        = 1 "$VIMRUNTIME/plugin/matchparen.vim
let g:loaded_netrw             = 1 "$VIMRUNTIME/autoload/netrw.vim
let g:loaded_netrwFileHandlers = 1 "$VIMRUNTIME/autoload/netrwFileHandlers.vim
let g:loaded_netrwPlugin       = 1 "$VIMRUNTIME/plugin/netrwPlugin.vim
let g:loaded_netrwSettings     = 1 "$VIMRUNTIME/autoload/netrwSettings.vim
let g:loaded_rrhelper          = 1 "$VIMRUNTIME/plugin/rrhelper.vim
let g:loaded_spellfile_plugin  = 1 "$VIMRUNTIME/plugin/spellfile.vim
let g:loaded_sql_completion    = 1 "$VIMRUNTIME/autoload/sqlcomplete.vim
let g:loaded_syntax_completion = 1 "$VIMRUNTIME/autoload/syntaxcomplete.vim
let g:loaded_tar               = 1 "$VIMRUNTIME/autoload/tar.vim
let g:loaded_tarPlugin         = 1 "$VIMRUNTIME/plugin/tarPlugin.vim
let g:loaded_vimball           = 1 "$VIMRUNTIME/autoload/vimball.vim
let g:loaded_vimballPlugin     = 1 "$VIMRUNTIME/plugin/vimballPlugin.vim
let g:loaded_zip               = 1 "$VIMRUNTIME/autoload/zip.vim
let g:loaded_zipPlugin         = 1 "$VIMRUNTIME/plugin/zipPlugin.vim
let g:vimsyn_embed             = 1 "$VIMRUNTIME/syntax/vim.vim

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = ' '

let $DOTVIM = expand('~/.vim')
let $VIMTEMP = expand('$DOTVIM/temp')

set packpath=$DOTVIM

packadd vim-diffy

syntax on
filetype plugin indent on
set secure

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
set list listchars=trail:.,tab:<->
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
set shortmess& shortmess+=I
set tags=./tags;
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

set showtabline=0
if has('tabsidebar')
    function! Tabsidebar() abort
        try
            let t = (g:actual_curtabpage == tabpagenr()) ? 'TabSideBarSel' : 'TabSideBar'
            let lines = ['']
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

for s:ch in ['w', 'b', 't', '<', '>', '[', ']', '"', "'"]
    execute printf('nnoremap <silent>si%s    vi%s"_c<C-r>"<esc>gvo<esc>', s:ch, s:ch)
endfor

noremap  <silent><C-u>       5k
noremap  <silent><C-d>       5j

noremap  <silent>j           gj
noremap  <silent>k           gk

inoremap <silent><tab>       <C-v><tab>

nnoremap <nowait><C-j>       :<C-u>cnext<cr>zz
nnoremap <nowait><C-k>       :<C-u>cprevious<cr>zz

command! -bar -nargs=0 LcdRootDir   :call diffy#cd2rootdir('lcd')

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

augroup vimscript
    autocmd!
    autocmd FileType vim    :command! -bar -buffer   Run  :call vimscript#run()
augroup END

" https://jonasjacek.github.io/colors/
augroup override-colorscheme
    autocmd!
    autocmd InsertEnter *                :highlight TabLine     ctermfg=245 ctermbg=52 guifg=#8a8a8a guibg=#5f0000
    autocmd InsertEnter *                :highlight TabLineSel  ctermfg=255 ctermbg=88 guifg=#eeeeee guibg=#870000
    autocmd InsertEnter *                :highlight TabLineFill ctermfg=255 ctermbg=52 guifg=#eeeeee guibg=#5f0000
    autocmd ColorScheme,InsertLeave *    :highlight TabLine     ctermfg=245 ctermbg=24 guifg=#8a8a8a guibg=#005f87
    autocmd ColorScheme,InsertLeave *    :highlight TabLineSel  ctermfg=255 ctermbg=31 guifg=#eeeeee guibg=#0087af
    autocmd ColorScheme,InsertLeave *    :highlight TabLineFill ctermfg=255 ctermbg=24 guifg=#eeeeee guibg=#005f87
augroup END

if has('vim_starting')
    set background=light
    colorscheme PaperColor
endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

nohlsearch
