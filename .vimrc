
if &compatible
	set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

if has('nvim')
	finish
endif

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')

function! PkgSyncSetup() abort
	let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
	silent! call mkdir(path, 'p')
	call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
		\ 'cwd': path,
		\ })
endfunction

augroup vimrc
	autocmd!
	" Delete unused commands, because it's an obstacle on cmdline-completion.
	autocmd CmdlineEnter     *
		\ : for s:cmdname in ['MANPAGER', 'VimFoldh', 'TextobjStringDefaultKeyMappings']
		\ |     execute printf('silent! delcommand %s', s:cmdname)
		\ | endfor
		\ | unlet s:cmdname
	autocmd FileType     help :setlocal colorcolumn=78
	autocmd VimEnter        *
		\ :if !exists(':PkgSync')
		\ |  execute 'command! -nargs=0 PkgSyncSetup :call PkgSyncSetup()'
		\ |endif
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
set rulerformat=%{&fileencoding}/%{&fileformat}
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set shiftwidth=4
set showcmd
set showmatch
set softtabstop=-1
set tabstop=4
set tags=./tags;
set timeout timeoutlen=500 ttimeoutlen=100
set updatetime=500
set wildmenu

" https://github.com/vim/vim/commit/3908ef5017a6b4425727013588f72cc7343199b9
if has('patch-8.2.4325')
	set wildoptions=pum
endif

" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
if has('patch-8.2.0860')
	set nrformats-=octal
	set nrformats+=unsigned
endif

if has('persistent_undo')
	set undofile
	" https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
	let &undodir = expand('$VIMRC_VIM/undofiles/vim')
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

	set packpath=$VIMRC_VIM/local,$VIMRC_VIM/github
	set runtimepath=$VIMRUNTIME

	silent! source ~/.vimrc.local
	filetype plugin indent on
	syntax enable
	packloadall
endif

" Can't use <S-space> at :terminal
" https://github.com/vim/vim/issues/6040
tnoremap <silent><S-space>           <space>

" Smart space on wildmenu
cnoremap <expr><space>             (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

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

cnoremap         <C-b>        <left>
cnoremap         <C-f>        <right>
cnoremap         <C-e>        <end>
cnoremap         <C-a>        <home>

nnoremap <silent><C-n>    <Cmd>cnext \| normal zz<cr>
nnoremap <silent><C-p>    <Cmd>cprevious \| normal zz<cr>

nnoremap <silent><C-f>    <Cmd>GitLsFiles<cr>
nnoremap <silent><C-g>    <Cmd>GitDiffRecently<cr>

nnoremap <silent><C-s>    <Cmd>Terminal<cr>
tnoremap <silent><C-s>    <Cmd>Terminal<cr>

function! s:is_installed(user_and_name) abort
	let xs = split(a:user_and_name, '/')
	return !empty(globpath($VIMRC_VIM, 'github/pack/' .. xs[0] .. '/*/' .. xs[1]))
endfunction

if s:is_installed('rbtnn/vim-textobj-string')
	nmap <silent>ds das
	nmap <silent>ys yas
	nmap <silent>vs vas
	if s:is_installed('kana/vim-operator-replace')
		nmap <silent>s   <Plug>(operator-replace)
		nmap <silent>ss  <Plug>(operator-replace)as
	endif
endif

if s:is_installed('tyru/restart.vim')
	let g:restart_sessionoptions = &sessionoptions
endif

if has('vim_starting')
	if has('termguicolors') && !has('gui_running') && (has('win32') || (256 == &t_Co))
		silent! set termguicolors
	endif
	if s:is_installed('KeitaNakamura/neodark.vim')
		if s:is_installed('itchyny/lightline.vim')
			let g:lightline = {}
			let g:lightline['colorscheme'] = 'neodark'
			let g:lightline['enable'] = { 'statusline': 1, 'tabline': 0, }
		endif
		autocmd vimrc ColorScheme      *
			\ : highlight!       TabSideBar        guifg=#777777 guibg=#263748 gui=NONE cterm=NONE
			\ | highlight!       TabSideBarFill    guifg=NONE    guibg=#263748 gui=NONE cterm=NONE
			\ | highlight!       TabSideBarSel     guifg=#ffffff guibg=#263748 gui=NONE cterm=NONE
			\ | highlight!       TabSideBarLabel   guifg=#00a700 guibg=#263748 gui=BOLD cterm=NONE
			\ | highlight!       CursorIM          guifg=NONE    guibg=#d70000
			\ | highlight!       SpecialKey        guifg=#263748 guibg=NONE    gui=NONE cterm=NONE
			\ | highlight!       EndOfBuffer       guifg=#263748 guibg=NONE    gui=NONE cterm=NONE
			\ | highlight!       NonText           guifg=#263748 guibg=NONE    gui=NONE cterm=NONE
		colorscheme neodark
	endif
else
	" Check whether echo-messages are not disappeared when .vimrc is read.
	echo '.vimrc has just read!'
endif

