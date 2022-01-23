
if &compatible
	set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

" https://github.com/vim/vim/commit/957cf67d50516ba98716f59c9e1cb6412ec1535d
let s:vimpatch_cmdtag = has('patch-8.2.1978') || has('nvim')
" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
let s:vimpatch_unsigned = has('patch-8.2.0860') || has('nvim')
let g:vim_indent_cont = &g:shiftwidth
let &cedit = "\<C-q>"

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_VIM = expand('$VIMRC_ROOT/vim')
let $VIMRC_DEV = expand('$VIMRC_VIM/dev')
let $VIMRC_PACKSTART = expand('$VIMRC_VIM/pack/my/start')

augroup vimrc
	autocmd!
	" Delete unused commands, because it's an obstacle on cmdline-completion.
	autocmd CmdlineEnter     *
		\ : for s:cmdname in [
		\		'MANPAGER', 'Man', 'Tutor', 'VimFoldh', 'TextobjStringDefaultKeyMappings',
		\		'Plug', 'PlugDiff', 'PlugInstall', 'PlugSnapshot',
		\		'PlugStatus', 'PlugUpgrade', 'UpdateRemotePlugins',
		\		]
		\ | 	execute printf('silent! delcommand %s', s:cmdname)
		\ | endfor
		\ | unlet s:cmdname
	autocmd FileType     help :setlocal colorcolumn=78
augroup END

language message C
set winaltkeys=yes
set guioptions=mM
set mouse=a
set belloff=all
set clipboard=unnamed

set autoread
set backspace=indent,eol,start
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
set scrolloff=5
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set shiftwidth=4
set showmatch
set showmode
set softtabstop=-1
set tabstop=4
set tags=./tags;
set updatetime=100
set wildmenu

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
	let g:tabsidebar_vertsplit = 1
	set notabsidebaralign
	set notabsidebarwrap
	set showtabsidebar=2
	set tabsidebar=%!vimrc#tabpages#expr(v:true)
	set tabsidebarcolumns=20
	set showtabline=0
	set tabline&
else
	set showtabline=2
	set tabline=%!vimrc#tabpages#expr(v:false)
endif

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

	call plug#('itchyny/lightline.vim')
	call plug#('kana/vim-operator-replace')
	call plug#('kana/vim-operator-user')
	call plug#('kana/vim-textobj-user')
	call plug#('cocopon/vaffle.vim')
	call plug#('rbtnn/vim-ambiwidth')
	call plug#('rbtnn/vim-gloaded')
	call plug#('rbtnn/vim-mrw')
	call plug#('rbtnn/vim-qfpopup')
	call plug#('rbtnn/vim-textobj-string')
	call plug#('rbtnn/vim-vimscript_indentexpr')
	call plug#('rbtnn/vim-vimscript_lasterror')
	call plug#('rbtnn/vim-vimscript_tagfunc')
	call plug#('sonph/onehalf', { 'rtp': 'vim/', })
	call plug#('thinca/vim-qfreplace')

	if !has('nvim') && has('win32')
		call plug#('tyru/restart.vim')
	endif
	silent! source ~/.vimrc.local
	call plug#end()
	function! s:is_installed(name) abort
		return isdirectory($VIMRC_PACKSTART .. '/' .. a:name) && (-1 != index(keys(g:plugs), a:name))
	endfunction
endif

if has('vim_starting') && has('termguicolors') && !has('gui_running') && (has('win32') || (256 == &t_Co))
	silent! set termguicolors
endif

if s:is_installed('vim-gloaded')
	source $VIMRC_PACKSTART/vim-gloaded/plugin/gloaded.vim
endif

if s:is_installed('vaffle.vim')
	let g:vaffle_show_hidden_files = 1
	nnoremap <silent><space>f       :<C-u>execute 'Vaffle ' .. (filereadable(expand('%')) ? '%:h' : '.')<cr>
endif

if s:is_installed('vim-qfpopup')
	autocmd vimrc VimResized         * :let g:qfpopup_width = &columns * 2 / 5
endif

nnoremap <silent><space>d        :<C-u>GitDiff<cr>
nnoremap <silent><space>t        :<C-u>terminal<cr>
nnoremap         <space>r        :<C-u>GitGotoRootDir<cr>
nnoremap         <space>g        :<C-u>GitGrep<space>

if s:is_installed('vim-mrw')
	nnoremap <silent><space>s       :<C-u>MRW<cr>
endif

if s:is_installed('lightline.vim')
	let g:lightline = {}
	let g:lightline['colorscheme'] = 'onehalfdark'
	let g:lightline['enable'] = { 'statusline': 1, 'tabline': 0, }
	let g:lightline['separator'] = { 'left': nr2char(0xe0b0), 'right': nr2char(0xe0b2), }
endif

if s:is_installed('onehalf')
	if has('vim_starting')
		set background=dark
		autocmd vimrc ColorScheme      *
			\ : highlight!       TabSideBar      guifg=#76787b guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       TabSideBarFill  guifg=#1a1a1a guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       TabSideBarSel   guifg=#22863a guibg=NONE    gui=NONE           cterm=NONE
			\ | highlight!       Comment                                     gui=NONE           cterm=NONE
			\ | highlight!       CursorIM        guifg=NONE    guibg=#aa0000
			\ | highlight!       SpecialKey      guifg=#383c44
			\ | highlight!       Pmenu           guifg=#dcdfe4 guibg=#313640
			\ | highlight!       LineNr                        guibg=#313640
		colorscheme onehalfdark
	endif
endif

if s:is_installed('vim-operator-replace')
	nmap     <silent>s           <Plug>(operator-replace)
endif

if s:is_installed('restart.vim')
	let g:restart_sessionoptions = &sessionoptions
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

call vimrc#snippet#clear('vim')
call vimrc#snippet#add('vim', '\<fu\%[nction\]', "function! () abort\<cr>endfunction\<up>\<left>")
call vimrc#snippet#add('vim', '\<au\%[group\]', "augroup \<cr>autocmd!\<cr>augroup END\<up>\<up>")
call vimrc#snippet#add('vim', '\<if', "if \<cr>endif\<up>")
call vimrc#snippet#add('vim', '\<wh\%[ile\]', "while \<cr>endwhile\<up>")

inoremap   <expr><C-f>           vimrc#snippet#expand()

if !has('vim_starting')
	" Check whether echo-messages are not disappeared when .vimrc is read.
	echo '.vimrc has just read!'
endif

finish
"
" termopen.vim
" https://gist.github.com/rbtnn/bf3d58f99d95da9d9c0d2dcd51d30e47
" toggle_terminal.vim
" https://gist.github.com/rbtnn/e71d36b462ac89d4dd029f4f42b42666
" ddc_and_pum.vim
" https://gist.github.com/rbtnn/4373572564964a905d1c162ed3931497
" airline and lightline arrow settings
" https://gist.github.com/rbtnn/41176651514d48178842f807ec8cac72
"
