set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')

" system
set langmenu=en_gb.latin1
set winaltkeys=yes
set guioptions=mM
set mouse=a
set belloff=all
set clipboard=unnamed
set ambiwidth=double

" indent size
set shiftround
set softtabstop=-1
set shiftwidth=4
set tabstop=4

" cmdline
set cmdwinheight=5
set cmdheight=2

" backup/swap
set nobackup
set nowritebackup
set noswapfile

" undo
if has('nvim')
	let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles/neovim')
else
	let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles/vim')
endif
set undofile
set undodir=$VIMRC_UNDO//
silent! call mkdir($VIMRC_UNDO, 'p')

" statusline/tabline/ruler/mode
set laststatus=2
set statusline&
set showtabline=0
set showmode
set ruler
set rulerformat=%16(%{&ft}/%{&ff}/%{&fileencoding}%)

" complete
set pumheight=10
set wildmenu
set isfname-==
set complete-=t

" special
set list
set listchars=tab:\ \ \|,trail:-

" fold
set foldmethod=indent
set foldlevelstart=999

" search
set incsearch
set hlsearch
set nowrapscan
set ignorecase

" vimgrep
set grepformat&
set grepprg=internal

" others
set autoread
set keywordprg=:help
set tags=./tags;
set nowrap
set fileformats=unix,dos
set nrformats=unsigned
set sessionoptions=winpos,winsize,resize,buffers,curdir,tabpages

if has('tabsidebar')
	function! Tabsidebar() abort
		let xs = ['%#TabSideBar#' .. '(' .. g:actual_curtabpage .. ')' .. '%#TabSideBar#']
		for x in filter(getwininfo(), { i, x -> g:actual_curtabpage == x['tabnr']})
			let s = bufname(x['bufnr'])
			if filereadable(s)
				let s = fnamemodify(s, ':t')
			elseif x['terminal']
				let s = '[Terminal]'
			elseif x['quickfix']
				let s = '[Quickfix]'
			elseif x['loclist']
				let s = '[Loclist]'
			elseif getbufvar(x['bufnr'], '&buftype') == 'nofile'
				let s = '[Scratch]'
			elseif empty(s)
				let s = '[No Name]'
			endif
			let xs += [
				\ (x['winid'] == win_getid() ? '%#TabSideBarSel#' : '%#TabSideBar#')
				\ .. ' ' .. s .. ' '
				\ .. (getbufvar(x['bufnr'], '&modified') ? '[+]' : '')
				\ .. (getbufvar(x['bufnr'], '&readonly') ? '[RO]' : '')
				\ ]
		endfor
		return join(xs, "\n")
	endfunction
	let g:tabsidebar_vertsplit = 1
	set tabsidebar=%!Tabsidebar()
	set tabsidebarwrap
	set notabsidebaralign
	set showtabsidebar=2
	set tabsidebarcolumns=16
endif

if has('win32')
	set wildignore+=NTUSER.DAT*,*.dll,*.exe,desktop.ini,*.lnk
endif

if !has('nvim') && has('win32') && !filereadable(expand('~/AppData/Local/nvim/init.vim'))
	" This is the same as stdpath('config') in nvim.
	let s:initdir = expand('~/AppData/Local/nvim')
	call mkdir(s:initdir, 'p')
	call writefile(['silent! source ~/.vimrc'], s:initdir .. '/init.vim')
endif

silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim

set runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM

let g:vim_indent_cont = &g:shiftwidth
let g:plug_url_format = 'https://github.com/%s.git'
if has('nvim')
	let g:loaded_restart = 1
endif

call plug#begin(expand('$VIMRC_DOTVIM/pack/my/start'))

call plug#('danilo-augusto/vim-afterglow')
call plug#('kana/vim-operator-replace')
call plug#('kana/vim-operator-user')
call plug#('mattn/vim-molder')
call plug#('obcat/vim-highlightedput')
call plug#('rbtnn/vim-find')
call plug#('rbtnn/vim-gloaded')
call plug#('rbtnn/vim-grizzly')
call plug#('rbtnn/vim-mrw')
call plug#('rbtnn/vim-vimscript_indentexpr')
call plug#('rbtnn/vim-vimscript_lasterror')
call plug#('rbtnn/vim-vimscript_tagfunc')
call plug#('thinca/vim-qfreplace')
call plug#('tyru/restart.vim')

silent! source ~/.vimrc.local

call plug#end()

augroup vimrc
	autocmd!
	autocmd CmdlineEnter     *
		\ : for s:cmdname in ['MANPAGER', 'VimFoldh', 'Plug', 'PlugDiff', 'PlugInstall', 'PlugSnapshot', 'PlugStatus', 'PlugUpgrade']
		\ | 	execute printf('silent! delcommand %s', s:cmdname)
		\ | endfor
	autocmd ColorScheme      *
		\ : highlight Pmenu        guifg=#d6d6d6 guibg=NONE
		\ | highlight PmenuSel     guifg=#a9dd9d guibg=NONE    gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		\ | highlight PmenuSbar    guibg=#202020 guifg=#000000 gui=NONE
		\ | highlight PmenuThumb   guibg=#606060 guifg=#000000 gui=NONE
		\ | highlight SpecialKey   guifg=#1a242e
		\ | highlight NonText      guifg=#1a242e
		\ | highlight DiffLine                                 gui=NONE           cterm=NONE
		\ | highlight StatusLine   guifg=#d6d6d6 guibg=#000000 gui=NONE           cterm=NONE
		\ | highlight TabLine      guifg=#d6d6d6 guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight TabLineFill  guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight TabLineSel   guifg=#a9dd9d guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight Terminal     guifg=#d6d6d6 guibg=#000000 gui=NONE           cterm=NONE
		\ | highlight VertSplit    guifg=#5a647e guibg=NONE
		\ | highlight WildMenu     guifg=#a9dd9d guibg=#000000 gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		\ | highlight CursorIM     guifg=NONE    guibg=#ff00ff
augroup END

" terminal keymappings
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
tnoremap <silent><nowait><C-j>           <Cmd>tabnext<cr>
tnoremap <silent><nowait><C-k>           <Cmd>tabprevious<cr>

" normal keymappings
nnoremap <silent><nowait><C-n>           <Cmd>cnext<cr>
nnoremap <silent><nowait><C-p>           <Cmd>cprevious<cr>
nnoremap <silent><nowait><C-j>           <Cmd>tabnext<cr>
nnoremap <silent><nowait><C-k>           <Cmd>tabprevious<cr>

" insert keymappings
inoremap <silent><nowait><tab>           <C-v><tab>

" cmdline keymappings
cnoremap         <nowait><C-b>           <left>
cnoremap         <nowait><C-f>           <right>
cnoremap         <nowait><C-e>           <end>
cnoremap         <nowait><C-a>           <home>
cnoremap         <nowait><C-q>           <C-f>
cnoremap   <expr><nowait><space>         (wildmenumode() && (getcmdline() =~# '^[tl]\?cd ')) ? '<space><bs>' : '<space>'

if !has('win32') && executable('sudo')
	command! -nargs=0 SudoWrite    :w !sudo tee % > /dev/null
endif

if has_key(g:plugs, 'vim-highlightedput')
	nmap p <Plug>(highlightedput-p)
	xmap p <Plug>(highlightedput-p)
	nmap P <Plug>(highlightedput-P)
	xmap P <Plug>(highlightedput-P)
	let g:highlightedput_highlight_duration = 100
	augroup vimrc
		autocmd ColorScheme      * : highlight link HighlightedputRegion  Search
	augroup END
endif

if has_key(g:plugs, 'vim-mrw')
	nnoremap <silent><nowait><space>         <Cmd>MRW<cr>
endif

if has_key(g:plugs, 'vim-find')
	nnoremap <silent><nowait><C-f>           <Cmd>Find<cr>
endif

if has_key(g:plugs, 'vim-operator-replace')
	nmap     <silent><nowait>s               <Plug>(operator-replace)
endif

if has_key(g:plugs, 'restart.vim')
	let g:restart_sessionoptions = &sessionoptions
endif

if has_key(g:plugs, 'vim-molder')
	let g:molder_show_hidden = 1
	augroup vimrc
		autocmd FileType         molder
			\ :nnoremap <silent><buffer>l   :<c-u>call molder#open()<cr>
			\ |nnoremap <silent><buffer>h   :<c-u>call molder#up()<cr>
	augroup END
endif

if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
	set termguicolors
endif

if has_key(g:plugs, 'vim-afterglow')
	silent! colorscheme afterglow
endif

filetype indent plugin on
syntax on
