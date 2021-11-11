set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/vim')
let $VIMRC_PACKSTART = expand('$VIMRC_DOTVIM/pack/my/start')

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

" ruler
set ruler
set rulerformat=%16(%{&ft}/%{&ff}/%{&fileencoding}%)

" statusline
set laststatus=0
set statusline&

" tabline
set showtabline=0
set tabline&

" title
function! TitleString(bnr, is_tabsidebar) abort
	let ft = getbufvar(a:bnr, '&filetype')
	let bt = getbufvar(a:bnr, '&buftype')
	let mo = getbufvar(a:bnr, '&modified')
	let re = getbufvar(a:bnr, '&readonly')
	let name = bufname(a:bnr)
	return (a:is_tabsidebar ? '%#TabSideBar#' : '')
		\ .. (!empty(bt)
		\          ? printf('[%s]', bt == 'nofile' ? ft : bt)
		\          : (empty(name) ? '[No Name]' : fnamemodify(name, a:is_tabsidebar ? ':t' : ':p'))
		\    )
		\ .. (a:is_tabsidebar ? '%#Comment#'    : '') .. (empty(bt) && mo ? '[+]' : '')
		\ .. (a:is_tabsidebar ? '%#Comment#'    : '') .. (empty(bt) && re ? '[RO]' : '')
endfunction

if has('win32')
	set title
	set titlestring=%{TitleString(bufnr(),v:false)}
else
	set notitle
endif

" tabsidebar
if has('tabsidebar')
	function! Tabsidebar() abort
		try
			let xs = ['', '%#Label#' .. '--- ' .. g:actual_curtabpage .. ' ---' .. '%#TabSideBar#']
			for x in filter(getwininfo(), { i, x -> g:actual_curtabpage == x['tabnr']})
				let curr = g:actual_curtabpage == tabpagenr()
				let xs += [
					\ ' '
					\ .. '%#TabSideBarSel#' .. (curr && x['winnr'] == winnr() ? '%%' : ' ')
					\ .. '%#Preproc#' .. (curr && x['winnr'] == winnr('#') ? '#' : ' ')
					\ .. ' '
					\ .. TitleString(x['bufnr'], v:true)
					\ ]
			endfor
			return join(xs, "\n")
		catch
			return v:exception
		endtry
	endfunction
	let g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!Tabsidebar()
	set tabsidebarcolumns=16
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

" others
set autoread
set fileformats=unix,dos
set keywordprg=:help
set nowrap
set nrformats=unsigned
set scrolloff=5
set sessionoptions=winpos,resize,tabpages,curdir,help
set showmode
set tags=./tags;
set updatetime=100

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

let s:plugvim_path = expand('$VIMRC_DOTVIM/autoload/plug.vim')
if !filereadable(s:plugvim_path) && executable('curl') && has('vim_starting')
	call system(printf('curl -o "%s" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', s:plugvim_path))
endif
if filereadable(s:plugvim_path)
	set runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM
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
	set packpath=$VIMRC_DOTVIM
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
	source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim
endif

if s:is_installed('vim-grizzly')
	if !has('nvim') && has('win32') && (&shell =~# '\<cmd\.exe$')
		let g:grizzly_prompt_pattern = '^$\zs.*'
	endif
endif

if s:is_installed('vim-find')
	nnoremap <silent><nowait><space>         <Cmd>FindFiles<cr>
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
	function! TabLine() abort
		try
			let x = qfprediction#get()
			let debug_msg = get(x, 'debug', '')
			if !empty(debug_msg)
				let debug_msg = ':' .. debug_msg
			endif
			if has_key(x, 'tabnr') && has_key(x, 'winnr')
				return printf('[qfprediction%s] Will open a file of the error at the window of tabnr:%d and winnr:%d.', debug_msg, x['tabnr'], x['winnr'])
			elseif has_key(x, 'split')
				return printf('[qfprediction%s] Will open a file of the error at new window.', debug_msg)
			else
				return printf('[qfprediction%s] Could not predict a window!', debug_msg)
			endif
		catch
			return string(v:throwpoint) .. string(v:exception)
		endtry
	endfunction
	set showtabline=2
	set tabline=%!TabLine()
	autocmd vimrc WinEnter * :redrawtabline
endif

autocmd vimrc WinEnter * :redrawtabline
if s:is_installed('yowish.vim')
	autocmd vimrc ColorScheme      *
		\ : highlight!       TabSideBar       guifg=#d6d6d6 guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       TabSideBarFill   guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       TabSideBarSel    guifg=#a9dd9d guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       Pmenu            guifg=#d6d6d6 guibg=NONE
		\ | highlight!       PmenuSel         guifg=#a9dd9d guibg=NONE    gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		\ | highlight!       PmenuSbar        guifg=#000000 guibg=#202020 gui=NONE
		\ | highlight!       PmenuThumb       guifg=#000000 guibg=#606060 gui=NONE
		\ | highlight! link  TabLine          StatusLine
		\ | highlight! link  TabLineSel       StatusLine
		\ | highlight! link  TabLineFill      StatusLine
		\ | highlight! link  diffAdded        String
		\ | highlight! link  diffRemoved      Constant
		\ | highlight!       CursorIM         guifg=NONE    guibg=#ff00ff
	silent! colorscheme yowish
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
nnoremap <silent><nowait><C-n>           <Cmd>cnext<cr>
nnoremap <silent><nowait><C-p>           <Cmd>cprevious<cr>

" Move the next/previous tabpage.
nnoremap <silent><nowait><C-j>           <Cmd>tabnext<cr>
nnoremap <silent><nowait><C-k>           <Cmd>tabprevious<cr>
tnoremap <silent><nowait><C-j>           <Cmd>tabnext<cr>
tnoremap <silent><nowait><C-k>           <Cmd>tabprevious<cr>

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

