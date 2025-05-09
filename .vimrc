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
set colorcolumn=78
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
set laststatus=2
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
set virtualedit=block
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

if has('tabpanel')
  function! Tabpanel() abort
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
  set tabpanel=%!Tabpanel()
  set showtabpanel=1
  if exists('+tabpanelopt')
    set tabpanelopt=vert:\|
  endif
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
  autocmd VimEnter,BufEnter * :call s:vimrc_init()
  autocmd ColorScheme       * :highlight! link TabPanel     Pmenu
  autocmd ColorScheme       * :highlight! link TabPanelSel  PmenuSel
  autocmd ColorScheme       * :highlight! link TabPanelFill Pmenu
  autocmd ColorScheme       * :highlight!      PmenuSel     guifg=NONE guibg=#013F7F
augroup END

if has('vim_starting')
  set packpath=$VIMRC_VIM/github
  set runtimepath=$VIMRUNTIME
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

function! VimLoadAction(target, q_args) abort
  let bnr = term_dumpload(expand(g:vimrc_vimrepo_dir .. '/src/testdir/' .. a:target .. '/' .. a:q_args))
  let wid = win_getid()
  let pid = popup_create(bnr, { 'border': [], })
  let pos = popup_getpos(win_getid())
  let width = pos['core_width']
  let height = pos['core_height']
  call popup_setoptions(pid, {
    \   'title': printf(' width:%d, height:%d ', width, height),
    \   'minwidth': width, 'maxwidth': width, 'minheight': height, 'maxheight': height,
    \ })
  call win_execute(wid, 'close')
endfunction

function! VimLoadList(target, ArgLead, CmdLine, CursorPos) abort
  let xs = []
  for x in readdir(expand(g:vimrc_vimrepo_dir .. '/src/testdir/' .. a:target))
    if -1 == match(a:CmdLine, x)
      let xs += [x]
    endif
  endfor
  return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
endfunction

function! VimLoadListDumps(ArgLead, CmdLine, CursorPos) abort
  return VimLoadList('dumps', a:ArgLead, a:CmdLine, a:CursorPos)
endfunction

function! VimLoadListFaileds(ArgLead, CmdLine, CursorPos) abort
  return VimLoadList('failed', a:ArgLead, a:CmdLine, a:CursorPos)
endfunction

function! ScreenCapture() abort
  let s = []
  for row in range(1, &lines - 1)
    let s += [join(map(range(1,&columns), {_,col -> nr2char(screenchar(row, col))}), '')]
  endfor
  return join(s, '')
endfunction

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
      \             "itchyny": [
      \               "lightline.vim"
      \             ],
      \             "tweekmonster": [
      \               "helpful.vim"
      \             ],
      \             "tyru": [
      \               "restart.vim"
      \             ],
      \             "haya14busa": [
      \               "vim-operator-flashy"
      \             ],
      \             "mattn": [
      \               "vim-molder"
      \             ],
      \             "joshdick": [
      \               "onedark.vim"
      \             ],
      \             "rbtnn": [
      \                 "vim-ambiwidth",
      \                 "vim-gitdiff",
      \                 "vim-gloaded",
      \                 "vim-mrw",
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

  " Windows OS treats Ctrl-v as Paste.
  nnoremap         V        <C-v>

  command! ScreenCapture  :echo ScreenCapture()

  if filereadable('/proc/version')
    if !empty(matchstr(readfile('/proc/version')[0], 'microsoft.*-WSL'))
      command! SendWinClipboard  :call system('/mnt/c/Windows/System32/clip.exe', @")

      let g:vimrc_vimrepo_dir = '~/work/vim'
      command! -nargs=0 VimClean
        \ : call term_start(['make', 'clean'], {
        \   'term_name': 'VimClean',
        \   'cwd': expand(g:vimrc_vimrepo_dir),
        \ })
      command! -nargs=0 VimBuild
        \ : call term_start(['make'], {
        \   'term_name': 'VimBuild',
        \   'cwd': expand(g:vimrc_vimrepo_dir),
        \ })
      command! -nargs=0 VimTags
        \ : call term_start(['make', 'tags'], {
        \   'term_name': 'VimTags',
        \   'cwd': expand(g:vimrc_vimrepo_dir .. '/runtime/doc'),
        \ })
      command! -nargs=0 VimTestRun
        \ : tabnew
        \ | call term_start(['make', 'clean', 'test_codestyle.res', 'test_options_all.res', 'test_tabpanel.res', 'report'], {
        \   'term_name': 'VimTestRun',
        \   'curwin': v:true,
        \   'cwd': expand(g:vimrc_vimrepo_dir .. '/src/testdir'),
        \ })
      command! -nargs=1 -complete=customlist,VimLoadListDumps   VimLoadDumps
        \ : call VimLoadAction('dumps', <q-args>)
      command! -nargs=1 -complete=customlist,VimLoadListFaileds VimLoadFailed
        \ : call VimLoadAction('failed', <q-args>)
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

  nnoremap <silent>X        <Cmd>echo screenrow() .. ',' .. screencol() screenpos(win_getid(), 1, 1)<cr>

  nnoremap <expr>s          get(t:, 'vimrc_small_s_keymapping', '<Cmd>GitUnifiedDiff -w<cr>')
  nnoremap <expr>S          get(t:, 'vimrc_capital_s_keymapping', printf('<Cmd>GitUnifiedDiff -w upstream/%s<cr>', get(readdir(gitdiff#get_rootdir() .. '/.git/refs/remotes/upstream'), 0, '')))

  if get(g:, 'loaded_mrw', v:false)
    nnoremap <silent><space>    <Cmd>MRW<cr>
  endif

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

if !has('vim_starting')
  call s:vimrc_init()
endif
