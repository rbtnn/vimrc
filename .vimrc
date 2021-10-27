set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/vim')

" system
language message C
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
if isdirectory($VIMRC_DOTVIM)
	if has('nvim')
		let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles/neovim')
	else
		let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles/vim')
	endif
	set undofile
	set undodir=$VIMRC_UNDO//
	silent! call mkdir($VIMRC_UNDO, 'p')
else
	set noundofile
endif

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

" matchpairs
set showmatch
set matchtime=1
set matchpairs+=<:>

" vimgrep
set grepformat&
set grepprg=internal

" others
set autoread
set fileformats=unix,dos
set keywordprg=:help
set nowrap
set nrformats=unsigned
set scrolloff=5
set sessionoptions=winpos,resize
set tags=./tags;
set updatetime=1000

if has('tabsidebar')
	function! Tabsidebar() abort
		let xs = ['%#TabSideBar#' .. '--- ' .. g:actual_curtabpage .. ' ---' .. '%#TabSideBar#']
		for x in filter(getwininfo(), { i, x -> g:actual_curtabpage == x['tabnr']})
			let ft = getbufvar(x['bufnr'], '&filetype')
			let bt = getbufvar(x['bufnr'], '&buftype')
			let s = bufname(x['bufnr'])
			let m = v:true
			let r = v:true
			if ft == 'help'
				let s = '[help]'
				let m = v:false
				let r = v:false
			elseif filereadable(s)
				let s = fnamemodify(s, ':t')
			elseif x['terminal']
				let s = '[Terminal]'
				let m = v:false
				let r = v:false
			elseif x['quickfix']
				let s = '[Quickfix]'
			elseif x['loclist']
				let s = '[Loclist]'
			elseif bt == 'nofile'
				if !empty(ft)
					let s = printf('[%s]', ft)
					let m = v:false
					let r = v:false
				else
					let s = '[Scratch]'
				endif
			elseif empty(s)
				let s = '[No Name]'
			endif
			let xs += [
				\ (x['winid'] == win_getid() ? '%#TabSideBarSel#' : '%#TabSideBar#')
				\ .. ' ' .. s .. ' '
				\ .. (getbufvar(x['bufnr'], '&modified') && m ? '[+]' : '')
				\ .. (getbufvar(x['bufnr'], '&readonly') && r ? '[RO]' : '')
				\ ]
		endfor
		let xs += ['']
		return join(xs, "\n")
	endfunction
	let g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!Tabsidebar()
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

set packpath=
set runtimepath=$VIMRUNTIME

if isdirectory($VIMRC_DOTVIM)
	silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim

	set runtimepath+=$VIMRC_DOTVIM

	let g:vim_indent_cont = &g:shiftwidth
	let g:plug_url_format = 'https://github.com/%s.git'
	if has('nvim')
		let g:loaded_restart = 1
	endif

	call plug#begin(expand('$VIMRC_DOTVIM/pack/my/start'))

	call plug#('danilo-augusto/vim-afterglow')
	call plug#('kana/vim-operator-replace')
	call plug#('kana/vim-operator-user')
	call plug#('rbtnn/vim-find')
	call plug#('rbtnn/vim-gloaded')
	call plug#('rbtnn/vim-grizzly')
	call plug#('rbtnn/vim-mrw')
	call plug#('rbtnn/vim-vimscript_indentexpr')
	call plug#('rbtnn/vim-vimscript_lasterror')
	call plug#('rbtnn/vim-vimscript_tagfunc')
	call plug#('rbtnn/vimtweak')
	call plug#('thinca/vim-qfreplace')
	call plug#('tyru/restart.vim')

	silent! source ~/.vimrc.local

	call plug#end()

	function! s:is_installed(name) abort
		if has_key(g:plugs, a:name)
			return isdirectory(g:plugs[a:name]['dir'])
		else
			return v:false
		endif
	endfunction

	augroup vimrc
		autocmd!
		autocmd FileType     help :setlocal colorcolumn=78
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
			\ | highlight Terminal     guifg=NONE    guibg=#111111
	augroup END

	if s:is_installed('vim-find')
		nnoremap <silent><nowait><space>         <Cmd>FindHistory<cr>
	endif

	if s:is_installed('vim-operator-replace')
		nmap     <silent><nowait>s               <Plug>(operator-replace)
	endif

	if s:is_installed('restart.vim')
		let g:restart_sessionoptions = &sessionoptions
	endif

	if s:is_installed('vimtweak')
		if has('gui_running') && has('win32')
			augroup vimrc
				autocmd VimEnter     * :VimTweakSetAlpha 240
			augroup END
		endif
	endif

	if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
		set termguicolors
	endif

	if s:is_installed('vim-afterglow')
		silent! colorscheme afterglow
	endif
endif

" -------------------------
" terminal keymappings
" -------------------------
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

" -------------------------
" normal keymappings
" -------------------------
nnoremap <silent><nowait><C-n>           <Cmd>cnext<cr>
nnoremap <silent><nowait><C-p>           <Cmd>cprevious<cr>
nnoremap <silent><nowait><C-j>           <Cmd>tabnext<cr>
nnoremap <silent><nowait><C-k>           <Cmd>tabprevious<cr>

" I use Ctrl-y and Ctrl-d to scroll. Others are disabled.
nnoremap <silent><nowait><C-e>           <nop>
nnoremap <silent><nowait><C-y>           <nop>
nnoremap <silent><nowait><C-f>           <nop>
nnoremap <silent><nowait><C-b>           <nop>

" -------------------------
" insert keymappings
" -------------------------
inoremap <silent><nowait><tab>           <C-v><tab>

" -------------------------
" cmdline keymappings
" -------------------------
cnoremap         <nowait><C-b>           <left>
cnoremap         <nowait><C-f>           <right>
cnoremap         <nowait><C-e>           <end>
cnoremap         <nowait><C-a>           <home>
cnoremap         <nowait><C-q>           <C-f>
cnoremap   <expr><nowait><space>         (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

filetype indent plugin on
syntax on
