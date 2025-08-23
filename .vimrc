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
set cmdheight=3
set colorcolumn&
set complete-=t
set completeslash=slash
set expandtab shiftwidth=2 tabstop=2
set fileencodings=ucs-bom,utf-8,cp932
set fileformats=unix,dos
set fillchars=vert:│
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set hlsearch
set incsearch
set isfname-==
set keywordprg=:help
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
set nrformats& nrformats-=octal
set pumheight=10
set rulerformat& ruler 
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set showcmd
set showmatch
set showmode
set softtabstop=-1
set laststatus=2 
set synmaxcol=300
set tabline& showtabline=0
set tags=./tags;
set termguicolors
set timeout timeoutlen=500 ttimeoutlen=100
set updatetime=500
set virtualedit=block
set wildignore=*/node_modules/**
set wildmenu

if has('patch-8.2.0860')
  set nrformats+=unsigned
endif

if has('patch-9.1.1590')
  set autocomplete
  set complete+=o
endif

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

if has('tabpanel')
  set tabpanel=%!tabpanel#exec()
  set showtabpanel=1
  set fillchars+=tpl_vert:│
  set tabpanelopt=vert,columns:24
endif

let &cedit = "\<C-q>"

if $TERM =~# 'xterm-'
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

let g:vim_indent_cont = &g:shiftwidth
let g:molder_show_hidden = 1
let g:lightline = { 'colorscheme': 'onedark', }

augroup vimrc
  autocmd!
  autocmd VimEnter,BufEnter           * :call s:vimrc_init()
  autocmd ColorScheme                 * :highlight! link TabPanel         Normal
  autocmd ColorScheme                 * :highlight! link TabPanelSel      Normal
  autocmd ColorScheme                 * :highlight! link TabPanelFill     Normal
  autocmd ColorScheme                 * :highlight!      PmenuSel     guifg=NONE guibg=#013F7F
  autocmd ColorScheme                 * :highlight!      Normal                  guibg=#080808
  autocmd ColorScheme                 * :highlight!      Terminal                guibg=NONE
  autocmd FileType           javascript :set expandtab shiftwidth=4 tabstop=4
  autocmd FileType           typescript :set expandtab shiftwidth=4 tabstop=4
  autocmd FileType      typescriptreact :set expandtab shiftwidth=4 tabstop=4
augroup END

if has('vim_starting')
  set packpath=$VIMRC_VIM/github
  set runtimepath=$VIMRUNTIME,$VIMRC_VIM/git,$VIMRC_VIM/vimdev
  silent! source ~/.vimrc.local
  filetype plugin indent on
  syntax enable
  packloadall
  try
    colorscheme onedark
  catch
    colorscheme default
  endtry
endif

function! s:add_plugin(j, x) abort
  let xs = split(a:x, '/')
  if !has_key(a:j.plugins.start, xs[0])
    let a:j.plugins.start[xs[0]] = []
  endif
  let a:j.plugins.start[xs[0]] += [xs[1]]
endfunction

function! s:vimrc_init() abort
  if exists(':PkgSync')
    let j = { 'packpath': '~/.vim/github', 'plugins': { 'start': {} } }
    call s:add_plugin(j, 'haya14busa/vim-operator-flashy')
    call s:add_plugin(j, 'itchyny/lightline.vim')
    call s:add_plugin(j, 'joshdick/onedark.vim')
    call s:add_plugin(j, 'kana/vim-operator-replace')
    call s:add_plugin(j, 'kana/vim-operator-user')
    call s:add_plugin(j, 'lambdalisue/vim-glyph-palette')
    call s:add_plugin(j, 'mattn/vim-molder')
    call s:add_plugin(j, 'rbtnn/vim-ambiwidth')
    call s:add_plugin(j, 'rbtnn/vim-gloaded')
    call s:add_plugin(j, 'rbtnn/vim-pkgsync')
    call s:add_plugin(j, 'ryanoasis/vim-devicons')
    call s:add_plugin(j, 'thinca/vim-qfreplace')
    call s:add_plugin(j, 'tweekmonster/helpful.vim')
    call s:add_plugin(j, 'tyru/restart.vim')
    call writefile([json_encode(j)], expand('~/pkgsync.json'))
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

  if filereadable('/proc/version')
    if !empty(matchstr(readfile('/proc/version')[0], 'microsoft.*-WSL'))
      command! SendWinClipboard  :call system('/mnt/c/Windows/System32/clip.exe', @")
    endif
  endif

  if get(g:, 'loaded_operator_flashy', v:false)
    map              y        <Plug>(operator-flashy)
    nmap             Y        <Plug>(operator-flashy)$
  else
    nnoremap         Y        y$
  endif

  nnoremap <silent><C-j>    <Cmd>tabnext<cr>
  nnoremap <silent><C-k>    <Cmd>tabprevious<cr>
  tnoremap <silent><C-j>    <Cmd>tabnext<cr>
  tnoremap <silent><C-k>    <Cmd>tabprevious<cr>

  nnoremap <silent><C-p>    <Cmd>cprevious<cr>zz
  nnoremap <silent><C-n>    <Cmd>cnext<cr>zz

  nnoremap <space>          <Cmd>execute isdirectory(expand('%:h')) ? 'e %:h' : 'e .'<cr>
  nnoremap s                <Cmd>GitLsFiles<cr>

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

  if get(g:, 'loaded_glyph_palette', v:false)
    call glyph_palette#apply()
  endif
endfunction

if !has('vim_starting')
  call s:vimrc_init()
endif
