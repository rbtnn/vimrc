
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
  autocmd FileType help :setlocal colorcolumn=78
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
set expandtab shiftwidth=2 tabstop=2
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set ignorecase
set incsearch
set isfname-==
set keywordprg=:help
set list listchars=trail:-
set matchpairs+=<:>
set matchtime=1
set nobackup
set nocursorline
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

nnoremap <silent><space>  <Cmd>FF<cr>
nnoremap <silent><C-g>    <Cmd>GitDiffRecently<cr>

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
  if has('tabsidebar')
    function! s:TabSideBarLabel(text) abort
      let rest = &tabsidebarcolumns - len(a:text)
      if rest < 0
        rest = 0
      endif
      return '%#TabSideBarLabel#' .. repeat(' ', rest / 2) .. a:text .. repeat(' ', rest / 2 + (rest % 2)) .. '%#TabSideBar#'
    endfunction

    function! TabSideBar() abort
      let tnr = get(g:, 'actual_curtabpage', tabpagenr())
      let lines = []
      let lines += ['', s:TabSideBarLabel(printf(' TABPAGE %d ', tnr)), '']
      for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
        let ft = getbufvar(x['bufnr'], '&filetype')
        let bt = getbufvar(x['bufnr'], '&buftype')
        let current = (tnr == tabpagenr()) && (x['winnr'] == winnr())
        let high = (current ? '%#TabSideBarSel#' : '%#TabSideBar#')
        let fname = fnamemodify(bufname(x['bufnr']), ':t')
        let lines += [
          \    high
          \ .. ' '
          \ .. (!empty(bt)
          \      ? printf('[%s]', bt == 'nofile' ? ft : bt)
          \      : (empty(bufname(x['bufnr']))
          \          ? '[No Name]'
          \          : fname))
          \ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
          \ ]
      endfor
      return join(lines, "\n")
    endfunction
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=16
    set tabsidebar=%!TabSideBar()
    for name in ['TabSideBar', 'TabSideBarFill', 'TabSideBarSel']
      if !hlexists(name)
        execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', name)
      endif
    endfor
  endif
  set termguicolors
  if s:is_installed('itchyny/lightline.vim')
    let g:lightline = { 'colorscheme': 'apprentice' }
  endif
  if s:is_installed('romainl/Apprentice')
    autocmd vimrc ColorScheme      *
      \ : highlight!       TabSideBar        guifg=#777777 guibg=#212121 gui=NONE cterm=NONE
      \ | highlight!       TabSideBarFill    guifg=NONE    guibg=#212121 gui=NONE cterm=NONE
      \ | highlight!       TabSideBarSel     guifg=#bcbcbc guibg=#212121 gui=NONE cterm=NONE
      \ | highlight!       TabSideBarLabel   guifg=#5f875f guibg=#212121 gui=BOLD cterm=NONE
      \ | highlight!       CursorIM          guifg=NONE    guibg=#d70000
      \ | highlight!       PopupBorder       guifg=#87875f guibg=NONE
      \ | highlight!       diffRemoved       guifg=#af5f5f guibg=NONE
      \ | highlight!       diffAdded         guifg=#5f875f guibg=NONE

    function! ColorIndents() abort
      if exists('w:colorindents')
        for x in w:colorindents
          silent! call matchdelete(x)
        endfor
      endif
      let w:colorindents = []
      let indent = '\%(' .. repeat(' ', &shiftwidth) .. '\|\t\)'
      for i in range(0, 10)
        let w:colorindents += [
          \ matchadd('Indent' .. (i % 2 + 1), '^' .. repeat(indent, i) .. '\zs' .. indent .. '\ze')
          \ ]
      endfor
    endfunction
    augroup color-indents
      autocmd!
      autocmd ColorScheme        *
        \ : highlight!   Indent1     guifg=#3a3a3a guibg=#2a2a2a
        \ | highlight!   Indent2     guifg=#3f3f3f guibg=#2f2f2f
      autocmd BufEnter,WinEnter  *
        \ : call ColorIndents()
    augroup END

    colorscheme apprentice
  endif
else
  " Check whether echo-messages are not disappeared when .vimrc is read.
  echo '.vimrc has just read!'
endif
