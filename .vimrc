
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

augroup vimrc
	autocmd!
	" Delete unused commands, because it's an obstacle on cmdline-completion.
	autocmd CmdlineEnter     *
		\ : for s:cmdname in [
		\   'MANPAGER', 'Man', 'Tutor', 'VimFoldh', 'TextobjStringDefaultKeyMappings',
		\   'UpdateRemotePlugins', 'TextobjVimfunctionnameDefaultKeyMappings',
		\   'VimTweakDisableCaption', 'VimTweakDisableMaximize', 'VimTweakDisableTopMost',
		\   'VimTweakEnableCaption', 'VimTweakEnableMaximize', 'VimTweakEnableTopMost',
		\ ]
		\ |     execute printf('silent! delcommand %s', s:cmdname)
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
set cmdheight=1
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
set list listchars=tab:<->,trail:-
set matchpairs+=<:>
set matchtime=1
set nobackup
set nonumber
set norelativenumber
set noshowmode
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats&
set pumheight=10
set ruler
set rulerformat&
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set shiftwidth=4
set showcmd
set showmatch
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

if executable('rg')
	command! -nargs=0 GrepSettingsRg
		\ :set grepformat=%f:%l:%c:%m
		\ |let &grepprg = 'rg --vimgrep --glob "!.git" --glob "!.svn" --glob "!node_modules" -uu'
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

let &cedit = "\<C-q>"
let g:vim_indent_cont = &g:shiftwidth

if has('vim_starting')
	set hlsearch
	set laststatus=2
	set statusline&
	set showtabline=0
	set tabline&

	if has('win32')
		if has('nvim')
			" Running nvim-qt.exe on Windows OS, never use GUI popupmenu and tabline.
			call rpcnotify(0, 'Gui', 'Option', 'Popupmenu', 0)
			call rpcnotify(0, 'Gui', 'Option', 'Tabline', 0)
		else
			" This is the same as stdpath('config') in nvim on Windows OS.
			let s:nvim_initpath = expand('~/AppData/Local/nvim/init.vim')
			if !filereadable(s:nvim_initpath)
				silent! call mkdir(fnamemodify(s:nvim_initpath, ':h'), 'p')
				call writefile(['silent! source ~/.vimrc'], s:nvim_initpath)
			endif
		endif
	endif

	set packpath=$VIMRC_VIM/local,$VIMRC_VIM/github
	set runtimepath=$VIMRUNTIME

	silent! source ~/.vimrc.local
	filetype plugin indent on
	syntax enable

	if has('termguicolors') && !has('gui_running') && (has('win32') || (256 == &t_Co))
		silent! set termguicolors
	endif
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
	nnoremap <silent><C-s>    <Cmd>FloatingTerminalToggle<cr>
	tnoremap <silent><C-s>    <Cmd>FloatingTerminalToggle<cr>
	nnoremap <silent><C-z>    <Cmd>GitDiff<cr>
	nnoremap <silent><space>  <Cmd>GitLsFiles<cr>

	" Move the next/previous error in quickfix.
	nnoremap <silent><C-n>    <Cmd>cnext \| normal zz<cr>
	nnoremap <silent><C-p>    <Cmd>cprevious \| normal zz<cr>
endif

function! s:is_installed(user_and_name) abort
	let xs = split(a:user_and_name, '/')
	return !empty(globpath($VIMRC_VIM, 'github/pack/' .. xs[0] .. '/*/' .. xs[1]))
endfunction

if s:is_installed('rbtnn/vim-gloaded')
	runtime OPT plugin/gloaded.vim
endif

if s:is_installed('rbtnn/vim-ambiwidth')
	let g:ambiwidth_cica_enabled = (&guifont =~# '^Cica')
endif

if s:is_installed('kaicataldo/material.vim')
	if s:is_installed('itchyny/lightline.vim')
		let g:lightline = {}
		let g:lightline['colorscheme'] = 'material_vim'
		let g:lightline['enable'] = { 'statusline': 1, 'tabline': 0, }
		let g:lightline['separator'] = { 'left': nr2char(0xe0b0), 'right': nr2char(0xe0b2), }
	endif
	if has('vim_starting')
		autocmd vimrc ColorScheme      *
			\ : highlight!       TabSideBar        guifg=#777777 guibg=NONE    gui=NONE cterm=NONE
			\ | highlight!       TabSideBarFill    guifg=NONE    guibg=NONE    gui=NONE cterm=NONE
			\ | highlight!       TabSideBarSel     guifg=#ffffff guibg=NONE    gui=NONE cterm=NONE
			\ | highlight!       TabSideBarLabel   guifg=#00a700 guibg=NONE    gui=BOLD cterm=NONE
			\ | highlight!       CursorIM          guifg=NONE    guibg=#d70000
			\ | highlight!       SpecialKey        guifg=#2a2a2a guibg=NONE    gui=NONE
			\ | highlight!       NonText           guifg=#2a2a2a guibg=NONE    gui=NONE
		if &guifont =~# '^Cica'
			autocmd vimrc ColorScheme      *
				\ : highlight!       TabSideBarIcon    guifg=#ffa700 guibg=NONE    gui=BOLD cterm=NONE
		endif
		let g:material_theme_style = 'darker'
		colorscheme material
	endif
endif

if s:is_installed('kana/vim-operator-replace')
	nmap     <silent>s           <Plug>(operator-replace)
endif

if s:is_installed('tyru/restart.vim')
	let g:restart_sessionoptions = &sessionoptions
endif

if !has('vim_starting')
	" Check whether echo-messages are not disappeared when .vimrc is read.
	echo '.vimrc has just read!'
endif

