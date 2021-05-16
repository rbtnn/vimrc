set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles')

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM mouse=a clipboard=unnamed belloff=all
set shiftround softtabstop=-1 shiftwidth=2 tabstop=2
set keywordprg=:help wildmenu cmdheight=1 tags=./tags;
set list nowrap listchars=tab:\ \ \|,trail:- fileformats=unix,dos
set showtabline=0 laststatus=2 statusline& ambiwidth=double
set nobackup nowritebackup noswapfile undofile undodir=$VIMRC_UNDO//
set foldmethod=indent foldlevelstart=1 ruler isfname-==
set sessionoptions=winpos,winsize,resize,buffers,curdir,tabpages
set cursorline
setglobal incsearch hlsearch nowrapscan ignorecase

if has('tabsidebar')
	set tabsidebar& tabsidebarwrap notabsidebaralign showtabsidebar=2 tabsidebarcolumns=16
endif

let g:restart_sessionoptions = &sessionoptions
let g:vim_indent_cont = &g:shiftwidth
let g:fern#default_hidden = 1
let g:github_colors_soft = 0

silent! call mkdir($VIMRC_UNDO, 'p')
silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim
silent! source $VIMRC_ROOT/vim-on-windows/vimbatchfiles/setup.vim

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

tnoremap <silent><nowait><C-p>       <up>
tnoremap <silent><nowait><C-n>       <down>
tnoremap <silent><nowait><C-b>       <left>
tnoremap <silent><nowait><C-f>       <right>
tnoremap <silent><nowait><C-e>       <end>
tnoremap <silent><nowait><C-a>       <home>
tnoremap <silent><nowait><C-u>       <esc>

tnoremap <silent><nowait>gt          <C-w>gt
tnoremap <silent><nowait>gT          <C-w>gT

nnoremap <silent><nowait><expr><space>
	\ isdirectory(expand('%:h'))
	\ ? '<Cmd>Fern %:h -drawer<cr>'
	\ : '<Cmd>Fern .   -drawer<cr>'

nnoremap <silent><nowait><C-s>       <Cmd>Diffy  -w<cr>

nnoremap <silent><nowait><C-n>       <Cmd>cnext     \| silent! foldopen!<cr>zz
nnoremap <silent><nowait><C-p>       <Cmd>cprevious \| silent! foldopen!<cr>zz

nmap     <silent><nowait>s           <Plug>(operator-replace)

inoremap <silent><tab>               <C-v><tab>

set background=light
silent! colorscheme github

silent! source ~/.vimrc.local

" Execute ':helptags ALL' Asynchronously
if executable(v:progpath) && exists('*job_start') && has('vim_starting')
	call job_start([
		\ v:progpath, '-u', 'NONE', '-N',
		\ '--cmd', ':helptags ALL',
		\ '--cmd', ':qa!',
		\ ], {})
endif

filetype indent plugin on
syntax on
