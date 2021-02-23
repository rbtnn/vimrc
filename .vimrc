set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_UNDO = expand('$VIMRC_DOTVIM/undofiles')

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM mouse=a clipboard=unnamed belloff=all
set shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set keywordprg=:help wildmenu cmdheight=3 tags=./tags;
set list nowrap listchars=tab:\ \ \|,trail:- fileformats=unix,dos
set showtabline=0 laststatus=2 statusline& ambiwidth=double
set nobackup nowritebackup noswapfile undofile undodir=$VIMRC_UNDO//
set foldmethod=indent foldlevelstart=1
setglobal incsearch hlsearch nowrapscan ignorecase

if has('tabsidebar')
	set tabsidebar& tabsidebarwrap notabsidebaralign showtabsidebar=2 tabsidebarcolumns=20
endif

set wildignore=*.pdb,*.obj,*.dll,*.exe,*.idb,*.ncb,*.ilk,*.plg,*.bsc,*.sbr,*.opt,*.config
set wildignore+=*.pdf,*.mp3,*.doc,*.docx,*.xls,*.xlsx,*.idx,*.jpg,*.png,*.zip,*.MMF,*.gif
set wildignore+=*.resX,*.lib,*.resources,*.ico,*.suo,*.cache,*.user,*.myapp,*.dat,*.dat01
set wildignore+=*.vbe,*.url,*.lnk,NTUSER.DAT*,*.msi,desktop.ini,Thumbs.db

let g:restart_sessionoptions = 'winpos,winsize,resize,buffers,curdir,tabpages'
let g:vim_indent_cont = &g:shiftwidth
let g:badwolf_tabline = 0
let g:badwolf_darkgutter = 1

silent! call mkdir($VIMRC_UNDO, 'p')
silent! source $VIMRC_DOTVIM/pack/my/start/vim-gloaded/plugin/gloaded.vim
silent! source $VIMRC_ROOT/vim-on-windows/vimbatchfiles/setup.vim

set runtimepath=$VIMRUNTIME
set packpath=$VIMRC_DOTVIM
packloadall!

if !has('nvim') && has('win32') && !filereadable(expand('~/AppData/Local/nvim/init.vim'))
	" This is the same as stdpath('config') in nvim.
	let s:initdir = expand('~/AppData/Local/nvim')
	call mkdir(s:initdir, 'p')
	call writefile(['silent! source ~/.vimrc'], s:initdir .. '/init.vim')
endif

tnoremap <silent><nowait><C-p>       <up>
tnoremap <silent><nowait><C-n>       <down>
tnoremap <silent><nowait><C-b>       <left>
tnoremap <silent><nowait><C-f>       <right>
tnoremap <silent><nowait><C-e>       <end>
tnoremap <silent><nowait><C-a>       <home>
tnoremap <silent><nowait><C-u>       <esc>
tnoremap <silent><nowait>gt          <C-w>gt
tnoremap <silent><nowait>gT          <C-w>gT

nnoremap <silent><nowait><space>     <Cmd>Near<cr>
nnoremap <silent><nowait><C-s>       <Cmd>Diffy -w<cr>
nnoremap <silent><nowait><C-n>       <Cmd>cnext<cr>
nnoremap <silent><nowait><C-p>       <Cmd>cprevious<cr>
nmap     <silent><nowait>s           <Plug>(operator-replace)

silent! colorscheme badwolf

silent! source ~/.vimrc.local

filetype indent plugin on
syntax on
