 
function! git#lsfiles#exec(q_bang) abort
  if !git#check_git()
    return
  endif

  let rootdir = git#get_rootdir()
  let d = s:build_path2status()
  let winid = popup_menu([], {
    \   'filter': function('s:popup_filter', [rootdir, d]),
    \   'callback': function('s:popup_callback', [rootdir]),
    \   'wrap': 0,
    \   'scrollbar': 0,
    \   'title': printf(' [%s] %s ',
    \     git#get_branch_name(rootdir),
    \     git#get_github_url(rootdir, 'origin')),
    \   'minheight': g:git_config.common.popupwin_minheight,
    \   'maxheight': g:git_config.common.popupwin_maxheight,
    \   'minwidth': g:git_config.common.popupwin_minwidth,
    \   'border': g:git_config.common.popupwin_border,
    \   'padding': g:git_config.common.popupwin_padding,
    \ })
  call s:set_prompt(winid, rootdir, get(g:git_config.lsfiles.caches, rootdir, ''))
  call s:update_window_async(rootdir, winid, d)
endfunction



function! s:popup_filter(rootdir, d, winid, key) abort
  let xs = split(s:get_query_from_prompt(a:winid), '\zs')
  let lnum = line('.', a:winid)
  if 21 == char2nr(a:key)
    " Ctrl-u
    if 0 < len(xs)
      call remove(xs, 0, -1)
      call s:set_prompt(a:winid, a:rootdir, join(xs, ''))
      call s:update_window_async(a:rootdir, a:winid, a:d)
    endif
    return 1
  elseif 10 == char2nr(a:key) || 14 == char2nr(a:key)
    " Ctrl-j or Ctrl-n
    if lnum == line('$', a:winid)
      call s:set_cursorline(a:winid, g:git_config.lsfiles.prompt_lnum + 1)
    else
      call s:set_cursorline(a:winid, lnum + 1)
    endif
    return 1
  elseif 11 == char2nr(a:key) || 16 == char2nr(a:key)
    " Ctrl-k or Ctrl-p
    if lnum == 1 || lnum == 2
      call s:set_cursorline(a:winid, line('$', a:winid))
    else
      call s:set_cursorline(a:winid, lnum - 1)
    endif
    return 1
  elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
    " Ctrl-h or bs
    if 0 < len(xs)
      call remove(xs, -1)
      call s:set_prompt(a:winid, a:rootdir, join(xs, ''))
      call s:update_window_async(a:rootdir, a:winid, a:d)
    endif
    return 1
  elseif (0x20 == char2nr(a:key)) && (0 == len(xs))
    return 1
  elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
    let xs += [a:key]
    call s:set_prompt(a:winid, a:rootdir, join(xs, ''))
    call s:update_window_async(a:rootdir, a:winid, a:d)
    return 1
  else
    return popup_filter_menu(a:winid, a:key)
  endif
endfunction

function! s:popup_callback(rootdir, winid, result) abort
  let line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
  let path = a:rootdir .. '/' .. trim(line[3:])
  call git#open_file(path, -1, v:false)
endfunction

function! s:update_window_async(rootdir, winid, d) abort
  if exists('s:job')
    call job_stop(s:job)
    unlet s:job
  endif
  let bnr = winbufnr(a:winid)
  let query = s:get_query_from_prompt(a:winid)
  silent! call deletebufline(bnr, g:git_config.lsfiles.prompt_lnum + 1, '$')
  let s:job = job_start(['git', '--no-pager', 'ls-files'], {
    \ 'callback': function('s:job_callback', [a:winid, a:rootdir, bnr, query, a:d]),
    \ 'exit_cb': function('s:job_exit_cb', [a:winid, a:rootdir]),
    \ 'cwd': a:rootdir,
    \ })
  call win_execute(a:winid, 'call clearmatches()')
  call win_execute(a:winid, printf('call matchadd("Title", %s)', string('\%1l' .. '^' .. g:git_config.lsfiles.prompt_string)))
  call win_execute(a:winid, printf('call matchadd("Directory", %s)', string('\%1l' .. g:git_config.lsfiles.prompt_cursor .. '$')))
  call win_execute(a:winid, printf('call matchadd("ErrorMsg", %s)', string('\%>1l[ MADRCU]\{2,2\} ')))
  try
    if !empty(query)
      call win_execute(a:winid, printf('call matchadd("Search", %s)', string('\%>1l' .. query)))
    endif
  catch
  endtry
endfunction

function! s:job_exit_cb(winid, rootdir, ch, status) abort
  let curr_lnum = line('.', a:winid)
  if curr_lnum == g:git_config.lsfiles.prompt_lnum
    call s:set_cursorline(a:winid, g:git_config.lsfiles.prompt_lnum + 1)
  endif
  let bnr = winbufnr(a:winid)
  let lines = getbufline(bnr, g:git_config.lsfiles.prompt_lnum + 1, '$')
  for j in range(0, len(lines) - 1)
    let jv = len(trim(lines[j][:3]))
    for k in range(0, len(lines) - 1)
      let kv = len(trim(lines[k][:3]))
      if j < k && jv < kv
        let temp = lines[j]
        let lines[j] = lines[k]
        let lines[k] = temp
      endif
    endfor
  endfor
  call setbufline(bnr, g:git_config.lsfiles.prompt_lnum + 1, lines)
  call git#set_position_of(a:winid, a:rootdir, '...')
endfunction

function! s:job_callback(winid, rootdir, bnr, query, d, ch, line) abort
  try
    let last_lnum = line('$', a:winid)
    if last_lnum < g:git_config.common.popupwin_maxheight
      if empty(a:query) || (a:line =~ a:query)
        let status = ''
        if has_key(a:d, a:line)
          let status = a:d[a:line]
        endif
        let line = getbufline(a:bnr, last_lnum)[0]
        if empty(line)
          call setbufline(a:bnr, last_lnum, printf('%2s %s', status, a:line))
        else
          call appendbufline(a:bnr, last_lnum, printf('%2s %s', status, a:line))
        endif
      endif
    endif
  catch
  endtry
endfunction

function! s:set_prompt(winid, rootdir, query) abort
  let bnr = winbufnr(a:winid)
  call setbufline(bnr, g:git_config.lsfiles.prompt_lnum, g:git_config.lsfiles.prompt_string .. a:query .. g:git_config.lsfiles.prompt_cursor)
  let g:git_config.lsfiles.caches[a:rootdir] = a:query
endfunction

function! s:get_query_from_prompt(winid) abort
  let bnr = winbufnr(a:winid)
  return getbufline(bnr, g:git_config.lsfiles.prompt_lnum)[0][1:-2]
endfunction

function! s:set_cursorline(winid, lnum) abort
  call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
endfunction

function! s:build_path2status() abort
  let d = {}
  for line in git#git_system(git#get_rootdir(), ['status', '-s'])
    let m = matchlist(line, '^\(..\) \(.*\)$')
    if !empty(m)
      let d[m[2]] = trim(m[1])
    endif
  endfor
  return d
endfunction
