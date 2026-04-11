set makeencoding=char
scriptencoding utf-8

let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/.vim')
if !exists('s:is_windowsterminal')
  let s:is_windowsterminal = v:false
  if filereadable('/proc/version')
    let s:is_windowsterminal = !empty(matchstr(readfile('/proc/version')[0], 'microsoft.*-WSL'))
  endif
endif

language messages C

if has('win32')
  set winaltkeys=yes
  set guioptions=M
else
  set mouse=a
endif

set autoread
set belloff=all
set clipboard=unnamed
set cmdheight=3
set colorcolumn&
set complete-=t
set completeslash=slash
set expandtab shiftwidth=2 tabstop=2
set fileencodings=ucs-bom,utf-8,cp932
set fileformats=unix,dos
set fillchars=vert:\│,tpl_vert:\|
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set hlsearch
set incsearch
set isfname-==
set keywordprg=:help
set laststatus=2
set list listchars=tab:-->
set matchpairs+=<:>
set matchtime=1
set nobackup
set noignorecase
set nonumber norelativenumber nocursorline
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats& nrformats-=octal nrformats+=unsigned
set rulerformat& ruler
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set showcmd
set showmatch
set showmode
set softtabstop=-1
set synmaxcol=300
set tabline& showtabline=0
set tabpanel& showtabpanel=1 tabpanelopt=vert
set tags=./tags;
set termguicolors
set timeout timeoutlen=500 ttimeoutlen=100
set updatetime=500
set virtualedit=block
set wildignore=*/node_modules/**
set wildmenu
set wildoptions=pum

if has('patch-9.2.0318')
  set pumopt=opacity:90,height:10,border:single
endif

if has('patch-9.1.1590')
  set autocomplete
  set complete+=o
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

if $TERM =~# 'xterm-'
  " Insert Mode: change to a steady bar
  if s:is_windowsterminal
    let &t_SI = "\e[6 q"
  else
    let &t_SI = "\e[5 q"
  endif
  " Normal Mode: change to a steady block
  let &t_EI = "\e[2 q"
endif

let g:vim_indent_cont = &g:shiftwidth
let g:netrw_menu = 0
let g:molder_show_hidden = 1

augroup vimrc
  autocmd!
  autocmd VimEnter,BufEnter           * :call s:vimrc_init()
  autocmd ColorScheme                 * :highlight! link TabPanel         Normal
  autocmd ColorScheme                 * :highlight! link TabPanelSel      Normal
  autocmd ColorScheme                 * :highlight! link TabPanelFill     Normal
  autocmd ColorScheme                 * :highlight!      Terminal                guibg=NONE
augroup END

if has('vim_starting')
  set packpath=$VIMRC_VIM/github
  set runtimepath=$VIMRUNTIME,$VIMRC_VIM/github
  silent! source ~/.vimrc.local
  filetype plugin indent on
  syntax enable
  packloadall
  try
    colorscheme habamax
  catch
  endtry
endif

function! s:vimrc_init() abort
  " Windows OS treats Ctrl-v as Paste.
  nnoremap         V        <C-v>

  if s:is_windowsterminal
    command! SendWinClipboard  :call system('/mnt/c/Windows/System32/clip.exe', @")
  endif

  " Can't use <S-space> at :terminal
  " https://github.com/vim/vim/issues/6040
  tnoremap <silent><S-space>           <space>

  " Emacs key mappings
  if has('win32') && (&shell =~# '\<cmd\.exe$')
    tnoremap <silent><C-p>           <up>
    tnoremap <silent><C-n>           <down>
    tnoremap <silent><C-b>           <left>
    tnoremap <silent><C-f>           <right>
    tnoremap <silent><C-e>           <end>
    tnoremap <silent><C-a>           <home>
    tnoremap <silent><C-u>           <esc>
    tnoremap <silent><C-cr>          <cr>
  endif

  cnoremap         <C-b>    <left>
  cnoremap         <C-f>    <right>
  cnoremap         <C-e>    <end>
  cnoremap         <C-a>    <home>

  " Windows OS treats Ctrl-v as Paste.
  nnoremap         V        <C-v>

  if s:is_windowsterminal
    command! SendWinClipboard  :call system('/mnt/c/Windows/System32/clip.exe', @")
  endif

  nnoremap <silent><C-j>    <Cmd>tabnext<cr>
  nnoremap <silent><C-k>    <Cmd>tabprevious<cr>
  tnoremap <silent><C-j>    <Cmd>tabnext<cr>
  tnoremap <silent><C-k>    <Cmd>tabprevious<cr>

  nnoremap <silent><C-p>    <Cmd>cprevious<cr>zz
  nnoremap <silent><C-n>    <Cmd>cnext<cr>zz

  if get(g:, 'loaded_operator_replace', v:false)
    nmap     <silent>x        <Plug>(operator-replace)
  endif

  if get(g:, 'loaded_gitdiff', v:false)
    nnoremap s                <Cmd>GitUnifiedDiff<cr>
  endif

  command! -nargs=0 SetupPlugins :call s:vimrc_setup_plugins()
endfunction

function! s:vimrc_setup_plugins() abort
  call s:vimrc_git_clone_or_pull('haya14busa', 'vim-operator-flashy')
  call s:vimrc_git_clone_or_pull('kana', 'vim-operator-replace')
  call s:vimrc_git_clone_or_pull('kana', 'vim-operator-user')
  call s:vimrc_git_clone_or_pull('mattn', 'vim-molder')
  call s:vimrc_git_clone_or_pull('rbtnn', 'vim-ambiwidth')
  call s:vimrc_git_clone_or_pull('rbtnn', 'vim-gitdiff')
  call s:vimrc_git_clone_or_pull('rbtnn', 'vim-gloaded')
  call s:vimrc_git_clone_or_pull('thinca', 'vim-qfreplace')
endfunction

function! s:vimrc_git_clone_or_pull(user, name) abort
  let path = expand('$VIMRC_VIM/github/pack/my/start/')
  let opt = { 'term_finish': 'close', }
  silent! call mkdir(path, 'p')
  if isdirectory(expand(path .. '/' .. a:name))
    call term_start(['git', '-C', path .. '/' .. a:name, 'pull'], opt)
  else
    call term_start(['git', '-C', path, 'clone', '--depth', '1', 'https://github.com/' .. a:user .. '/' .. a:name .. '.git'], opt)
  endif
endfunction

if !has('vim_starting')
  call s:vimrc_init()
endif
