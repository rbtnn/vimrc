set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles')

set langmenu=en_gb.latin1
set autoread
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

if has('tabsidebar')
	let g:tabsidebar_vertsplit = 1
	set tabsidebar=%{g:actual_curtabpage}.\ %t
	set tabsidebarwrap notabsidebaralign showtabsidebar=2 tabsidebarcolumns=16
endif

if has('win32')
	set wildignore+=NTUSER.DAT*,*.dll,*.exe,desktop.ini,*.lnk
endif

silent! call mkdir($VIMRC_UNDO, 'p')
silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim

set runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM

call plug#begin(expand('$VIMRC_DOTVIM/pack/my/start'))

Plug 'danilo-augusto/vim-afterglow'
Plug 'itchyny/lightline.vim'
Plug 'kana/vim-operator-replace'
Plug 'kana/vim-operator-user'
Plug 'rbtnn/vim-gloaded'
Plug 'rbtnn/vim-grizzly'
Plug 'rbtnn/vim-vimscript_indentexpr'
Plug 'rbtnn/vim-vimscript_lasterror'
Plug 'rbtnn/vim-vimscript_tagfunc'
Plug 'thinca/vim-prettyprint'
Plug 'thinca/vim-qfreplace'
Plug 'tyru/restart.vim'

silent! source ~/.vimrc.local

call plug#end()

function! s:autocmd_cmdlineenter() abort
	for cmdname in [
		\ 'MANPAGER', 'VimFoldh', 'PlugDiff', 'PlugInstall',
		\ 'PlugSnapshot', 'PlugStatus', 'PlugUpgrade']
		execute printf('silent! delcommand %s', cmdname)
	endfor
endfunction

function! s:autocmd_vimenter() abort
	if !has('nvim') && has('win32') && !filereadable(expand('~/AppData/Local/nvim/init.vim'))
		" This is the same as stdpath('config') in nvim.
		let s:initdir = expand('~/AppData/Local/nvim')
		call mkdir(s:initdir, 'p')
		call writefile(['silent! source ~/.vimrc'], s:initdir .. '/init.vim')
	endif

	let s:win32_grep_path = 'C:/Program Files/Git/usr/bin/grep.exe'
	if executable('grep')
		set grepformat& grepprg=grep\ -I\ --line-number\ --with-filename
	elseif has('win32') && filereadable(s:win32_grep_path)
		set grepformat&
		let &grepprg = printf('"%s" -I --line-number --with-filename', s:win32_grep_path)
	else
		set grepformat& grepprg=internal
	endif

	let g:vim_indent_cont = &g:shiftwidth
	let g:restart_sessionoptions = &sessionoptions

	nmap     <silent><nowait>s   <Plug>(operator-replace)

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

	nnoremap <silent><space>             <Cmd>GitDiff<cr>

	nnoremap <silent><C-n>               <Cmd>cnext<cr>
	nnoremap <silent><C-p>               <Cmd>cprevious<cr>

	nnoremap <silent><C-j>               <Cmd>tabnext<cr>
	tnoremap <silent><C-j>               <Cmd>tabnext<cr>
	nnoremap <silent><C-k>               <Cmd>tabprevious<cr>
	tnoremap <silent><C-k>               <Cmd>tabprevious<cr>

	if !has('win32') && executable('sudo')
		command! -nargs=0 SudoWrite    :w !sudo tee % > /dev/null
	endif

	silent! colorscheme afterglow
	if g:colors_name == 'afterglow'
		highlight Pmenu        guifg=#d6d6d6 guibg=NONE
		highlight PmenuSel     guifg=#a9dd9d guibg=NONE    gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		highlight PmenuSbar    guibg=#202020 guifg=#000000 gui=NONE
		highlight PmenuThumb   guibg=#606060 guifg=#000000 gui=NONE
		highlight SpecialKey   guifg=#1a242e
		highlight NonText      guifg=#1a242e
		highlight DiffLine                                 gui=NONE           cterm=NONE
		highlight StatusLine   guifg=#d6d6d6 guibg=#000000 gui=NONE           cterm=NONE
		highlight TabLine      guifg=#d6d6d6 guibg=NONE    gui=NONE           cterm=NONE
		highlight TabLineFill  guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
		highlight TabLineSel   guifg=#a9dd9d guibg=NONE    gui=NONE           cterm=NONE
		highlight Terminal     guifg=#d6d6d6 guibg=#000000 gui=NONE           cterm=NONE
		highlight VertSplit    guifg=#5a647e guibg=NONE
		highlight WildMenu     guifg=#a9dd9d guibg=#000000 gui=NONE           cterm=NONE
	endif

	let g:lightline = {}
	let g:lightline['colorscheme'] = 'simpleblack'
	if (&guifont =~# 'Cica') && (&encoding == 'utf-8')
		let g:lightline['separator'] = { 'left': nr2char(0xe0b0), 'right': nr2char(0xe0b2) }
	endif
	call lightline#enable()
endfunction

augroup vimrc
	autocmd!
	autocmd QuickFixCmdPost  * :copen
	autocmd CmdlineEnter     * :call s:autocmd_cmdlineenter()
	autocmd VimEnter         * :call s:autocmd_vimenter()
augroup END

if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
	set termguicolors
endif

filetype indent plugin on
syntax on
