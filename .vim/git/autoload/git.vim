
function! git#get_rootdir(path = '.') abort
  let xs = split(fnamemodify(a:path, ':p'), '[\/]')
  let prefix = (has('mac') || has('linux')) ? '/' : ''
  while !empty(xs)
    let path = prefix .. join(xs + ['.git'], '/')
    if isdirectory(path) || filereadable(path)
      return prefix .. join(xs, '/')
    endif
    call remove(xs, -1)
  endwhile
  return ''
endfunction

function! git#get_branch_name(rootdir) abort
  let path = expand(a:rootdir .. '/.git/HEAD')
  if filereadable(path)
    for line in readfile(path)
      let m = matchlist(line, '^ref: refs/heads/\(.*\)$')
      if !empty(m)
        return m[1]
      endif
    endfor
  endif
  return ''
endfunction

function! git#set_position_of(winid, rootdir, head_regex) abort
  let curr_bufpath = ''
  if &filetype == 'diff'
    for line in getbufline('%', 1, 10)
      if line =~# '^\(+++\|---\) [ab]/'
        let curr_bufpath = line[len('+++ b/'):]
        break
      endif
    endfor
  else
    let curr_bufpath = substitute(git#fix_path(expand('%:p')), a:rootdir .. '/\?', '', '')
  endif
  if !empty(curr_bufpath)
    echo win_execute(a:winid, printf('call search(''^%s%s$'')', a:head_regex, curr_bufpath))
    echo win_execute(a:winid, 'redraw')
  endif
endfunction

function! git#fix_path(path) abort
  return substitute(a:path, '[\/]', '/', 'g')
endfunction

function! git#echo_error(msg) abort
  echohl Error
  echo printf('[git] %s!', a:msg)
  echohl None
endfunction

function! git#echo_message(msg) abort
  echohl Title
  echo printf('[git] %s!', a:msg)
  echohl None
endfunction

function! git#open_file(path, lnum, exclude_curr_win) abort
  if filereadable(a:path)
    if !s:find_window_by_path(a:path)
      const bnr = s:strict_bufnr(a:path)
      if -1 == bnr
        if a:exclude_curr_win
          new
        endif
        execute printf('edit %s', fnameescape(a:path))
      elseif &modified
        execute printf('new %s', fnameescape(a:path))
      else
        if a:exclude_curr_win
          new
        endif
        execute printf('buffer %d', bnr)
      endif
    endif
    if 0 < a:lnum
      call cursor([a:lnum, 1])
    endif
    normal! zz
  endif
endfunction

function git#popup_menu_ex(rootdir, title, lines, opts) abort
  return popup_menu(a:lines, extend({
    \   'borderchars': [nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
    \                   nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)],
    \   'borderhighlight': ['Normal'],
    \   'highlight': 'Normal',
    \   'pos': 'topleft',
    \   'line': (&lines - g:git_config.common.popupwin_maxheight) / 2,
    \   'col': (&columns - g:git_config.common.popupwin_minwidth) / 2,
    \   'title': printf(' [%s] %s ',
    \     git#get_branch_name(a:rootdir),
    \     a:title),
    \   'minheight': g:git_config.common.popupwin_minheight,
    \   'maxheight': g:git_config.common.popupwin_maxheight,
    \   'minwidth': g:git_config.common.popupwin_minwidth,
    \   'border': [1, 1, 1, 1],
    \   'padding': [0, 1, 0, 1],
    \ }, a:opts, 'force'))
endfunction

function git#git_system(cwd, subcmd) abort
  let cmd_prefix = ['git', '--no-pager']
  let lines = []
  let path = tempname()
  try
    let job = job_start(cmd_prefix + a:subcmd, {
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
  return lines
endfunction

function! git#check_git() abort
  if has('nvim') 
    call git#echo_error('This plugin can work on Vim only (not Neovim)')
    return v:false
  endif

  if !executable('git')
    call git#echo_error('Git command is not executable')
    return v:false
  endif

  if !isdirectory(git#get_rootdir())
    call git#echo_error('The current directory is not under git control')
    return v:false
  endif

  let tstatus = term_getstatus(bufnr())
  if (tstatus != 'finished') && !empty(tstatus)
    call git#echo_error('Could not open on running terminal buffer')
    return v:false
  endif

  if !empty(getcmdwintype())
    call git#echo_error('Could not open on command-line window')
    return v:false
  endif

  return v:true
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
