
if &compatible
	set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

" https://github.com/vim/vim/commit/957cf67d50516ba98716f59c9e1cb6412ec1535d
let s:vimpatch_cmdtag = has('patch-8.2.1978') || has('nvim')
" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
let s:vimpatch_unsigned = has('patch-8.2.0860') || has('nvim')

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_VIM = expand('$VIMRC_ROOT/vim')
let $VIMRC_DEV = expand('$VIMRC_VIM/dev')
let $VIMRC_PACKSTART = expand('$VIMRC_VIM/pack/my/start')

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

" display
if has('vim_starting')
	set ambiwidth=double
endif
set nonumber
set norelativenumber
set nowrap
set scrolloff=5

" indent size
set shiftround
set softtabstop=-1
set shiftwidth=4
set tabstop=4
let g:vim_indent_cont = &g:shiftwidth

" cmdline
set cmdwinheight=5
set cmdheight=3
set noshowcmd
let &cedit = "\<C-q>"

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

" others
set autoread
set fileformats=unix,dos
set keywordprg=:help
set nrformats&
if s:vimpatch_unsigned
	set nrformats-=octal
	set nrformats+=unsigned
endif
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
		if has('vim_starting')
			call rpcnotify(0, 'Gui', 'Option', 'Popupmenu', 0)
			call rpcnotify(0, 'Gui', 'Option', 'Tabline', 0)
		endif
	endif
	set pumblend=20
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

let s:plugvim_path = expand('$VIMRC_DEV/autoload/plug.vim')

if !filereadable(s:plugvim_path) && executable('curl') && has('vim_starting')
	silent! call mkdir($VIMRC_PACKSTART, 'p')
	call system(printf('curl -o "%s" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', s:plugvim_path))
endif

if filereadable(s:plugvim_path) && (get(readfile(s:plugvim_path, '', 1), 0, '') != '404: Not Found')
	set runtimepath=$VIMRUNTIME,$VIMRC_DEV
	set packpath=
	let g:plug_url_format = 'https://github.com/%s.git'
	call plug#begin($VIMRC_PACKSTART)
	call plug#('kana/vim-operator-replace')
	call plug#('kana/vim-operator-user')
	call plug#('mattn/vim-molder')
	call plug#('rakr/vim-one')
	call plug#('rbtnn/vim-gloaded')
	call plug#('rbtnn/vim-mrw')
	call plug#('rbtnn/vim-qfpopup')
	call plug#('rbtnn/vim-testing-for-tabsidebar')
	call plug#('rbtnn/vim-vimscript_indentexpr')
	call plug#('rbtnn/vim-vimscript_lasterror')
	call plug#('rbtnn/vim-vimscript_tagfunc')
	call plug#('thinca/vim-qfreplace')
	if !has('nvim') && has('win32')
		call plug#('tyru/restart.vim')
	endif
	silent! source ~/.vimrc.local
	call plug#end()
	function! s:is_installed(name) abort
		return isdirectory($VIMRC_PACKSTART .. '/' .. a:name) && (-1 != index(keys(g:plugs), a:name))
	endfunction
else
	set runtimepath=$VIMRUNTIME,$VIMRC_DEV
	set packpath=$VIMRC_VIM
	silent! source ~/.vimrc.local
	packloadall!
	filetype indent plugin on
	syntax on
	function! s:is_installed(name) abort
		return isdirectory($VIMRC_PACKSTART .. '/' .. a:name)
	endfunction
endif

" Delete unused commands, because it's an obstacle on cmdline-completion.
autocmd vimrc CmdlineEnter     *
	\ : for s:cmdname in [
	\		'MANPAGER', 'Man', 'Tutor', 'VimFoldh',
	\		'Plug', 'PlugDiff', 'PlugInstall', 'PlugSnapshot',
	\		'PlugStatus', 'PlugUpgrade', 'UpdateRemotePlugins',
	\		]
	\ | 	execute printf('silent! delcommand %s', s:cmdname)
	\ | endfor
	\ | unlet s:cmdname

autocmd vimrc FileType     help :setlocal colorcolumn=78

function! s:term_win_open() abort
	if (bufname() =~# '\<cmd\.exe\>') && has('win32')
		" https://en.wikipedia.org/wiki/Windows_10_version_history
		" https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc725943(v=ws.11)
		" https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
		let s:vcvarsall_path = glob('C:\Program Files (x86)\Microsoft Visual Studio\2019\*\VC\Auxiliary\Build\vcvarsall.bat')
		let s:initcmd_path = get(s:, 'initcmd_path', tempname() .. '.cmd')
		let s:windows_build_number = get(s:, 'windows_build_number', -1)
		let s:win10_anniversary_update = get(s:, 'win10_anniversary_update', v:false)
		if executable('wmic') && (-1 == s:windows_build_number)
			let s:windows_build_number = str2nr(join(filter(split(system('wmic os get BuildNumber'), '\zs'), { i,x -> (0x30 <= char2nr(x)) && (char2nr(x) <= 0x39) }), ''))
			let s:win10_anniversary_update = 14393 <= s:windows_build_number
		endif
		call writefile(map([
			\	'@echo off', 'cls',
			\	(s:win10_anniversary_update ? 'prompt $e[0;32m$$$e[0m' : 'prompt $$'),
			\	'doskey vc=call "' .. s:vcvarsall_path .. '" $*',
			\	'doskey ls=dir /b $*',
			\	'doskey rm=del /q $*',
			\	'doskey mv=move /y $*',
			\	'doskey cp=copy /y $*',
			\	'doskey pwd=cd',
			\ ], { i,x -> x .. "\r" }), s:initcmd_path)
		if has('nvim')
			startinsert
			call jobsend(b:terminal_job_id, printf("call %s\r", s:initcmd_path))
		else
			call term_sendkeys(bufnr(), printf("call %s\r", s:initcmd_path))
		endif
	endif
	if bufname() =~# '\<bash\>'
		let cmd = join(['export PS1="\[\e[0;32m\]$\[\e[0m\]"', 'clear', ''], "\r")
		if has('nvim')
			startinsert
			call jobsend(b:terminal_job_id, cmd)
		else
			call term_sendkeys(bufnr(), cmd)
		endif
	endif
endfunction
if has('nvim')
	autocmd vimrc TermOpen           * :silent! call s:term_win_open()
else
	autocmd vimrc TerminalWinOpen    * :silent! call s:term_win_open()
endif
if (bufname() =~# '\<cmd\.exe$') && has('win32')
	autocmd vimrc VimLeave           * :silent! call delete(s:initcmd_path)
endif

function! s:toggle_terminal() abort
	if &buftype == 'terminal'
		setlocal hidden
		close
	else
		let xs = getbufinfo()
		call filter(xs, { i,x -> getbufvar(x['bufnr'], '&buftype') == 'terminal' })
		if !has('nvim')
			call filter(xs, { i,x -> term_getstatus(x['bufnr']) != 'finished' })
		endif
		rightbelow vertical new
		if empty(xs)
			if has('nvim')
				terminal
			else
				terminal ++kill=kill ++curwin
			endif
		else
			execute 'buffer ' .. xs[0]['bufnr']
		endif
		startinsert
	endif
endfunction

tnoremap <C-q> <Cmd>call <SID>toggle_terminal()<cr>
nnoremap <C-q> <Cmd>call <SID>toggle_terminal()<cr>

if has('vim_starting')
	if (has('win32') || (256 == &t_Co)) && has('termguicolors') && !has('gui_running')
		silent! set termguicolors
	endif
endif

if s:is_installed('vim-gloaded')
	source $VIMRC_PACKSTART/vim-gloaded/plugin/gloaded.vim
endif

nnoremap <silent><space>d        :<C-u>GitDiff<cr>
nnoremap         <space>r        :<C-u>GitGotoRootDir<cr>
nnoremap         <space>g        :<C-u>GitGrep<space>

if s:is_installed('vim-mrw')
	nnoremap <silent><space>s       :<C-u>MRW<cr>
endif

if s:is_installed('vim-molder')
	let g:molder_show_hidden = 1
	nnoremap <silent><space>f       :<C-u>execute 'e ' .. (filereadable(expand('%')) ? '%:h' : '.')<cr>
	function! s:init_molder() abort
		nmap <buffer>h           <plug>(molder-up)
		nmap <buffer>l           <plug>(molder-open)
	endfunction
	autocmd vimrc FileType      molder  :call s:init_molder()
endif

if s:is_installed('vim-one')
	if has('vim_starting')
		set background=dark
		autocmd vimrc ColorScheme      *
			\ : highlight!       TabSideBar      guifg=#76787b guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       TabSideBarFill  guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       TabSideBarSel   guifg=#22863a guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       Cursor          guifg=NONE    guibg=#aaaaaa
			\ | highlight!       CursorIM        guifg=NONE    guibg=#aa0000
			\ | highlight!       Comment                                     gui=NONE           cterm=NONE
			\ | highlight!       DiffLine                      guibg=NONE
			\ | highlight!       DiffFile                      guibg=NONE
			\ | highlight!       DiffNewFile                   guibg=NONE
			\ | highlight!       DiffAdded                     guibg=NONE
			\ | highlight!       DiffRemoved                   guibg=NONE
			\ | highlight!       Terminal        guifg=#eeeeee guibg=#000000
		if &background == 'dark'
			autocmd vimrc ColorScheme      *
				\ : highlight!       SpecialKey      guifg=#383c44
		else
			autocmd vimrc ColorScheme      *
				\ : highlight!       SpecialKey      guifg=#eeeeee
		endif
		colorscheme one
	endif
endif

if s:is_installed('vim-operator-replace')
	nmap     <silent>s           <Plug>(operator-replace)
endif

if s:is_installed('restart.vim')
	let g:restart_sessionoptions = &sessionoptions
endif

if s:is_installed('denops.vim')
	command! -nargs=0 DenoRestart
		\ : let g:denops#debug = 1
		\ | call denops#server#restart()
endif

" Emacs key mappings
if has('win32') && (&shell =~# '\<cmd\.exe$')
	tnoremap <silent><C-p>       <up>
	tnoremap <silent><C-n>       <down>
	tnoremap <silent><C-b>       <left>
	tnoremap <silent><C-f>       <right>
	tnoremap <silent><C-e>       <end>
	tnoremap <silent><C-a>       <home>
	tnoremap <silent><C-u>       <esc>
endif
cnoremap         <C-b>           <left>
cnoremap         <C-f>           <right>
cnoremap         <C-e>           <end>
cnoremap         <C-a>           <home>

" Escape from Terminal mode.
if has('nvim')
	tnoremap <silent><C-w>N      <C-\><C-n>
endif

" Can't use <S-space> at :terminal
" https://github.com/vim/vim/issues/6040
tnoremap <silent><S-space>       <space>

" Move the next/previous tabpage.
if s:vimpatch_cmdtag
	tnoremap <silent>gt          <Cmd>tabnext<cr>
	tnoremap <silent>gT          <Cmd>tabprevious<cr>
endif

" Move the next/previous error in quickfix.
nnoremap <silent><C-j>           :<C-u>cnext<cr>
nnoremap <silent><C-k>           :<C-u>cprevious<cr>

" Smart space on wildmenu
cnoremap   <expr><space>         (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

" Save script variables for debugging purposes.
let g:vimrc_scriptvars = s:

if !has('vim_starting')
	" Check whether echo-messages are not disappeared when .vimrc is read.
	echo '.vimrc has just read!'
endif

