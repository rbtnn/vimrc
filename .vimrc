
if &compatible
	set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

" https://github.com/vim/vim/commit/957cf67d50516ba98716f59c9e1cb6412ec1535d
let s:vimpatch_cmdtag = has('patch-8.2.1978') || has('nvim')
" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
let s:vimpatch_unsigned = has('patch-8.2.0860') || has('nvim')
" https://github.com/vim/vim/commit/3908ef5017a6b4425727013588f72cc7343199b9
let s:vimpatch_cmdlinepum = has('patch-8.2.4325') || has('nvim')

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')
let $VIMRC_DEV = expand('$VIMRC_VIM/dev')

augroup vimrc
	autocmd!
	" Delete unused commands, because it's an obstacle on cmdline-completion.
	autocmd CmdlineEnter     *
		\ : for s:cmdname in ['MANPAGER', 'Man', 'Tutor', 'VimFoldh', 'TextobjStringDefaultKeyMappings', 'UpdateRemotePlugins']
		\ | 	execute printf('silent! delcommand %s', s:cmdname)
		\ | endfor
		\ | unlet s:cmdname
	autocmd FileType     help :setlocal colorcolumn=78
augroup END

language messages C
set winaltkeys=yes
set guioptions=mM
set mouse=a
set belloff=all
set clipboard=unnamed

set autoread
set cmdheight=3
set cmdwinheight=5
set complete-=t
set completeslash=slash
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set ignorecase
set incsearch
set isfname-==
set keywordprg=:help
set list
set listchars=tab:\ \ \|,trail:-
set matchpairs+=<:>
set matchtime=1
set nobackup
set nonumber
set norelativenumber
set noruler
set noshowcmd
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats&
set pumheight=10
set rulerformat&
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set shiftwidth=4
set showmatch
set showmode
set softtabstop=-1
set tabstop=4
set tags=./tags;
set updatetime&
set wildmenu

if s:vimpatch_cmdlinepum
	set wildoptions=pum
endif

if s:vimpatch_unsigned
	set nrformats-=octal
	set nrformats+=unsigned
endif

if has('vim_starting')
	set hlsearch
	set laststatus=2
	set statusline&
endif

if has('persistent_undo')
	set undofile
	" https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
	if has('nvim')
		let &undodir = expand('$VIMRC_VIM/undofiles/neovim')
	else
		let &undodir = expand('$VIMRC_VIM/undofiles/vim')
	endif
	silent! call mkdir(&undodir, 'p')
else
	set noundofile
endif

if has('tabsidebar')
	function! TabSideBar() abort
		try
			let hl_lbl = '%#Label#'
			let hl_sel = '%#TabSideBarSel#'
			let hl_def = '%#TabSideBar#'
			let hl_fil = '%#TabSideBarFill#'
			let hl_alt = hl_def
			let lines = []
			for tnr in range(1, tabpagenr('$'))
				if tnr != get(g:, 'actual_curtabpage', tabpagenr())
					continue
				endif
				let lines += ['', printf('%s--- Tab %d ---%s', hl_lbl, tnr, hl_def)]
				for x in filter(getwininfo(), { i, x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid'])) })
					let ft = getbufvar(x['bufnr'], '&filetype')
					let bt = getbufvar(x['bufnr'], '&buftype')
					let is_curwin = (tnr == tabpagenr()) && (x['winnr'] == winnr())
					let is_altwin = (tnr == tabpagenr()) && (x['winnr'] == winnr('#'))
					let text =
						\ (is_curwin
						\   ? hl_sel .. '(%%)'
						\   : (is_altwin
						\       ? hl_alt .. '(#)'
						\       : (hl_def .. '(' .. x['winnr'] .. ')')))
						\ .. ' '
						\ .. (!empty(bt)
						\      ? printf('[%s]', bt == 'nofile' ? ft : bt)
						\      : (empty(bufname(x['bufnr']))
						\          ? '[No Name]'
						\          : fnamemodify(bufname(x['bufnr']), ':t')))
					let lines += [text]
				endfor
			endfor
			return join(lines, "\n")
		catch
			let g:tab_throwpoint = v:throwpoint
			let g:tab_exception = v:exception
			return 'Error! Please see g:tab_throwpoint and g:tab_exception.'
		endtry
	endfunction
	let g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!TabSideBar()
	set tabsidebarcolumns=20
	set showtabline=0
	set tabline&
else
	set showtabline=2
	set tabline&
endif

if has('nvim')
	if has('win32')
		" Running nvim-qt.exe on Windows OS, never use GUI popupmenu and tabline.
		if has('vim_starting')
			call rpcnotify(0, 'Gui', 'Option', 'Popupmenu', 0)
			call rpcnotify(0, 'Gui', 'Option', 'Tabline', 0)
		endif
	endif
else
	if has('win32')
		" This is the same as stdpath('config') in nvim on Windows OS.
		let s:nvim_initpath = expand('~/AppData/Local/nvim/init.vim')
		if !filereadable(s:nvim_initpath)
			silent! call mkdir(fnamemodify(s:nvim_initpath, ':h'), 'p')
			call writefile(['silent! source ~/.vimrc'], s:nvim_initpath)
		endif
	endif
endif

if has('vim_starting') && has('termguicolors') && !has('gui_running') && (has('win32') || (256 == &t_Co))
	silent! set termguicolors
endif

let &cedit = "\<C-q>"
let g:vim_indent_cont = &g:shiftwidth

if has('vim_starting')
	set packpath=$VIMRC_VIM
	set runtimepath=$VIMRUNTIME,$VIMRC_DEV
	silent! source ~/.vimrc.local
	filetype plugin indent on
	syntax enable
endif

" Can't use <S-space> at :terminal
" https://github.com/vim/vim/issues/6040
tnoremap <silent><S-space>           <space>

" Smart space on wildmenu
cnoremap   <expr><space>             (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

" Escape from Terminal mode.
if has('nvim')
	tnoremap <silent><C-w>N          <C-\><C-n>
endif

nnoremap         <space>g        :<C-u>GitGrep<space>
nnoremap <silent><space>d        :<C-u>GitDiff<cr>
nnoremap         <space>r        :<C-u>GitGotoRootDir<cr>

" Emacs key mappings
if has('win32') && (&shell =~# '\<cmd\.exe$')
	tnoremap <silent><C-p>           <up>
	tnoremap <silent><C-n>           <down>
	tnoremap <silent><C-b>           <left>
	tnoremap <silent><C-f>           <right>
	tnoremap <silent><C-e>           <end>
	tnoremap <silent><C-a>           <home>
	tnoremap <silent><C-u>           <esc>
endif
cnoremap         <C-b>               <left>
cnoremap         <C-f>               <right>
cnoremap         <C-e>               <end>
cnoremap         <C-a>               <home>

if s:vimpatch_cmdtag
	if has('nvim')
		nnoremap <silent><space>t    <Cmd>new \| execute 'terminal' \| startinsert<cr>
	else
		nnoremap <silent><space>t    <Cmd>new \| terminal ++curwin<cr>
	endif

	" Move the next/previous tabpage.
	tnoremap <silent><C-j>           <Cmd>tabnext<cr>
	tnoremap <silent><C-k>           <Cmd>tabprevious<cr>
	nnoremap <silent><C-j>           <Cmd>tabnext<cr>
	nnoremap <silent><C-k>           <Cmd>tabprevious<cr>

	" Move the next/previous error in quickfix.
	nnoremap <silent><C-n>           <Cmd>cnext<cr>
	nnoremap <silent><C-p>           <Cmd>cprevious<cr>
endif

if !empty(globpath($VIMRC_VIM, 'pack/rbtnn/*/vim-gloaded'))
	source $VIMRC_VIM/pack/rbtnn/start/vim-gloaded/plugin/gloaded.vim
endif

if !empty(globpath($VIMRC_VIM, 'pack/cocopon/*/vaffle.vim'))
	let g:vaffle_show_hidden_files = 1
	nnoremap <silent><space>f       :<C-u>execute 'Vaffle ' .. (filereadable(expand('%')) ? '%:h' : '.')<cr>
endif

if !empty(globpath($VIMRC_VIM, 'pack/rbtnn/*/vim-mrw'))
	let g:mrw_limit = 100
	nnoremap <silent><space>s       :<C-u>MRW<cr>
endif

if !empty(globpath($VIMRC_VIM, 'pack/rbtnn/*/vim-diffnotify'))
	call diffnotify#styles#tabline()
	let g:diffnotify_threshold = 0
	let g:diffnotify_timespan = 1000
endif

if !empty(globpath($VIMRC_VIM, 'pack/bluz71/*/vim-moonfly-colors'))
	if !empty(globpath($VIMRC_VIM, 'pack/itchyny/*/lightline.vim'))
		let g:lightline = {}
		let g:lightline['colorscheme'] = 'moonfly'
		let g:lightline['enable'] = { 'statusline': 1, 'tabline': 0, }
		let g:lightline['separator'] = { 'left': nr2char(0xe0b0), 'right': nr2char(0xe0b2), }
	endif
	if has('vim_starting')
		set background=dark
		autocmd vimrc ColorScheme      *
			\ : highlight!       TabSideBar      guifg=#76787b guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       TabSideBarFill  guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       TabSideBarSel   guifg=#ff80ff guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       Comment         guifg=#313131               gui=NONE           cterm=NONE
			\ | highlight!       CursorIM        guifg=NONE    guibg=#ff0000
			\ | highlight!       SpecialKey      guifg=#1a1a1a
		colorscheme moonfly
	endif
else
	if has('tabsidebar')
		highlight!       TabSideBar                    guibg=NONE    gui=NONE           cterm=NONE
		highlight!       TabSideBarFill                guibg=NONE    gui=NONE           cterm=NONE
		highlight!       TabSideBarSel                 guibg=NONE    gui=NONE           cterm=NONE
	endif
endif

if !empty(globpath($VIMRC_VIM, 'pack/kyoh86/*/vim-ripgrep'))
	command! -nargs=* -complete=file Ripgrep :call ripgrep#search(<q-args>)
endif

if !empty(globpath($VIMRC_VIM, 'pack/kana/*/vim-operator-replace'))
	nmap     <silent>s           <Plug>(operator-replace)
endif

if !empty(globpath($VIMRC_VIM, 'pack/tyru/*/restart.vim'))
	let g:restart_sessionoptions = &sessionoptions
endif

if !has('vim_starting')
	" Check whether echo-messages are not disappeared when .vimrc is read.
	echo '.vimrc has just read!'
endif

