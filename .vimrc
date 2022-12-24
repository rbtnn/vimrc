
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

function! s:is_installed(user_and_name) abort
  let xs = split(a:user_and_name, '/')
  return !empty(globpath($VIMRC_VIM, 'github/pack/' .. xs[0] .. '/*/' .. xs[1]))
endfunction

if s:is_installed('nathanaelkane/vim-indent-guides')
  let g:indent_guides_enable_on_vim_startup = 1
  let g:indent_guides_default_mapping = 0
  let g:indent_guides_auto_colors = 0
endif

if s:is_installed('tyru/restart.vim')
  let g:restart_sessionoptions = &sessionoptions
endif

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
nnoremap <silent><C-g>    <Cmd>GitDiff<cr>

if s:is_installed('rbtnn/vim-textobj-string')
  nmap <silent>ds das
  nmap <silent>ys yas
  nmap <silent>vs vas
  if s:is_installed('kana/vim-operator-replace')
    nmap <silent>s   <Plug>(operator-replace)
    nmap <silent>ss  <Plug>(operator-replace)as
  endif
endif

if has('vim_starting')
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
      \ | highlight!       IndentGuidesOdd   guifg=#3a3a3a guibg=#2a2a2a
      \ | highlight!       IndentGuidesEven  guifg=#3f3f3f guibg=#2f2f2f
    colorscheme apprentice
  endif
endif

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

command! -nargs=0                                  FF        :call s:ff()
if executable('git')
  command! -nargs=* -complete=customlist,GitDiffComp GitDiff   :call s:gitdiff(<q-args>)
  command! -nargs=*                                  GitGrep   :call s:gitgrep(<q-args>)
endif
if executable('rg')
  command! -nargs=*                                  RipGrep   :call s:ripgrep(<q-args>)
endif
if has('win32') && executable('msbuild')
  command! -complete=customlist,MSBuildRunTaskComp -nargs=* MSBuildRunTask    :call s:msbuild_runtask(eval(g:msbuild_projectfile), <q-args>)
  command!                                         -nargs=1 MSBuildNewProject :call s:msbuild_newproject(<q-args>)
endif

let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")
let s:ff_mrw_path = get(s:, 'ff_mrw_path', expand('~/.ffmrw'))
let s:subwinid = get(s:, 'subwinid', -1)
let s:items = []

augroup ff-mrw
  autocmd!
  autocmd BufWritePost         * :call <SID>mrw_bufwritepost()
augroup END

function! s:ff() abort
  let winid = popup_menu([], s:get_popupwin_options())
  let pos = popup_getpos(winid)
  let s:subwinid = popup_create('', {
    \ 'line': pos['line'] - 3,
    \ 'col': pos['col'],
    \ 'padding': [0, 0, 0, 0],
    \ 'border': [],
    \ 'width': pos['width'] - 2,
    \ 'minwidth': pos['width'] - 2,
    \ 'title': ' SEARCH TEXT ',
    \ 'highlight': 'Normal',
    \ 'borderhighlight': repeat(['PopupBorder'], 4),
    \ 'borderchars': [
    \   nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
    \   nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)]
    \ })
  if -1 != winid
    let rootdir = s:get_rootdir('.', 'git')

    call popup_setoptions(winid, {
      \ 'filter': function('s:common_popup_filter', ['ff', rootdir, '']),
      \ 'callback': function('s:popup_callback'),
      \ })

    call s:create_context(rootdir, winid, v:false)
    call s:update_lines(rootdir, winid)
  endif
endfunction

function! s:mrw_bufwritepost() abort
  let path = s:fix_path(s:ff_mrw_path)
  let lines = s:read_mrwfile()
  let fullpath = s:fix_path(expand('<afile>'))
  if fullpath != path
    let p = v:false
    if filereadable(path)
      if filereadable(fullpath)
        if 0 < len(get(lines, 0, ''))
          if fullpath != s:fix_path(get(lines, 0, ''))
            let p = v:true
          endif
        else
          let p = v:true
        endif
      endif
    else
      let p = v:true
    endif
    if p
      call writefile([fullpath] + filter(lines, { i,x -> x != fullpath }), path)
    endif
  endif
endfunction

function! s:common_popup_filter(kind, rootdir, q_args, winid, key) abort
  let lnum = line('.', a:winid)
  if a:kind == 'gitdiff'
    if (10 == char2nr(a:key)) || (14 == char2nr(a:key)) || (106 == char2nr(a:key))
      " Ctrl-n or Ctrl-j or j
      if lnum == line('$', a:winid)
        call s:set_cursorline(a:winid, 1)
      else
        call s:set_cursorline(a:winid, lnum + 1)
      endif
      return 1
    elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key)) || (107 == char2nr(a:key))
      " Ctrl-p or Ctrl-k or k
      if lnum == 1
        call s:set_cursorline(a:winid, line('$', a:winid))
      else
        call s:set_cursorline(a:winid, lnum - 1)
      endif
      return 1
    elseif 100 == char2nr(a:key)
      " d
      call s:show_diff(a:rootdir, a:q_args, a:winid, line('.', a:winid), v:true)
      return 1
    elseif 71 == char2nr(a:key)
      " G
      call s:set_cursorline(a:winid, line('$', a:winid))
      return 1
    elseif 103 == char2nr(a:key)
      " g
      call s:set_cursorline(a:winid, 1)
      return 1
    elseif 0x0d == char2nr(a:key)
      let path = s:resolve(a:rootdir, a:winid, lnum)
      if !empty(path)
        call s:open_file(path, -1)
      endif
      return popup_filter_menu(a:winid, "\<esc>")
    endif
  else
    let xs = split(s:ctx['query'], '\zs')
    if 21 == char2nr(a:key)
      " Ctrl-u
      if 0 < len(xs)
        call remove(xs, 0, -1)
        let s:ctx['query'] = join(xs, '')
        call s:update_lines(a:rootdir, a:winid)
      endif
      return 1
    elseif 33 == char2nr(a:key)
      " !
      call s:create_context(a:rootdir, a:winid, v:true)
      call s:update_lines(a:rootdir, a:winid)
      return 1
    elseif (10 == char2nr(a:key)) || (14 == char2nr(a:key))
      " Ctrl-n or Ctrl-j
      if lnum == line('$', a:winid)
        call s:set_cursorline(a:winid, 1)
      else
        call s:set_cursorline(a:winid, lnum + 1)
      endif
      return 1
    elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
      " Ctrl-p or Ctrl-k
      if lnum == 1
        call s:set_cursorline(a:winid, line('$', a:winid))
      else
        call s:set_cursorline(a:winid, lnum - 1)
      endif
      return 1
    elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
      " Ctrl-h or bs
      if 0 < len(xs)
        call remove(xs, -1)
        let s:ctx['query'] = join(xs, '')
        call s:update_lines(a:rootdir, a:winid)
      endif
      return 1
    elseif 0x20 == char2nr(a:key)
      return popup_filter_menu(a:winid, "\<cr>")
    elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
      let xs += [a:key]
      let s:ctx['query'] = join(xs, '')
      call s:update_lines(a:rootdir, a:winid)
      return 1
    elseif 0x0d == char2nr(a:key)
      return popup_filter_menu(a:winid, "\<cr>")
    endif
  endif
  if char2nr(a:key) < 0x20
    return popup_filter_menu(a:winid, "\<esc>")
  else
    return popup_filter_menu(a:winid, a:key)
  endif
endfunction

function! s:can_open_in_current() abort
  let tstatus = term_getstatus(bufnr())
  if (tstatus != 'finished') && !empty(tstatus)
    return v:false
  elseif !empty(getcmdwintype())
    return v:false
  elseif &modified
    return v:false
  else
    return v:true
  endif
endfunction

function! s:strict_bufnr(path) abort
  let bnr = bufnr(a:path)
  let fname1 = fnamemodify(a:path, ':t')
  let fname2 = fnamemodify(bufname(bnr), ':t')
  if (-1 == bnr) || (fname1 != fname2)
    return -1
  else
    return bnr
  endif
endfunction

function! s:open_file(path, lnum) abort
  const ok = s:can_open_in_current()
  let bnr = s:strict_bufnr(a:path)
  if bufnr() == bnr
    " nop if current buffer is the same
  elseif ok
    if -1 == bnr
      execute printf('edit %s', fnameescape(a:path))
    else
      silent! execute printf('buffer %d', bnr)
    endif
  else
    execute printf('new %s', fnameescape(a:path))
  endif
  if 0 < a:lnum
    call cursor([a:lnum, 1])
  endif
endfunction

function! s:popup_callback(winid, result) abort
  if -1 != a:result
    let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
    let m = matchlist(line, '^\(.\+\)\[\(.\+\)\]$')
    if !empty(m)
      let path = expand(m[2] .. '/' .. trim(m[1]))
      if filereadable(path)
        call s:open_file(path, -1)
      endif
    endif
  endif
  if -1 != s:subwinid
    call popup_close(s:subwinid)
    let s:subwinid = -1
  endif
endfunction

function! s:read_mrwfile() abort
  let path = s:fix_path(s:ff_mrw_path)
  if filereadable(path)
    return readfile(path)
  else
    return []
  endif
endfunction

function! s:create_context(rootdir, winid, force) abort
  let s:ctx = get(s:, 'ctx', {
    \ 'lines': [],
    \ 'lsfiles_caches': {},
    \ 'query': '',
    \ })

  let s:ctx['lines'] = []

  for path in s:read_mrwfile()
    call s:extend_line(s:ctx['lines'], path)
  endfor

  for path in map(getbufinfo(), { i,x -> x['name'] })
    call s:extend_line(s:ctx['lines'], path)
  endfor

  if exists('*getscriptinfo')
    for path in map(getscriptinfo(), { i,x -> x['name'] })
      call s:extend_line(s:ctx['lines'], path)
    endfor
  endif

  if a:force || isdirectory(a:rootdir) && executable('git')
    if !has_key(s:ctx['lsfiles_caches'], a:rootdir)
      if get(s:, 'gitls_job', v:null) != v:null
        call job_stop(s:gitls_job)
        let s:gitls_job = v:null
      endif
      let s:ctx['lsfiles_caches'][a:rootdir] = []
      let s:gitls_job = job_start(['git', '--no-pager', 'ls-files'], {
        \ 'callback': function('s:job_callback', [a:rootdir, a:winid, s:ctx['lsfiles_caches'][a:rootdir]]),
        \ 'exit_cb': function('s:job_exit_cb', [a:rootdir, a:winid]),
        \ 'cwd': a:rootdir,
        \ })
    endif
  endif
endfunction

function! s:fix_path(path) abort
  return fnamemodify(resolve(a:path), ':p:gs?\\?/?')
endfunction

function! s:extend_line(lines, path) abort
  let path = s:fix_path(a:path)
  if -1 == index(a:lines, path)
    if filereadable(path)
      call extend(a:lines, [path])
    endif
  endif
endfunction

function! s:update_title(rootdir, winid) abort
  let n = line('$', a:winid)
  if empty(get(getbufline(winbufnr(a:winid), 1), 0, ''))
    let n = 0
  endif
  if empty(s:ctx['query'])
    call popup_hide(s:subwinid)
  else
    call popup_show(s:subwinid)
    call popup_settext(s:subwinid, ' ' .. s:ctx['query'] .. ' ')
  endif
endfunction

function! s:update_lines(rootdir, winid) abort
  let bnr = winbufnr(a:winid)
  let lnum = 0
  let xs = []
  let maxlen = 0
  let lines = []
  try
    silent! call deletebufline(bnr, 1, '$')
    for path in s:ctx['lines'] + get(s:ctx['lsfiles_caches'], a:rootdir, [])
      if -1 == index(lines, path)
        let lines += [path]
        let fname = fnamemodify(path, ':t')
        let dir = fnamemodify(path, ':h')
        if empty(s:ctx['query']) || (fname =~ s:ctx['query'])
          let xs += [[fname, dir]]
          if maxlen < len(fname)
            let maxlen = len(fname)
          endif
        endif
      endif
    endfor

    for x in xs
      let lnum += 1
      let d = strdisplaywidth(x[0]) - len(split(x[0], '\zs'))
      call setbufline(bnr, lnum, printf('%-' .. (maxlen + d) .. 's [%s]', x[0], x[1]))
    endfor
  catch
    echohl Error
    echo v:exception
    echohl None
  endtry

  call win_execute(a:winid, 'call clearmatches()')
  if !empty(s:ctx['query'])
    try
      call win_execute(a:winid, 'call matchadd(' .. string('IncSearch') .. ', "\\c" .. ' .. string(s:ctx['query']) .. ' .. "\\ze.*\\[.*\\]$")')
    catch
    endtry
  endif

  call s:update_title(a:rootdir, a:winid)
  call s:set_cursorline(a:winid, 1)
endfunction

function! s:set_cursorline(winid, lnum) abort
  call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
  call win_execute(a:winid, 'redraw')
endfunction

function! s:job_callback(rootdir, winid, lines, ch, msg) abort
  call s:extend_line(a:lines, a:rootdir .. '/' .. a:msg)
endfunction

function! s:job_exit_cb(rootdir, winid, ch, msg) abort
  call s:update_lines(a:rootdir, a:winid)
  call s:update_title(a:rootdir, a:winid)
endfunction

function! s:get_popupwin_options() abort
  let width = get(g:, 'git_utils_popupwin_width', 120)
  let height = get(g:, 'git_utils_popupwin_height', 30)
  let d = 0
  if has('tabsidebar')
    if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
      let d = &tabsidebarcolumns
    endif
  endif
  if &columns - d < width
    let width = &columns - d
  endif
  if &lines - &cmdheight < height
    let height = &lines - &cmdheight
  endif
  let width -= 2
  let height -= 4
  if width < 4
    let width = 4
  endif
  if height < 4
    let height = 4
  endif
  let opts = {
    \ 'wrap': 0,
    \ 'scrollbar': 0,
    \ 'highlight': 'Normal',
    \ 'minwidth': width, 'maxwidth': width,
    \ 'minheight': height, 'maxheight': height,
    \ 'pos': 'center',
    \ 'border': [0, 0, 0, 0],
    \ 'padding': [0, 0, 0, 0],
    \ }
  if has('gui_running') || (!has('win32') && !has('gui_running'))
    " ┌──┐
    " │  │
    " └──┘
    const borderchars_typeA = [
      \ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
      \ nr2char(0x250c), nr2char(0x2510), nr2char(0x2518), nr2char(0x2514)]
    " ╭──╮
    " │  │
    " ╰──╯
    const borderchars_typeB = [
      \ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
      \ nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)]
    call extend(opts, {
      \ 'border': [],
      \ 'borderhighlight': repeat(['PopupBorder'], 4),
      \ 'borderchars': borderchars_typeB,
      \ }, 'force')
  endif
  return opts
endfunction

function! s:get_rootdir(path, cmdname) abort
  let xs = split(fnamemodify(a:path, ':p'), '[\/]')
  let prefix = (has('mac') || has('linux')) ? '/' : ''
  while !empty(xs)
    let path = prefix .. join(xs + ['.' .. a:cmdname], '/')
    if isdirectory(path) || filereadable(path)
      return prefix .. join(xs, '/')
    endif
    call remove(xs, -1)
  endwhile
  return ''
endfunction

function! s:gitdiff(q_args) abort
  let rootdir = s:get_rootdir('.', 'git')
  if !isdirectory(rootdir)
    echo 'The directory is not under git control!'
  else
    let cmd = 'git --no-pager diff --numstat -w ' .. a:q_args
    let lines = s:system(cmd, rootdir)
    if empty(lines)
      echo 'No modified files!'
    else
      let winid = popup_menu(lines, s:get_popupwin_options())
      if -1 != winid
        call win_execute(winid, 'call clearmatches()')
        call win_execute(winid, 'call matchadd("diffAdded", "^\\zs\\d\\+\\ze")')
        call win_execute(winid, 'call matchadd("diffRemoved", "^\\d\\+\\s\\+\\zs\\d\\+\\ze")')
        call popup_setoptions(winid, {
          \ 'filter': function('s:common_popup_filter', ['gitdiff', rootdir, a:q_args]),
          \ 'callback': function('s:gitdiff_popup_callback', [rootdir, a:q_args]),
          \ })
      endif
    endif
  endif
endfunction

function! s:gitdiff_popup_callback(rootdir, q_args, winid, result) abort
  if -1 != a:result
    call s:show_diff(a:rootdir, a:q_args, a:winid, a:result, v:false)
  endif
endfunction

function! GitDiffComp(ArgLead, CmdLine, CursorPos) abort
  let rootdir = s:get_rootdir('.', 'git')
  let xs = ['--cached', 'HEAD']
  if isdirectory(rootdir)
    if isdirectory(rootdir .. '/.git/refs/heads')
      let xs += readdir(rootdir .. '/.git/refs/heads')
    endif
    if isdirectory(rootdir .. '/.git/refs/tags')
      let xs += readdir(rootdir .. '/.git/refs/tags')
    endif
  endif
  return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
endfunction

function! s:show_diff(rootdir, q_args, winid, lnum, stay) abort
  let path = s:resolve(a:rootdir, a:winid, a:lnum)
  if !empty(path)
    let cmd = 'git --no-pager diff -w ' .. a:q_args .. ' -- ' .. path
    call s:open_gitdiffwindow(a:rootdir, cmd, a:stay)
    call popup_setoptions(a:winid, s:get_popupwin_options())
  endif
endfunction

function! s:open_gitdiffwindow(rootdir, cmd, stay) abort
  let wnr = winnr()
  let lnum = line('.')

  let exists = v:false
  for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
    if getbufvar(w['bufnr'], '&filetype', '') == 'diff'
      execute printf('%dwincmd w', w['winnr'])
      let exists = v:true
      break
    endif
  endfor
  if !exists
    if &lines < &columns / 2
      botright vnew
    else
      botright new
    endif
    setfiletype diff
    setlocal nolist
  endif

  let lines = s:system(a:cmd, a:rootdir)

  let &l:statusline = a:cmd
  call s:setbuflines(lines)
  let b:diffview = {
    \ 'cmd': a:cmd,
    \ 'rootdir': a:rootdir,
    \ }

  nnoremap         <buffer><cr>  <Cmd>call <SID>jumpdiffline(b:diffview['rootdir'])<cr>
  nnoremap         <buffer>R     <Cmd>call <SID>open_gitdiffwindow(b:diffview['rootdir'], b:diffview['cmd'], v:true)<cr>

  " Redraw windows because the encoding process is very slowly.
  redraw

  " The lines encodes after redrawing.
  for i in range(0, len(lines) - 1)
    let lines[i] = qficonv#encoding#iconv_utf8(lines[i], 'shift_jis')
  endfor
  call s:setbuflines(lines)

  if a:stay
    execute printf(':%dwincmd w', wnr)
    call cursor(lnum, 0)
  endif
endfunction

function! s:setbuflines(lines) abort
  setlocal modifiable noreadonly
  silent! call deletebufline(bufnr(), 1, '$')
  call setbufline(bufnr(), 1, a:lines)
  setlocal buftype=nofile nomodifiable readonly
endfunction

function! s:jumpdiffline(rootdir) abort
  let x = s:calc_lnum(a:rootdir)
  if !empty(x)
    if filereadable(x['path'])
      if s:find_window_by_path(x['path'])
        execute printf(':%d', x['lnum'])
      else
        new
        call s:open_file(x['path'], x['lnum'])
      endif
    endif
    normal! zz
  endif
endfunction

function! s:calc_lnum(rootdir) abort
  let lines = getbufline(bufnr(), 1, '$')
  let curr_lnum = line('.')
  let lnum = -1
  let relpath = ''

  for m in range(curr_lnum, 1, -1)
    if lines[m - 1] =~# '^@@'
      let lnum = m
      break
    endif
  endfor
  for m in range(curr_lnum, 1, -1)
    if lines[m - 1] =~# '^+++ '
      let relpath = matchstr(lines[m - 1], '^+++ \zs.\+$')
      let relpath = substitute(relpath, '^b/', '', '')
      let relpath = substitute(relpath, '\s\+(working copy)$', '', '')
      let relpath = substitute(relpath, '\s\+(revision \d\+)$', '', '')
      break
    endif
  endfor

  if (lnum < curr_lnum) && (0 < lnum)
    let n1 = 0
    let n2 = 0
    for n in range(lnum + 1, curr_lnum)
      let line = lines[n - 1]
      if line =~# '^-'
        let n2 += 1
      elseif line =~# '^+'
        let n1 += 1
      endif
    endfor
    let n3 = curr_lnum - lnum - n1 - n2 - 1
    let m = []
    let m2 = matchlist(lines[lnum - 1], '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\?\s*@@\(.*\)$')
    let m3 = matchlist(lines[lnum - 1], '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
    if !empty(m2)
      let m = m2
    elseif !empty(m3)
      let m = m3
    endif
    if !empty(m)
      for i in [1, 3, 5]
        if '+' == m[i]
          let lnum = str2nr(m[i + 1]) + n1 + n3
          return { 'lnum': lnum, 'path': expand(a:rootdir .. '/' .. relpath) }
        endif
      endfor
    endif
  endif

  return {}
endfunction

function! s:find_window_by_path(path) abort
  for x in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
    if x['bufnr'] == s:strict_bufnr(a:path)
      execute printf(':%dwincmd w', x['winnr'])
      return v:true
    endif
  endfor
  return v:false
endfunction

function! s:resolve(rootdir, winid, lnum) abort
  let line = get(getbufline(winbufnr(a:winid), a:lnum), 0, '')
  if !empty(line)
    let path = expand(a:rootdir .. '/' .. trim(get(split(line, "\t") ,2, '')))
    if filereadable(path)
      return path
    endif
  endif
  return ''
endfunction

function s:system(cmd, cwd) abort
  let lines = []
  if has('nvim')
    let job = jobstart(a:cmd, {
      \ 'cwd': a:cwd,
      \ 'on_stdout': function('s:system_onevent', [{ 'lines': lines, }]),
      \ 'on_stderr': function('s:system_onevent', [{ 'lines': lines, }]),
      \ })
    call jobwait([job])
  else
    let path = tempname()
    try
      let job = job_start(a:cmd, {
        \ 'cwd': a:cwd,
        \ 'out_io': 'file',
        \ 'out_name': path,
        \ 'err_io': 'out',
        \ })
      while 'run' == job_status(job)
      endwhile
      if filereadable(path)
        let lines = readfile(path)
      endif
    finally
      if filereadable(path)
        call delete(path)
      endif
    endtry
  endif
  return lines
endfunction

function s:system_onevent(d, job, data, event) abort
  let a:d['lines'] += a:data
  sleep 10m
endfunction

function! s:gitgrep(q_args) abort
  let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n', '--column'] + split(a:q_args, '\s\+')
  call s:qfjob_start('git grep', cmd, function('s:gitgrep_line_parser'))
endfunction

function s:gitgrep_line_parser(line) abort
  let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
  if !empty(m)
    let path = m[1]
    if !filereadable(path) && (path !~# '^[A-Z]:')
      let path = expand(fnamemodify(path, ':h') .. '/' .. m[1])
    endif
    return s:qfjob_match(path, m[2], m[3], m[4])
  else
    return s:qfjob_do_not_match(a:line)
  endif
endfunction

function! s:qfjob_start(title, cmd, line_parser, ...) abort
  let keep_cursor = get(a:000, 0, v:false)
  call s:qfjob_stop()
  cclose
  let s:qfjob = job_start(a:cmd, {
    \ 'exit_cb': function('s:exit_cb', [a:title, a:line_parser, keep_cursor]),
    \ 'out_cb': function('s:out_cb'),
    \ 'err_io': 'out',
    \ })
endfunction

function! s:qfjob_stop() abort
  if s:qfjob != v:null
    if 'run' == job_status(s:qfjob)
      call job_stop(s:qfjob, 'kill')
    endif
  endif
  let s:qfjob = v:null
  let s:items = []
endfunction

function! s:qfjob_match(path, lnum, col, text) abort
  return {
    \ 'filename': s:iconv(a:path),
    \ 'lnum': a:lnum,
    \ 'col': a:col,
    \ 'text': s:iconv(a:text),
    \ }
endfunction

function! s:qfjob_do_not_match(line) abort
  return { 'text': s:iconv(a:line), }
endfunction

function s:iconv(text) abort
  if exists('g:loaded_qficonv') && (len(a:text) < 500)
    return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
  else
    return a:text
  endif
endfunction

function s:out_cb(ch, msg) abort
  let s:items += [a:msg]
endfunction

function s:exit_cb(title, line_parser, keep_cursor, job, status) abort
  let xs = []
  try
    for item in s:items
      let p = len(xs) * 100 / len(s:items)
      let xs += [a:line_parser(item)]
      redraw
      echo printf('[%s] The job has finished! Please wait for building the quickfix... (%d%%)', a:title, p)
    endfor
  catch /^Vim:Interrupt$/
    redraw
    echo printf('[%s] Interrupt!', a:title)
  finally
    call setqflist(xs)
    let bnr = bufnr()
    silent! copen
    if a:keep_cursor
      call win_gotoid(bufwinid(bnr))
    endif
    call s:qfjob_stop()
  endtry
endfunction

function! s:ripgrep(q_args) abort
  let cmd = ['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
  call s:qfjob_start('ripgrep', cmd, function('s:ripgrep_line_parser'))
endfunction

function s:ripgrep_line_parser(line) abort
  let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
  if !empty(m)
    let path = m[1]
    if !filereadable(path) && (path !~# '^[A-Z]:')
      let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
    endif
    return s:qfjob_match(path, m[2], m[3], m[4])
  else
    return s:qfjob_do_not_match(a:line)
  endif
endfunction

function! s:msbuild_runtask(projectfile, args) abort
  if type([]) == type(a:args)
    let cmd = ['msbuild']
    if filereadable(a:projectfile)
      let cmd += ['/nologo', a:projectfile] + a:args
    else
      let cmd += ['/nologo'] + a:args
    endif
  else
    let cmd = printf('msbuild /nologo %s %s', a:args, a:projectfile)
  endif
  call s:qfjob_start('msbuild', cmd, function('s:msbuild_runtask_line_parser', [a:projectfile]))
endfunction

function s:msbuild_runtask_line_parser(projectfile, line) abort
  let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
  if !empty(m)
    let path = m[1]
    if !filereadable(path) && (path !~# '^[A-Z]:')
      let path = expand(fnamemodify(a:projectfile, ':h') .. '/' .. m[1])
    endif
    return s:qfjob_match(path, m[2], m[3], m[4])
  else
    return s:qfjob_do_not_match(a:line)
  endif
endfunction

function! MSBuildRunTaskComp(A, L, P) abort
  let xs = []
  let path = eval(g:msbuild_projectfile)
  if filereadable(path)
    for line in readfile(path)
      let m = matchlist(line, '<Target\s\+Name="\([^"]\+\)"')
      if !empty(m)
        let xs += ['/t:' .. m[1]]
      endif
    endfor
  endif
  return xs
endfunction

function! s:msbuild_newproject(q_args) abort
  const projectname = trim(a:q_args)
  if isdirectory(projectname)
    echohl Error
    echo   'The directory already exists: ' .. string(projectname)
    echohl None
  elseif projectname =~# '^[a-zA-Z0-9_-]\+$'
    call mkdir(expand(projectname .. '/src'), 'p')
    call writefile([
      \   "using System;",
      \   "using System.IO;",
      \   "using System.Text;",
      \   "using System.Text.RegularExpressions;",
      \   "using System.Collections.Generic;",
      \   "using System.Linq;",
      \   "",
      \   "class Prog {",
      \   "\tstatic void Main(string[] args) {",
      \   "\t\tConsole.WriteLine(\"Hello\");",
      \   "\t}",
      \   "}",
      \ ], expand(projectname .. '/src/Main.cs'))
    call writefile([
      \   "<Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">",
      \   "\t<PropertyGroup>",
      \   "\t\t<AssemblyName>Main.exe</AssemblyName>",
      \   "\t\t<OutputPath>bin\\</OutputPath>",
      \   "\t\t<OutputType>exe</OutputType>",
      \   "\t\t<References></References>",
      \   "\t</PropertyGroup>",
      \   "\t<ItemGroup>",
      \   "\t\t<Compile Include=\"src\\*.cs\" />",
      \   "\t</ItemGroup>",
      \   "\t<Target Name=\"Build\">",
      \   "\t\t<MakeDir Directories=\"$(OutputPath)\" Condition=\"!Exists('$(OutputPath)')\" />",
      \   "\t\t<Csc",
      \   "\t\t\tSources=\"@(Compile)\"",
      \   "\t\t\tTargetType=\"$(OutputType)\"",
      \   "\t\t\tReferences=\"$(References)\"",
      \   "\t\t\tOutputAssembly=\"$(OutputPath)$(AssemblyName)\" />",
      \   "\t</Target>",
      \   "\t<Target Name=\"Run\" >",
      \   "\t\t<Exec Command=\"$(OutputPath)$(AssemblyName)\" />",
      \   "\t</Target>",
      \   "\t<Target Name=\"Clean\" >",
      \   "\t\t<Delete Files=\"$(OutputPath)$(AssemblyName)\" />",
      \   "\t</Target>",
      \   "</Project>",
      \ ], expand(projectname .. '/msbuild.xml'))
    echo 'Made new proect: ' .. string(projectname)
  else
    echohl Error
    echo   'Invalid the project name: ' .. string(projectname)
    echohl None
  endif
endfunction
