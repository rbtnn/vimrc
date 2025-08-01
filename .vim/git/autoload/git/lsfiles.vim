
function! git#lsfiles#exec(q_bang) abort
  if !git#check_git()
    return
  endif

  let ctx = s:make_context()
  const winid = git#popup_menu_ex(ctx.rootdir, ctx.rootdir, [], {
    \   'filter': function('s:popup_filter', [ctx]),
    \   'callback': function('s:popup_callback', [ctx]),
    \   'wrap': 0,
    \   'scrollbar': 1,
    \ })
  call s:set_prompt(winid, ctx, get(g:git_config.lsfiles.prompt_caches, ctx.rootdir, ''))
  call s:update_window_async(winid, ctx)
endfunction



function! s:popup_filter(ctx, winid, key) abort
  let xs = split(a:ctx.query, '\zs')
  const lnum = line('.', a:winid)
  if 21 == char2nr(a:key)
    " Ctrl-u
    if 0 < len(xs)
      call remove(xs, 0, -1)
      call s:set_prompt(a:winid, a:ctx, join(xs, ''))
      call s:update_window_async(a:winid, a:ctx)
    endif
    return 1
  elseif 4 == char2nr(a:key)
    " Ctrl-d
    const line = get(getbufline(winbufnr(a:winid), lnum), 0, '')
    call git#unifieddiff#show_diff_with_path(
      \ g:git_config.lsfiles.diff_args,
      \ trim(line[3:]))
    return 1
  elseif 10 == char2nr(a:key) || 14 == char2nr(a:key)
    " Ctrl-j or Ctrl-n
    if lnum == line('$', a:winid)
      call s:set_cursorline(a:winid, g:git_config.lsfiles.prompt_lnum)
    else
      call s:set_cursorline(a:winid, lnum + 1)
    endif
    return 1
  elseif 11 == char2nr(a:key) || 16 == char2nr(a:key)
    " Ctrl-k or Ctrl-p
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
      call s:set_prompt(a:winid, a:ctx, join(xs, ''))
      call s:update_window_async(a:winid, a:ctx)
    endif
    return 1
  elseif (0x20 == char2nr(a:key)) && (0 == len(xs))
    return 1
  elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
    let xs += [a:key]
    call s:set_prompt(a:winid, a:ctx, join(xs, ''))
    call s:update_window_async(a:winid, a:ctx)
    return 1
  else
    return popup_filter_menu(a:winid, a:key)
  endif
endfunction

function! s:popup_callback(ctx, winid, result) abort
  if g:git_config.lsfiles.prompt_lnum != a:result && -1 != a:result
    const line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
    const path = a:ctx.rootdir .. '/' .. trim(line[3:])
    call git#open_file(path, -1, v:false)
  endif
endfunction

function! s:update_window_async(winid, ctx) abort
  if exists('s:job')
    call job_stop(s:job)
    unlet s:job
  endif
  const query = a:ctx.query
  let a:ctx.lines = []
  let s:job = job_start(['git', '--no-pager', 'ls-files'], {
    \ 'callback': function('s:job_callback', [a:winid, a:ctx]),
    \ 'exit_cb': function('s:job_exit_cb', [a:winid, a:ctx]),
    \ 'cwd': a:ctx.rootdir,
    \ })
endfunction

function! s:job_exit_cb(winid, ctx, ch, status) abort
  const bnr = winbufnr(a:winid)
  silent! call deletebufline(bnr, len(a:ctx.lines) + 2, '$')
  call win_execute(a:winid, 'call clearmatches()')
  call win_execute(a:winid, printf('call matchadd("Title", %s)', string('\%1l' .. '^' .. g:git_config.lsfiles.prompt_string)))
  call win_execute(a:winid, printf('call matchadd("Directory", %s)', string('\%1l' .. g:git_config.lsfiles.prompt_cursor .. '$')))
  call win_execute(a:winid, printf('call matchadd("ErrorMsg", %s)', string('\%>1l[ MADRCU]\{2,2\} ')))
  try
    if !empty(a:ctx.query)
      call win_execute(a:winid, printf('call matchadd("Search", %s)', string('\%>1l' .. a:ctx.query)))
    endif
  catch
  endtry
  call s:set_cursorline(a:winid, g:git_config.lsfiles.prompt_lnum)
  call git#set_position_of(a:winid, a:ctx.rootdir, '...')
  if line('.', a:winid) <= g:git_config.lsfiles.prompt_lnum
    call s:set_cursorline(a:winid, g:git_config.lsfiles.prompt_lnum + 1)
    call win_execute(a:winid, 'redraw')
  endif
endfunction

function! s:job_callback(winid, ctx, ch, line) abort
  const bnr = winbufnr(a:winid)
  const last_lnum = len(a:ctx.lines) + 1
  if last_lnum < g:git_config.lsfiles.max_displayed
    const status = has_key(a:ctx.status, a:line) ? a:ctx.status[a:line] : ''
    const display_line = printf('%2s %s', status, a:line)
    if empty(a:ctx.query) || (display_line =~ a:ctx.query)
      call appendbufline(bnr, last_lnum, display_line)
      let a:ctx.lines += [display_line]
    endif
  endif
endfunction

function! s:set_prompt(winid, ctx, new_query) abort
  call setbufline(
    \ winbufnr(a:winid),
    \ g:git_config.lsfiles.prompt_lnum,
    \ g:git_config.lsfiles.prompt_string .. a:new_query .. g:git_config.lsfiles.prompt_cursor)
  let a:ctx.query = a:new_query
  let g:git_config.lsfiles.prompt_caches[a:ctx.rootdir] = a:new_query
endfunction

function! s:set_cursorline(winid, lnum) abort
  call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
endfunction

function! s:make_context() abort
  let ctx = {
    \   'rootdir': git#get_rootdir(),
    \   'status': {},
    \   'lines': [],
    \   'query': '',
    \ }
  for line in git#git_system(ctx.rootdir, ['status', '-s'])
    let m = matchlist(line, '^\(..\) \(.*\)$')
    if !empty(m)
      let ctx.status[m[2]] = trim(m[1])
    endif
  endfor
  return ctx
endfunction
