
if &compatible
    set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

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
set diffopt+=iwhiteall
set expandtab shiftwidth=4 tabstop=4
set fileencodings=ucs-bom,utf-8,cp932
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set incsearch
set isfname-==
set keywordprg=:help
set list listchars=tab:\ \ \|,trail:-
set matchpairs+=<:>
set matchtime=1
set nobackup
set nocursorline
set noignorecase
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
set showcmd
set showmatch
set softtabstop=-1
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
    set termguicolors
endif
