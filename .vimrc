set makeencoding=char
scriptencoding utf-8

" https://github.com/vim/vim/commit/957cf67d50516ba98716f59c9e1cb6412ec1535d
let s:vimpatch_cmdtag = has('patch-8.2.1978') || has('nvim')
" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
let s:vimpatch_unsigned = has('patch-8.2.0860') || has('nvim')

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_VIM = expand('$VIMRC_ROOT/vim')
let $VIMRC_PACKSTART = expand('$VIMRC_VIM/pack/my/start')
" https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
if has('nvim')
	let $VIMRC_UNDO = expand('$VIMRC_VIM/undofiles/neovim')
else
	let $VIMRC_UNDO = expand('$VIMRC_VIM/undofiles/vim')
endif

augroup vimrc
	autocmd!
augroup END

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
let g:vim_indent_cont = &g:shiftwidth

" cmdline
set cmdwinheight=5
set cmdheight=1

" backup/swap
set nobackup
set nowritebackup
set noswapfile

" title
if has('win32')
	set title
	set titlestring&
else
	set notitle
endif

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

" ruler
set noruler
set rulerformat&

" statusline
set laststatus=0
set statusline&

" undo
if isdirectory($VIMRC_VIM)
	set undofile
	set undodir=$VIMRC_UNDO//
	silent! call mkdir($VIMRC_UNDO, 'p')
else
	set noundofile
endif

" others
set autoread
set fileformats=unix,dos
set keywordprg=:help
set nowrap
set nrformats&
if s:vimpatch_unsigned
	set nrformats+=unsigned
endif
set scrolloff=5
set sessionoptions=winpos,resize,tabpages,curdir,help
set showmode
set tags=./tags;
set updatetime=100

" tabline/tabsidebar
function! Tabpages(is_tabsidebar) abort
	try
		let hl_lbl = a:is_tabsidebar ? '%#Label#' : ''
		let hl_sel = a:is_tabsidebar ? '%#TabSideBarSel#' : '%#TabLineSel#'
		let hl_def = a:is_tabsidebar ? '%#TabSideBar#' : '%#TabLine#'
		let hl_fil = a:is_tabsidebar ? '%#TabSideBarFill#' : '%#TabLineFill#'
		let hl_alt = a:is_tabsidebar ? '%#PreProc#' : ''
		let lines = []
		for tnr in range(1, tabpagenr('$'))
			if a:is_tabsidebar && (tnr != get(g:, 'actual_curtabpage', tabpagenr()))
				continue
			endif
			if a:is_tabsidebar
				let lines += ['', hl_lbl .. '--- ' .. tnr .. ' ---' .. hl_def]
			else
				let lines += [(tnr == tabpagenr() ? hl_sel : hl_def) .. '<Tab.' .. tnr .. '> ']
			endif
			for x in filter(getwininfo(), { i, x -> tnr == x['tabnr']})
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
		if !a:is_tabsidebar
			let lines += [hl_fil]
		endif
		return join(lines, a:is_tabsidebar ? "\n" : ' ')
	catch
		let g:tab_throwpoint = v:throwpoint
		let g:tab_exception = v:exception
		return 'Error! Please see g:tab_throwpoint and g:tab_exception.'
	endtry
endfunction

if has('tabsidebar')
	let g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!Tabpages(v:true)
	set tabsidebarcolumns=20
	set showtabline=0
	set tabline&
else
	set showtabline=2
	set tabline=%!Tabpages(v:false)
endif

" for Neovim
if has('nvim')
	if has('win32')
		" Running nvim-qt.exe on Windows OS, never use GUI popupmenu and tabline.
		call rpcnotify(0, 'Gui', 'Option', 'Popupmenu', 0)
		call rpcnotify(0, 'Gui', 'Option', 'Tabline', 0)
	endif
	set pumblend=20
else
	if has('win32')
		" This is the same as stdpath('config') in nvim on Windows OS.
		let s:nvim_initpath = expand('~/AppData/Local/nvim/init.vim')
		if !filereadable(s:nvim_initpath)
			call mkdir(fnamemodify(s:nvim_initpath, ':h'), 'p')
			call writefile(['silent! source ~/.vimrc'], s:nvim_initpath)
		endif
	endif
endif

let s:plugvim_path = expand('$VIMRC_VIM/autoload/plug.vim')
if !filereadable(s:plugvim_path) && executable('curl') && has('vim_starting')
	call system(printf('curl -o "%s" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', s:plugvim_path))
endif
if filereadable(s:plugvim_path)
	set runtimepath=$VIMRUNTIME,$VIMRC_VIM
	set packpath=
	let g:plug_url_format = 'https://github.com/%s.git'
	call plug#begin($VIMRC_PACKSTART)
	call plug#('KabbAmine/yowish.vim')
	call plug#('kana/vim-operator-replace')
	call plug#('kana/vim-operator-user')
	call plug#('rbtnn/vim-find')
	call plug#('rbtnn/vim-gloaded')
	call plug#('rbtnn/vim-mrw')
	call plug#('rbtnn/vim-qfprediction')
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
	silent! source ~/.vimrc.local
	call plug#end()
else
	set runtimepath=$VIMRUNTIME
	set packpath=$VIMRC_VIM
	silent! source ~/.vimrc.local
	packloadall!
	filetype indent plugin on
	syntax on
endif

" Delete unused commands, because it's an obstacle on cmdline-completion.
autocmd vimrc CmdlineEnter     *
	\ : for s:cmdname in [
	\		'MANPAGER', 'VimFoldh', 'VimTweakDisableCaption', 'VimTweakDisableMaximize',
	\		'VimTweakDisableTopMost', 'VimTweakEnableCaption', 'VimTweakEnableMaximize',
	\		'VimTweakEnableTopMost', 'Plug', 'PlugDiff', 'PlugInstall', 'PlugSnapshot',
	\		'PlugStatus', 'PlugUpgrade',
	\		]
	\ | 	execute printf('silent! delcommand %s', s:cmdname)
	\ | endfor

autocmd vimrc FileType     help :setlocal colorcolumn=78

if !has('nvim') && has('win32') && (&shell =~# '\<cmd\.exe$')
	let s:initcmd_path = get(s:, 'initcmd_path', tempname() .. '.cmd')
	function! s:term_win_open() abort
		" https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc725943(v=ws.11)
		" https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
		call writefile(map([
			\	'@echo off', 'cls',
			\	(windowsversion() == '10.0' ? 'prompt $e[0;32m$$$e[0m' : 'prompt $$'),
			\	'doskey ls=dir /b $*',
			\	'doskey rm=del /q $*',
			\	'doskey mv=move /y $*',
			\	'doskey cp=copy /y $*',
			\	'doskey pwd=cd',
			\ ], { i,x -> x .. "\r" }), s:initcmd_path)
		call term_sendkeys(bufnr(), printf("call %s\r", s:initcmd_path))
	endfunction
	autocmd vimrc TerminalWinOpen     * :silent! call s:term_win_open()
	autocmd vimrc VimLeave            * :silent! call delete(s:initcmd_path)
endif

if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
	set termguicolors
endif

function! s:is_installed(name) abort
	return isdirectory($VIMRC_PACKSTART .. '/' .. a:name)
endfunction

if s:is_installed('vim-gloaded')
	source $VIMRC_PACKSTART/vim-gloaded/plugin/gloaded.vim
endif

if s:is_installed('vim-grizzly')
	if !has('nvim') && has('win32') && (&shell =~# '\<cmd\.exe$')
		let g:grizzly_prompt_pattern = '^$\zs.*'
	endif
endif

if s:is_installed('vim-find')
	if s:vimpatch_cmdtag
		nnoremap <silent><nowait><space>         <Cmd>FindFiles<cr>
	else
		nnoremap <silent><nowait><space>         :<C-u>FindFiles<cr>
	endif
endif

if s:is_installed('vim-operator-replace')
	nmap     <silent><nowait>s               <Plug>(operator-replace)
endif

if s:is_installed('restart.vim')
	let g:restart_sessionoptions = &sessionoptions
endif

if s:is_installed('vimtweak')
	if has('gui_running') && has('win32')
		autocmd vimrc VimEnter     * :VimTweakSetAlpha 240
	endif
endif

if s:is_installed('vim-qfprediction')
	function! StatusLine() abort
		try
			let twnr = win_id2tabwin(g:statusline_winid)
			let bnr = winbufnr(g:statusline_winid)
			let bt = getbufvar(bnr, '&buftype')
			let qf_labels = []
			for x in [
				\ ['[qf-sel]', qfprediction#get()],
				\ ['[qf-cnext]', qfprediction#get(1)],
				\ ['[qf-cprev]', qfprediction#get(-1)],
				\ ]
				if get(x[1], 'tabnr', -1) == twnr[0] && get(x[1], 'winnr', -1) == twnr[1]
					let qf_labels += [x[0]]
				endif
			endfor
			let s = ''
			if empty(bt)
				let ff = getbufvar(bnr, '&fileformat')
				let ft = getbufvar(bnr, '&filetype')
				let fe = getbufvar(bnr, '&fileencoding')
				let f = join(filter([ft, ff, fe], { i,x -> !empty(x) }), '/')
				let s = '%m%r' .. (empty(f) ? '' : '[' .. f .. ']')
			endif
			return '%t ' .. s .. join(qf_labels, '')
		catch
			let g:st_throwpoint = v:throwpoint
			let g:st_exception = v:exception
			return 'Error! Please see g:st_throwpoint and g:st_exception.'
		endtry
	endfunction
	set laststatus=2
	set statusline=%!StatusLine()
	autocmd vimrc QuickfixCmdPost,WinEnter * :redrawstatus!
endif

if s:is_installed('yowish.vim')
	autocmd vimrc ColorScheme      *
		\ : highlight!       TabSideBar      guifg=#d6d6d6 guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       TabSideBarFill  guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       TabSideBarSel   guifg=#a9dd9d guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       Pmenu           guifg=#d6d6d6 guibg=NONE
		\ | highlight!       PmenuSel        guifg=#a9dd9d guibg=NONE    gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		\ | highlight!       PmenuSbar       guifg=#000000 guibg=#202020 gui=NONE
		\ | highlight!       PmenuThumb      guifg=#000000 guibg=#606060 gui=NONE
		\ | highlight! link  diffAdded       String
		\ | highlight! link  diffRemoved     Constant
		\ | highlight!       CursorIM        guifg=NONE    guibg=#ff00ff
	colorscheme yowish
endif

" Emacs key mappings
if has('win32')
	tnoremap <silent><nowait><C-b>       <left>
	tnoremap <silent><nowait><C-f>       <right>
	tnoremap <silent><nowait><C-e>       <end>
	tnoremap <silent><nowait><C-a>       <home>
	tnoremap <silent><nowait><C-u>       <esc>
endif
cnoremap         <nowait><C-b>           <left>
cnoremap         <nowait><C-f>           <right>
cnoremap         <nowait><C-e>           <end>
cnoremap         <nowait><C-a>           <home>

" Enter Command-line window from Command-line.
cnoremap         <nowait><C-q>           <C-f>

" Escape from Terminal mode.
if has('nvim')
	tnoremap <silent><nowait><esc>       <C-\><C-n>
else
	tnoremap <silent><nowait><esc>       <C-w>N
endif

" Move the next/previous error in quickfix.
if s:vimpatch_cmdtag
	nnoremap <silent><nowait><C-n>           <Cmd>cnext<cr>
	nnoremap <silent><nowait><C-p>           <Cmd>cprevious<cr>
else
	nnoremap <silent><nowait><C-n>           :<C-u>cnext<cr>
	nnoremap <silent><nowait><C-p>           :<C-u>cprevious<cr>
endif

" Move the next/previous tabpage.
nnoremap <silent><nowait><C-j>           gt
nnoremap <silent><nowait><C-k>           gT
if s:vimpatch_cmdtag
	tnoremap <silent><nowait><C-j>           <Cmd>tabnext<cr>
	tnoremap <silent><nowait><C-k>           <Cmd>tabprevious<cr>
else
	tnoremap <silent><nowait><C-j>           <C-w>:<C-u>tabnext<cr>
	tnoremap <silent><nowait><C-k>           <C-w>:<C-u>tabprevious<cr>
endif

" Go to the last accessed window.
tnoremap <silent><nowait><C-s>           <C-w>p
nnoremap <silent><nowait><C-s>           <C-w>p

" Smart space on wildmenu
cnoremap   <expr><nowait><space>         (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

" I use Ctrl-u and Ctrl-d to scroll. Others are disabled.
nnoremap <silent><nowait><C-e>           <nop>
nnoremap <silent><nowait><C-y>           <nop>
nnoremap <silent><nowait><C-f>           <nop>
nnoremap <silent><nowait><C-b>           <nop>

