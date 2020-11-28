set encoding=utf-8
set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_DOTVIM = expand('$VIMRC_ROOT/.vim')
let $VIMRC_PLUGDIR = expand('$VIMRC_ROOT/.vim/plugged')

set langmenu=en_gb.latin1
set winaltkeys=yes guioptions=mM mouse=a clipboard=unnamed belloff=all
set shiftround softtabstop=-1 shiftwidth=4 tabstop=4
set keywordprg=:help wildmenu cmdheight=3 tags=./tags;
set list nowrap listchars=tab:\ \ \|,trail:- fileformats=unix,dos
set showtabline=0 laststatus&
set nobackup nowritebackup noswapfile undofile undodir=$VIMRC_DOTVIM/undofiles//
set packpath= runtimepath=$VIMRUNTIME,$VIMRC_DOTVIM
setglobal incsearch hlsearch nowrapscan ignorecase

silent! call mkdir(expand('$VIMRC_DOTVIM/undofiles'), 'p')
silent! source $VIMRC_PLUGDIR/vim-gloaded/plugin/gloaded.vim
silent! source $VIMRC_ROOT/vim-on-windows/vimbatchfiles/setup.vim

let g:vim_indent_cont = &g:shiftwidth
let g:restart_sessionoptions = 'winpos,winsize,resize,buffers,curdir,tabpages'
let g:molder_show_hidden = 1
let g:plug_url_format = 'https://github.com/%s.git'

silent! call plug#begin($VIMRC_PLUGDIR)
for s:plug_name in [
		\ 'kana/vim-operator-replace',
		\ 'kana/vim-operator-user',
		\ 'mattn/vim-molder',
		\ 'rbtnn/vim-gloaded',
		\ 'rbtnn/vim-jumptoline',
		\ 'rbtnn/vim-vimscript_indentexpr',
		\ 'rbtnn/vim-vimscript_lasterror',
		\ 'rbtnn/vim-vimscript_tagfunc',
		\ 'thinca/vim-qfreplace',
		\ 'tyru/restart.vim',
		\ ]
	call plug#(s:plug_name)
endfor
call plug#end()

tnoremap <silent><nowait><C-p>       <up>
tnoremap <silent><nowait><C-n>       <down>
tnoremap <silent><nowait><C-b>       <left>
tnoremap <silent><nowait><C-f>       <right>
tnoremap <silent><nowait><C-e>       <end>
tnoremap <silent><nowait><C-a>       <home>
tnoremap <silent><nowait><C-u>       <esc>
nnoremap <silent><nowait><C-s>       :<C-u>call vimrc#git#diff('-w')<cr>
nnoremap <silent><nowait><C-f>       :<C-u>call vimrc#git#lsfiles()<cr>
nnoremap <silent><nowait><C-g>       :<C-u>call vimrc#git#grep()<cr>
nnoremap <silent><nowait><C-j>       :<C-u>JumpToLine!<cr>
nnoremap <silent><nowait><C-n>       :<C-u>cnext<cr>
nnoremap <silent><nowait><C-p>       :<C-u>cprevious<cr>
nmap     <silent><nowait>s           <Plug>(operator-replace)

silent! colorscheme mycolorscheme

silent! source ~/.vimrc.local
