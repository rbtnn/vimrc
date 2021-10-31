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
	" https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
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
set sessionoptions=winpos,resize,tabpages,curdir,help
set tags=./tags;
set updatetime=1000

let s:nvim_initpath = expand('~/AppData/Local/nvim/init.vim')
if !has('nvim') && has('win32') && !filereadable(s:nvim_initpath)
	" This is the same as stdpath('config') in nvim.
	call mkdir(fnamemodify(s:nvim_initpath, ':h'), 'p')
	call writefile(['silent! source ~/.vimrc'], s:nvim_initpath)
endif

set packpath=
set runtimepath=$VIMRUNTIME

if isdirectory($VIMRC_DOTVIM)
	set runtimepath+=$VIMRC_DOTVIM

	let g:vim_indent_cont = &g:shiftwidth
	let g:plug_url_format = 'https://github.com/%s.git'

	call plug#begin(expand('$VIMRC_DOTVIM/pack/my/start'))

	call plug#('KabbAmine/yowish.vim')
	call plug#('kana/vim-operator-replace')
	call plug#('kana/vim-operator-user')
	call plug#('rbtnn/vim-find')
	call plug#('rbtnn/vim-gloaded')
	call plug#('rbtnn/vim-mrw')
	call plug#('rbtnn/vim-vimscript_indentexpr')
	call plug#('rbtnn/vim-vimscript_lasterror')
	call plug#('rbtnn/vim-vimscript_tagfunc')
	call plug#('thinca/vim-qfreplace')

	if has('win32')
		call plug#('rbtnn/vim-grizzly')
		call plug#('rbtnn/vimtweak')
		if !has('nvim')
			call plug#('tyru/restart.vim')
		endif
	endif

	if executable('cargo')
		call plug#('rust-lang/rust.vim')
	endif

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
		autocmd CmdlineEnter     *
			\ : for s:cmdname in [
			\		'MANPAGER', 'VimFoldh', 'VimTweakDisableCaption', 'VimTweakDisableMaximize',
			\		'VimTweakDisableTopMost', 'VimTweakEnableCaption', 'VimTweakEnableMaximize',
			\		'VimTweakEnableTopMost', 'Plug', 'PlugDiff', 'PlugInstall', 'PlugSnapshot',
			\		'PlugStatus', 'PlugUpgrade',
			\		'Cbench', 'Cbuild', 'Ccheck', 'Cclean', 'Cdoc',
			\		'Cinit', 'Cinstall', 'Cnew', 'Cpublish', 'Crun',
			\		'Cruntarget', 'Csearch', 'Ctest', 'Cupdate',
			\		]
			\ | 	execute printf('silent! delcommand %s', s:cmdname)
			\ | endfor
		autocmd FileType     help :setlocal colorcolumn=78
		if s:is_installed('yowish.vim')
			autocmd ColorScheme      *
				\ : highlight!       TabLine          guifg=#d6d6d6 guibg=NONE    gui=NONE           cterm=NONE
				\ | highlight!       TabLineFill      guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
				\ | highlight!       TabLineSel       guifg=#a9dd9d guibg=NONE    gui=NONE           cterm=NONE
				\ | highlight!       Pmenu            guifg=#d6d6d6 guibg=NONE
				\ | highlight!       PmenuSel         guifg=#a9dd9d guibg=NONE    gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
				\ | highlight!       PmenuSbar        guifg=#000000 guibg=#202020 gui=NONE
				\ | highlight!       PmenuThumb       guifg=#000000 guibg=#606060 gui=NONE
				\ | highlight! link  diffAdded        String
				\ | highlight! link  diffRemoved      Constant
				\ | highlight!       CursorIM         guifg=NONE    guibg=#ff00ff
		endif
	augroup END

	if s:is_installed('vim-gloaded')
		source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim
	endif

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

	if s:is_installed('yowish.vim')
		silent! colorscheme yowish
	endif
else
	filetype indent plugin on
	syntax on
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

" I use Ctrl-u and Ctrl-d to scroll. Others are disabled.
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

if has('tabsidebar')
	function! Tabsidebar() abort
		let xs = ['%#TabSideBar#' .. '--- ' .. g:actual_curtabpage .. ' ---' .. '%#TabSideBar#']
		for x in filter(getwininfo(), { i, x -> g:actual_curtabpage == x['tabnr']})
			let ft = getbufvar(x['bufnr'], '&filetype')
			let bt = getbufvar(x['bufnr'], '&buftype')
			let text = bufname(x['bufnr'])
			let m = v:true
			let r = v:true
			if ft == 'help'
				let text = '[help]'
				let m = v:false
				let r = v:false
			elseif filereadable(text)
				let text = fnamemodify(text, ':t')
			elseif x['terminal']
				let text = '[Terminal]'
				let m = v:false
				let r = v:false
			elseif x['quickfix']
				let text = '[Quickfix]'
			elseif x['loclist']
				let text = '[Loclist]'
			elseif bt == 'nofile'
				if !empty(ft)
					let text = printf('[%s]', ft)
					let m = v:false
					let r = v:false
				else
					let text = '[Scratch]'
				endif
			elseif empty(text)
				let text = '[No Name]'
			endif
			let xs += [
				\ (x['winid'] == win_getid() ? '%#TabSideBarSel#' : '%#TabSideBar#')
				\ .. ' ' .. text .. ' '
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

