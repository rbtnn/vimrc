set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles')

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM mouse=a clipboard=unnamed belloff=all
set shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set keywordprg=:help wildmenu cmdheight=1 tags=./tags;
set list nowrap listchars=tab:\ \ \|,trail:- fileformats=unix,dos
set showtabline=0 laststatus=2 ambiwidth=double statusline&
set pumheight=5 noshowmode noruler nrformats=unsigned
set nobackup nowritebackup noswapfile undofile undodir=$VIMRC_UNDO//
set foldmethod=indent foldlevelstart=1 isfname-==
set sessionoptions=winpos,winsize,resize,buffers,curdir,tabpages
setglobal incsearch hlsearch nowrapscan ignorecase

if has('tabsidebar')
	let g:tabsidebar_vertsplit = 1
	set tabsidebar& tabsidebarwrap notabsidebaralign showtabsidebar=2 tabsidebarcolumns=16
endif

if has('win32')
	set wildignore+=NTUSER.DAT*,*.dll,*.exe
endif

let g:vim_indent_cont = &g:shiftwidth

silent! call mkdir($VIMRC_UNDO, 'p')
silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim

set runtimepath=$VIMRUNTIME
set packpath=$VIMRC_DOTVIM
packloadall!

if !has('nvim') && has('win32') && !filereadable(expand('~/AppData/Local/nvim/init.vim'))
	" This is the same as stdpath('config') in nvim.
	let s:initdir = expand('~/AppData/Local/nvim')
	call mkdir(s:initdir, 'p')
	call writefile(['silent! source ~/.vimrc'], s:initdir .. '/init.vim')
endif

command! -nargs=0 SessionSave :mksession! ~/.vimrc.session
command! -nargs=0 SessionLoad :source     ~/.vimrc.session

if has('win32')
	tnoremap <silent><nowait><C-b>       <left>
	tnoremap <silent><nowait><C-f>       <right>
	tnoremap <silent><nowait><C-e>       <end>
	tnoremap <silent><nowait><C-a>       <home>
	tnoremap <silent><nowait><C-u>       <esc>
endif

if has('nvim')
	tnoremap <silent><nowait><esc>       <C-\><C-n>
else
	tnoremap <silent><nowait><esc>       <C-w>N
endif

nnoremap <silent><nowait><Plug>(open-fold-at-center)    :<C-u>silent! foldopen!<cr>zz
nmap     <silent><nowait><C-n>                          :<C-u>cnext<cr><Plug>(open-fold-at-center)
nmap     <silent><nowait><C-p>                          :<C-u>cprevious<cr><Plug>(open-fold-at-center)
nmap     <silent><nowait>n                              n<Plug>(open-fold-at-center)
nmap     <silent><nowait>N                              N<Plug>(open-fold-at-center)
nmap     <silent><nowait>*                              *<Plug>(open-fold-at-center)

inoremap <silent><tab>               <C-v><tab>



silent! source ~/.vimrc.local



" Execute ':helptags ALL' Asynchronously
if !exists('g:helptags')
	if executable(v:progpath) && exists('*job_start') && has('vim_starting')
		call job_start([
			\ v:progpath,
			\ '--cmd', ':let g:helptags = v:true',
			\ '-c', ':silent! helptags ALL',
			\ '-c', ':qa!',
			\ ], {})
	endif
endif



" --------------------------
" tyru/restart.vim
" --------------------------
let g:restart_sessionoptions = 'winpos,winsize,resize'

" --------------------------
" rbtnn/vim-grizzly
" --------------------------
let g:grizzly_history = '$VIMRC_DOTVIM/.grizzly_history'

" --------------------------
" kana/vim-operator-replace
" --------------------------
nmap     <silent><nowait>s           <Plug>(operator-replace)

" --------------------------
" itchyny/lightline.vim
" --------------------------
let g:lightline = { 'colorscheme': 'srcery', }

" --------------------------
" srcery-colors/srcery-vim
" --------------------------
if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
	set termguicolors
endif
let g:srcery_italic = 0
set background=dark
silent! colorscheme srcery



augroup vimrc
	autocmd!
	autocmd ColorScheme * :highlight CursorIM guifg=NONE guibg=Red
	autocmd FileType help :command! HelpEdit
		\ : setlocal list tabstop=8 shiftwidth=8 softtabstop=8
		\ | setlocal noexpandtab textwidth=78 conceallevel=0
		\ | setlocal colorcolumn=+1 noreadonly modifiable
augroup END



filetype indent plugin on
syntax on
