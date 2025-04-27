set makeencoding=char
scriptencoding utf-8

let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/.vim')

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
set complete-=t
set completeslash=slash
set expandtab shiftwidth=2 tabstop=2
set fileencodings=ucs-bom,utf-8,cp932
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set hlsearch
set incsearch
set isfname-==
set keywordprg=:help
set laststatus=1
set list listchars=tab:-->
set matchpairs+=<:>
set matchtime=1
set nobackup
set noignorecase
set nonumber norelativenumber nocursorline
set noruler rulerformat&
set noshowmode
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats& nrformats-=octal
if has('patch-8.2.0860')
  set nrformats+=unsigned
endif
set pumheight=10
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set showcmd
set showmatch
set showtabline=0 tabline&
set softtabstop=-1
set synmaxcol=300
set tags=./tags;
set termguicolors
set timeout timeoutlen=500 ttimeoutlen=100
set updatetime=500
set wildignore=*/node_modules/**
set wildmenu
if has('patch-8.2.4325')
  set wildoptions=pum
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
  set fillchars+=tabsidebar:\|
  set notabsidebaralign
  set notabsidebarwrap
  set showtabsidebar=1
  set tabsidebarcolumns=20
  function! Tabsidebar() abort
    try
      let tnr = g:actual_curtabpage
      let s = printf("\n TABPAGE %d.\n", tnr)
      for x in filter(getwininfo(), { i,x -> x.tabnr == tnr })
        let bname = fnamemodify(bufname(x.bufnr), ":t")
        if empty(bname)
          let bname = '[No Name]'
        endif
        let s = s .. printf("  %s%s\n",
          \ ((tabpagenr() == x.tabnr) && (winnr() == x.winnr) ? '*' : ' '),
          \ bname)
      endfor
      return s
    catch
      return "ERR"
    endtry
  endfunction
  set tabsidebar=%!Tabsidebar()
endif

let &cedit = "\<C-q>"

if $TERM =~# 'xterm-'
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

let g:vim_indent_cont = &g:shiftwidth
let g:molder_show_hidden = 1

if has('vim_starting')
  set packpath=$VIMRC_VIM/github
  set runtimepath=$VIMRUNTIME
  silent! source ~/.vimrc.local
  filetype plugin indent on
  syntax enable
  packloadall
  try
    colorscheme habamax
  catch
    colorscheme default
  endtry
endif

augroup vimrc
  autocmd!
  autocmd VimEnter,BufEnter * :call s:vimrc_init()
  autocmd ColorScheme       * :highlight! link TabSideBarFill StatusLine
augroup END

function! s:vimrc_init() abort
  if exists(':PkgSync')
    " pkgsync.json is managed by .vimrc 
    call writefile([json_encode({
      \     "packpath": "~/.vim/github",
      \     "plugins": {
      \         "start": {
      \             "kana": [
      \                 "vim-operator-replace",
      \                 "vim-operator-user",
      \             ],
      \             "mattn": [
      \               "vim-molder"
      \             ],
      \             "rbtnn": [
      \                 "vim-ambiwidth",
      \                 "vim-gitdiff",
      \                 "vim-gloaded",
      \                 "vim-pkgsync",
      \             ],
      \             "thinca": [
      \                 "vim-qfreplace",
      \             ],
      \         }
      \     }
      \ })], expand('~/pkgsync.json'))
  else
    function! s:pkgsync_setup() abort
      if !isdirectory(expand('$VIMRC_VIM/github/pack/rbtnn/start/vim-pkgsync'))
        let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
        silent! call mkdir(path, 'p')
        call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
          \ 'cwd': path,
          \ })
        echo 'please restart Vim!'
      endif
    endfunction
    command! -nargs=0 PkgSyncSetup :call s:pkgsync_setup()
  endif

  cabbrev W  w

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

  nnoremap         v        <C-v>
  nnoremap         Y        y$

  nnoremap <silent><C-j>    <Cmd>tabnext<cr>
  nnoremap <silent><C-k>    <Cmd>tabprevious<cr>
  tnoremap <silent><C-j>    <Cmd>tabnext<cr>
  tnoremap <silent><C-k>    <Cmd>tabprevious<cr>

  nnoremap <silent><C-p>    <Cmd>cprevious<cr>zz
  nnoremap <silent><C-n>    <Cmd>cnext<cr>zz

  nnoremap <expr>s          get(t:, 'vimrc_s_keymapping', '<Cmd>GitUnifiedDiff -w<cr>')

  if get(g:, 'loaded_molder', v:false)
    if &filetype == 'molder'
      nnoremap <buffer> h  <plug>(molder-up)
      nnoremap <buffer> l  <plug>(molder-open)
      nnoremap <buffer> C  <Cmd>call chdir(b:molder_dir) \| verbose pwd<cr>
    endif
  endif

  if get(g:, 'loaded_operator_replace', v:false)
    nmap     <silent>x        <Plug>(operator-replace)
  endif
endfunction
