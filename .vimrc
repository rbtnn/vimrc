
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
set fillchars=eob:\ ,vert:\ ,fold:-
set foldlevelstart=999
set foldmethod=indent
set ignorecase
set incsearch
set isfname-==
set keywordprg=:help
set list listchars=tab:<->
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

command! -nargs=0 GrepprgInternal
	\ :set grepformat&
	\ |set grepprg=internal

if executable('git')
	command! -nargs=0 GrepprgGit
		\ :set grepformat=%f:%l:%c:%m
		\ |let &grepprg = 'git --no-pager grep --column --line --no-color'
endif

if executable('rg')
	command! -nargs=0 GrepprgRg
		\ :set grepformat=%f:%l:%c:%m
		\ |let &grepprg = 'rg --vimgrep --glob "!.git" --glob "!.svn" -uu'
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
			let tnr = get(g:, 'actual_curtabpage', tabpagenr())
			let lines = ['', printf('%s- Tab %d -%s', '%#TabSideBarLabel#', tnr, '%#TabSideBar#')]
			for x in filter(getwininfo(), { i, x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid'])) })
				let ft = getbufvar(x['bufnr'], '&filetype')
				let bt = getbufvar(x['bufnr'], '&buftype')
				let lines += [
					\    ((tnr == tabpagenr()) && (x['winnr'] == winnr()) ? '%#TabSideBarSel#' : '%#TabSideBar#')
					\ .. ' '
					\ .. (!empty(bt)
					\      ? printf('[%s]', bt == 'nofile' ? ft : bt)
					\      : (empty(bufname(x['bufnr']))
					\          ? '[No Name]'
					\          : fnamemodify(bufname(x['bufnr']), ':t')))
					\ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
					\ ]
			endfor
			return join(lines, "\n")
		catch
			let g:tab_throwpoint = v:throwpoint
			let g:tab_exception = v:exception
			return 'Error! Please see g:tab_throwpoint and g:tab_exception.'
		endtry
	endfunction
	let g:tabsidebar_vertsplit = 0
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!TabSideBar()
	set tabsidebarcolumns=20
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

	set packpath=$VIMRC_VIM
	set runtimepath=$VIMRUNTIME
	set runtimepath+=$VIMRC_VIM/dev/vim-diffview
	set runtimepath+=$VIMRC_VIM/dev/vim-qficonv
	set runtimepath+=$VIMRC_VIM/dev/vim-find
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

nnoremap <silent><space>d       :<C-u>DiffView<cr>
nnoremap         <space>f       :<C-u>Find<space>

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

function! s:is_installed(name) abort
	return !empty(globpath($VIMRC_VIM, 'pack/*/*/' .. a:name))
endfunction

if s:is_installed('vim-gloaded')
	runtime OPT plugin/gloaded.vim
endif

if s:is_installed('vim-mrw')
	nnoremap <silent><space>s       :<C-u>MRW -filename-only<cr>
endif

if s:is_installed('vim-diffnotify')
	let g:diffnotify_style = 'tabline'
	let g:diffnotify_threshold = 0
	let g:diffnotify_timespan = 1000
	let g:diffnotify_arguments = ['-w']
endif

if s:is_installed('SpaceCamp')
	if has('vim_starting')
		autocmd vimrc ColorScheme      *
			\ : highlight!       TabSideBar      guifg=#cccccc guibg=#262626    gui=NONE cterm=NONE
			\ | highlight!       TabSideBarFill  guifg=NONE    guibg=#262626    gui=NONE cterm=NONE
			\ | highlight!       TabSideBarSel   guifg=#ffffff guibg=#262626    gui=NONE cterm=NONE
			\ | highlight!       TabSideBarLabel guifg=#777777 guibg=#262626    gui=BOLD cterm=NONE
			\ | highlight!       CursorIM        guifg=NONE    guibg=#ff3333
			\ | highlight!       SpecialKey      guifg=#1f1f1f
		autocmd vimrc FileType      diff
			\ : highlight! link  diffRemoved     DiffDelete 
			\ | highlight! link  diffAdded       DiffAdd
		colorscheme spacecamp
	endif
else
	if has('tabsidebar')
		highlight!       TabSideBar                    guibg=NONE    gui=NONE cterm=NONE
		highlight!       TabSideBarFill                guibg=NONE    gui=NONE cterm=NONE
		highlight!       TabSideBarSel                 guibg=NONE    gui=NONE cterm=NONE
	endif
endif

if s:is_installed('vim-operator-replace')
	nmap     <silent>s           <Plug>(operator-replace)
endif

if s:is_installed('restart.vim')
	let g:restart_sessionoptions = &sessionoptions
endif

if !has('vim_starting')
	" Check whether echo-messages are not disappeared when .vimrc is read.
	echo '.vimrc has just read!'
endif

