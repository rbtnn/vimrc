set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_VIM = expand('$VIMRC_ROOT/vim')
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
if isdirectory($VIMRC_VIM)
	" https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
	if has('nvim')
		let $VIMRC_UNDO = expand('$VIMRC_VIM/undofiles/neovim')
	else
		let $VIMRC_UNDO = expand('$VIMRC_VIM/undofiles/vim')
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
if has('win32')
	set title
	set titlestring&
else
	set notitle
endif

" tabsidebar
if has('tabsidebar')
	function! Tabsidebar() abort
		try
			let xs = ['', '%#Label#' .. '--- ' .. g:actual_curtabpage .. ' ---' .. '%#TabSideBar#']
			for x in filter(getwininfo(), { i, x -> g:actual_curtabpage == x['tabnr']})
				let ft = getbufvar(x['bufnr'], '&filetype')
				let bt = getbufvar(x['bufnr'], '&buftype')
				let mo = getbufvar(x['bufnr'], '&modified')
				let re = getbufvar(x['bufnr'], '&readonly')
				let name = (!empty(bt)
					\ ? printf('[%s]', bt == 'nofile' ? ft : bt)
					\ : (empty(bufname(x['bufnr'])) ? '[No Name]' : fnamemodify(bufname(x['bufnr']), ':t')))
				let is_curwin = (g:actual_curtabpage == tabpagenr()) && (x['winnr'] == winnr())
				let is_altwin = (g:actual_curtabpage == tabpagenr()) && (x['winnr'] == winnr('#'))
				let text =
					\ (is_curwin
					\   ? '%#TabSideBarSel#(%%)'
					\   : (is_altwin
					\       ? '%#PreProc#(#)'
					\       : ('%#TabSideBar#(' .. x['winnr'] .. ')')))
					\ .. ' '
					\ .. name
					\ .. '%#Comment#'
					\ .. (empty(bt) && mo ? '[+]' : '')
					\ .. (empty(bt) && re ? '[RO]' : '')
				let xs += [text]
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
	set tabsidebarcolumns=20
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
	source $VIMRC_VIM/pack/my/start/vim-gloaded/plugin/gloaded.vim
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
			let args = [['select', qfprediction#get()], ['cnext', qfprediction#get(1)], ['cprev', qfprediction#get(-1)]]
			for i in range(0, len(args) - 1)
				let label = args[i][0]
				let x = args[i][1]
				if has_key(x, 'tabnr') && has_key(x, 'winnr')
					if tabpagenr() == x['tabnr']
						let args[i] = printf('%s:win(%d)', label, x['winnr'])
					else
						let args[i] = printf('%s:win(%d) of tab(%d)', label, x['winnr'], x['tabnr'])
					endif
				elseif has_key(x, 'split')
					let args[i] = printf('%s:split', label)
				else
					let args[i] = printf('%s:?', label)
				endif
			endfor
			return '%#Qfprediction#[qfprediction] ' .. join(args, ', ')
		catch
			return string(v:throwpoint) .. string(v:exception)
		endtry
	endfunction
	set showtabline=2
	set tabline=%!TabLine()
	autocmd vimrc WinEnter * :redrawtabline
endif

if s:is_installed('yowish.vim')
	autocmd vimrc ColorScheme      *
		\ : highlight!       TabSideBar       guifg=#d6d6d6 guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       TabSideBarFill   guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       TabSideBarSel    guifg=#a9dd9d guibg=NONE    gui=NONE           cterm=NONE
		\ | highlight!       Pmenu            guifg=#d6d6d6 guibg=NONE
		\ | highlight!       PmenuSel         guifg=#a9dd9d guibg=NONE    gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE
		\ | highlight!       PmenuSbar        guifg=#000000 guibg=#202020 gui=NONE
		\ | highlight!       PmenuThumb       guifg=#000000 guibg=#606060 gui=NONE
		\ | highlight! link  Qfprediction     StatusLineNC
		\ | highlight! link  diffAdded        String
		\ | highlight! link  diffRemoved      Constant
		\ | highlight!       CursorIM         guifg=NONE    guibg=#ff00ff
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

