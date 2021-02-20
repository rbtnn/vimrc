set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_PLUGDIR = expand('$VIMRC_ROOT/.vim/plugged')
let $VIMRC_PLUGVIM = expand('$VIMRC_ROOT/.vim/autoload/plug.vim')

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM mouse=a clipboard=unnamed belloff=all
set shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set keywordprg=:help wildmenu cmdheight=3 tags=./tags;
set list nowrap listchars=tab:\ \ \|,trail:- fileformats=unix,dos
set showtabline=0 laststatus=2 statusline& ambiwidth=double
set nobackup nowritebackup noswapfile undofile undodir=$VIMRC_DOTVIM/undofiles//
set packpath= runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM foldmethod=indent foldlevelstart=1
setglobal incsearch hlsearch nowrapscan ignorecase

if has('tabsidebar')
	set tabsidebar& tabsidebarwrap notabsidebaralign showtabsidebar=2 tabsidebarcolumns=20
endif

set wildignore=*.pdb,*.obj,*.dll,*.exe,*.idb,*.ncb,*.ilk,*.plg,*.bsc,*.sbr,*.opt,*.config
set wildignore+=*.pdf,*.mp3,*.doc,*.docx,*.xls,*.xlsx,*.idx,*.jpg,*.png,*.zip,*.MMF,*.gif
set wildignore+=*.resX,*.lib,*.resources,*.ico,*.suo,*.cache,*.user,*.myapp,*.dat,*.dat01
set wildignore+=*.vbe,*.url,*.lnk,NTUSER.DAT*,*.msi,desktop.ini,Thumbs.db

silent! call mkdir(expand('$VIMRC_DOTVIM/undofiles'), 'p')
silent! source $VIMRC_PLUGDIR/vim-gloaded/plugin/gloaded.vim
silent! source $VIMRC_ROOT/vim-on-windows/vimbatchfiles/setup.vim

let g:plug_url_format = 'https://github.com/%s.git'
let g:restart_sessionoptions = 'winpos,winsize,resize,buffers,curdir,tabpages'
let g:vim_indent_cont = &g:shiftwidth
let g:badwolf_tabline = 0
let g:badwolf_darkgutter = 1

if !has('nvim') && has('win32') && !filereadable(expand('~/AppData/Local/nvim/init.vim'))
	" This is the same as stdpath('config') in nvim.
	let s:initdir = expand('~/AppData/Local/nvim')
	call mkdir(s:initdir, 'p')
	call writefile(['silent! source ~/.vimrc'], s:initdir .. '/init.vim')
endif

if filereadable()
silent! call plug#begin($VIMRC_PLUGDIR)
for s:plug_name in [
		\ 'kana/vim-operator-replace',
		\ 'kana/vim-operator-user',
		\ 'rbtnn/vim-diffy',
		\ 'rbtnn/vim-gloaded',
		\ 'rbtnn/vim-near',
		\ 'rbtnn/vim-vimscript_indentexpr',
		\ 'rbtnn/vim-vimscript_lasterror',
		\ 'rbtnn/vim-vimscript_tagfunc',
		\ 'sjl/badwolf',
		\ 'thinca/vim-qfreplace',
		\ 'tyru/restart.vim',
		\ ]
	call plug#(s:plug_name)
endfor
silent! source ~/.vimrc.local
call plug#end()
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
