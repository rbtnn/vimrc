
if has('vimscript-4')
    scriptversion 4
else
    finish
endif

set encoding=utf-8
if exists('&makeencoding')
    set makeencoding=char
endif
scriptencoding utf-8

set winaltkeys=yes guioptions=mM

let $DOTVIM = expand('~/.vim')
let $VIMTEMP = expand('$DOTVIM/temp')

set packpath=$DOTVIM
set runtimepath+=$DOTVIM

let g:vim_indent_cont = &g:shiftwidth
let g:mapleader = 's'

set autoread
set background=dark
set clipboard=unnamed
set colorcolumn&
set display=lastline
set expandtab softtabstop=-1 shiftwidth=4 tabstop=4
set fileencodings=utf-8,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set foldcolumn=0 foldlevelstart=99 foldmethod=indent
set grepprg=internal
set incsearch hlsearch
set keywordprg=:help
set laststatus=2 statusline&
set list listchars=tab:\ \ \|
set matchpairs+=<:>
set mouse=a
set nocursorline nocursorcolumn
set noignorecase
set noshellslash completeslash=slash
set nowrap
set nowrapscan
set pumheight=10 completeopt=menu
set ruler rulerformat=%{&fenc}/%{&ff}/%{&ft}
set scrolloff=0 nonumber norelativenumber
set sessionoptions=buffers,curdir,tabpages
set shortmess& shortmess+=I shortmess-=S
set showmode
set showtabline=0
set tags=./tags;
set termguicolors
set visualbell noerrorbells t_vb=
set wildignore&
set wildmenu wildmode&

silent! source $DOTVIM/gloaded.vim
silent! source $DOTVIM/tabsidebar.vim
silent! source $DOTVIM/clpum.vim
silent! source $DOTVIM/etc.vim

" swap and backup files
silent! call mkdir(expand('$VIMTEMP/backupfiles'), 'p')
set noswapfile backup nowritebackup backupdir=$VIMTEMP/backupfiles//

" undo files
if has('persistent_undo')
    silent! call mkdir(expand('$VIMTEMP/undofiles'), 'p')
    set undofile undodir=$VIMTEMP/undofiles//
endif

inoremap <silent><nowait><tab>       <C-v><tab>
nnoremap <silent><nowait><C-j>       :<C-u>cnext<cr>zz
nnoremap <silent><nowait><C-k>       :<C-u>cprevious<cr>zz
nnoremap <silent><nowait><leader>s   :<C-u>Diffy -w<cr>

" https://github.com/rprichard/winpty/releases/
if has('win32') && has('terminal')
    tnoremap <silent><C-p>       <up>
    tnoremap <silent><C-n>       <down>
    tnoremap <silent><C-b>       <left>
    tnoremap <silent><C-f>       <right>
    tnoremap <silent><C-e>       <end>
    tnoremap <silent><C-a>       <home>
    tnoremap <silent><C-u>       <esc>
endif

let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config['_'] = {
    \   'runner' : 'terminal',
    \   'runner/terminal/into' : 1,
    \ }
let g:quickrun_config['rust'] = {
    \   'exec' : 'cargo run',
    \ }
" let g:quickrun_config['_']['hook/output_encode/encoding'] = &encoding
" let g:quickrun_config['_']['hook/output_encode/encoding'] = &termencoding

syntax on
filetype plugin indent on
set secure

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

packloadall!

augroup vimrc
    autocmd!
    autocmd VimEnter,BufEnter  * :silent! delcommand MANPAGER
    autocmd FileType         xml :setlocal completeslash&
augroup END

silent! colorscheme xxx

nohlsearch
