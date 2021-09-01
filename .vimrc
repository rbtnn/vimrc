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
set keywordprg=:help wildmenu tags=./tags; cmdwinheight=5 cmdheight=3
set list nowrap listchars=tab:\ \ \|,trail:- fileformats=unix,dos
set showtabline=0 laststatus=2 ambiwidth=double statusline&
set pumheight=10 noshowmode noruler nrformats=unsigned
set nobackup nowritebackup noswapfile undofile undodir=$VIMRC_UNDO//
set foldmethod=indent foldlevelstart=999 isfname-== complete-=t
set sessionoptions=winpos,winsize,resize,buffers,curdir,tabpages
setglobal incsearch hlsearch nowrapscan ignorecase

let s:win32_grep_path = 'C:/Program Files/Git/usr/bin/grep.exe'
if executable('grep')
	set grepformat& grepprg=grep\ -I\ --line-number\ --with-filename
elseif has('win32') && filereadable(s:win32_grep_path)
	set grepformat&
   	let &grepprg = printf('"%s" -I --line-number --with-filename', s:win32_grep_path)
else
	set grepformat& grepprg=internal
endif

if has('tabsidebar')
	let g:tabsidebar_vertsplit = 1
	set tabsidebar=%{g:actual_curtabpage}.\ %t
	set tabsidebarwrap notabsidebaralign showtabsidebar=2 tabsidebarcolumns=16
endif

if has('win32')
	set wildignore+=NTUSER.DAT*,*.dll,*.exe,desktop.ini,*.lnk
endif

let g:vim_indent_cont = &g:shiftwidth

silent! call mkdir($VIMRC_UNDO, 'p')
silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim

set runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM

call plug#begin(expand('$VIMRC_DOTVIM/pack/my/start'))

Plug 'itchyny/lightline.vim'
Plug 'kana/vim-operator-replace'
Plug 'kana/vim-operator-user'
Plug 'rbtnn/vim-gloaded'
Plug 'rbtnn/vim-grizzly'
Plug 'rbtnn/vim-vimscript_indentexpr'
Plug 'rbtnn/vim-vimscript_lasterror'
Plug 'rbtnn/vim-vimscript_tagfunc'
Plug 'rbtnn/vim9-e'
Plug 'rhysd/vim-color-spring-night'
Plug 'thinca/vim-prettyprint'
Plug 'thinca/vim-qfreplace'
Plug 'tyru/restart.vim'

silent! source ~/.vimrc.local

call plug#end()

if !has('nvim') && has('win32') && !filereadable(expand('~/AppData/Local/nvim/init.vim'))
	" This is the same as stdpath('config') in nvim.
	let s:initdir = expand('~/AppData/Local/nvim')
	call mkdir(s:initdir, 'p')
	call writefile(['silent! source ~/.vimrc'], s:initdir .. '/init.vim')
endif

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

inoremap <silent><tab>               <C-v><tab>

nnoremap <silent><C-n>               <Cmd>cnext<cr>
nnoremap <silent><C-p>               <Cmd>cprevious<cr>

nnoremap <silent><C-j>               <Cmd>tabnext<cr>
tnoremap <silent><C-j>               <Cmd>tabnext<cr>
nnoremap <silent><C-k>               <Cmd>tabprevious<cr>
tnoremap <silent><C-k>               <Cmd>tabprevious<cr>

if !has('win32') && executable('sudo')
	command! -nargs=0 SudoWrite    :w !sudo tee % > /dev/null
endif

augroup vimrc
	autocmd!
	autocmd QuickFixCmdPost  * :copen
	autocmd CmdlineEnter     * {
		silent! delcommand MANPAGER
		silent! delcommand VimFoldh
	}
	autocmd ColorScheme      * {
		highlight Pmenu          guifg=#ffffff guibg=#000000
		highlight PmenuSel       guifg=#a9dd9d guibg=#000000 gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		highlight SpecialKey     guifg=#203040
		highlight TabLine        guifg=#fffeeb guibg=#132132 gui=NONE
		highlight TabLineFill    guifg=#132132 guibg=NONE
		highlight TabLineSel     guifg=#fedf81 guibg=#132132
		highlight Terminal       guifg=#ffffff guibg=#000000
		highlight VertSplit      guifg=#132132 guibg=#536273
	}
augroup END

" --------------------------
" tyru/restart.vim
" --------------------------
let g:restart_sessionoptions = &sessionoptions

" --------------------------
" rbtnn/vim9-e
" --------------------------
nnoremap <silent><nowait><space>     :<C-u>EFiler<cr>

" --------------------------
" kana/vim-operator-replace
" --------------------------
nmap     <silent><nowait>s           <Plug>(operator-replace)

" --------------------------
" itchyny/lightline.vim
" --------------------------
let g:lightline = {}
let g:lightline['colorscheme'] = 'simpleblack'
if has('gui_running')
	let g:lightline['separator'] = { 'left': nr2char(0xe0b0), 'right': nr2char(0xe0b2) }
endif

" --------------------------
" rhysd/vim-color-spring-night
" --------------------------
if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
	set termguicolors
endif
let g:spring_night_high_contrast = 1
let g:spring_night_kill_italic = 1
set background=dark
silent! colorscheme spring-night

filetype indent plugin on
syntax on
