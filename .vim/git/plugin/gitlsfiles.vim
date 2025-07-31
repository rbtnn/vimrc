let g:loaded_gitlsfiles = 1

let s:PROMPT_LNUM = 1
let s:PROMPT_STRING = '>'
let s:PROMPT_CURSOR = '|'
let s:WIDTH = 60
let s:HEIGHT = 7

let s:PROMPT_CACHES = get(s:, 'PROMPT_CACHES', {})

command! -bang -nargs=0 GitLsFiles :call s:main(<q-bang>) 

function! s:main(q_bang) abort
  if has('nvim') 
    call gitdiff#echo_error('The feature can work on Vim(not Neovim)')
  else
    let tstatus = term_getstatus(bufnr())
    let rootdir = gitdiff#get_rootdir()
    if !isdirectory(rootdir)
      call gitdiff#echo_error('The directory is not under git control')
    elseif !executable('git')
      call gitdiff#echo_error('Git is not executable')
    elseif (tstatus != 'finished') && !empty(tstatus)
      call gitdiff#echo_error('Could not open on running terminal buffer')
    elseif !empty(getcmdwintype())
      call gitdiff#echo_error('Could not open on command-line window')
    elseif &modified
      call gitdiff#echo_error('Could not open on modified buffer')
    else
      let d = s:build_path2status()
      let winid = popup_menu([], {
        \ 'filter': function('s:popup_filter', [rootdir, d]),
        \ 'callback': function('s:popup_callback', [rootdir]),
        \ 'pos': 'center',
        \ 'minheight': s:HEIGHT,
        \ 'maxheight': s:HEIGHT,
        \ 'minwidth': s:WIDTH,
        \ 'wrap': 0,
        \ 'scrollbar': 0,
        \ 'border': [1, 1, 1, 1],
        \ 'padding': [0, 0, 0, 0],
        \ })
      call s:set_prompt(winid, rootdir, get(s:PROMPT_CACHES, rootdir, ''))
      call s:update_window_async(rootdir, winid, d)
    endif
  endif
endfunction

function! s:get_branch_name(rootdir) abort
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

function! s:get_github_url(rootdir) abort
  let path = expand(a:rootdir .. '/.git/config')
  let curr_branch = ''
  if filereadable(path)
    for line in readfile(path)
      let m1 = matchlist(line, '^\[.*"\(.*\)"\]$')
      let m2 = matchlist(line, '^\s*url = \(.*\)$')
      if !empty(m1)
        let curr_branch = m1[1]
      elseif !empty(m2)
        if 'origin' == curr_branch
          return m2[1]
        endif
      endif
    endfor
  endif
  return ''
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
      call s:set_cursorline(a:winid, s:PROMPT_LNUM + 1)
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
  if filereadable(path)
    let bnr = s:strict_bufnr(path)
    if -1 == bnr
      execute printf('edit %s', fnameescape(path))
    else
      execute printf('buffer %d', bnr)
    endif
  endif
endfunction

function! s:update_window_async(rootdir, winid, d) abort
  if exists('s:job')
    call job_stop(s:job)
    unlet s:job
  endif
  let count_ref = [0]
  let bnr = winbufnr(a:winid)
  let query = s:get_query_from_prompt(a:winid)
  silent! call deletebufline(bnr, s:PROMPT_LNUM + 1, '$')
  let s:job = job_start(['git', '--no-pager', 'ls-files'], {
    \ 'callback': function('s:job_callback', [count_ref, a:winid, a:rootdir, bnr, query, a:d]),
    \ 'exit_cb': function('s:job_exit_cb', [count_ref, a:winid, a:rootdir]),
    \ 'cwd': a:rootdir,
    \ })
  call win_execute(a:winid, 'call clearmatches()')
  call win_execute(a:winid, printf('call matchadd("Title", %s)', string('\%1l' .. '^' .. s:PROMPT_STRING)))
  call win_execute(a:winid, printf('call matchadd("Directory", %s)', string('\%1l' .. s:PROMPT_CURSOR .. '$')))
  call win_execute(a:winid, printf('call matchadd("ErrorMsg", %s)', string('\%>1l[ MADRCU]\{2,2\} ')))
  try
    if !empty(query)
      call win_execute(a:winid, printf('call matchadd("Search", %s)', string('\%>1l' .. query)))
    endif
  catch
  endtry
endfunction

function! s:job_exit_cb(count_ref, winid, rootdir, ch, status) abort
  let curr_lnum = line('.', a:winid)
  if curr_lnum == s:PROMPT_LNUM
    call s:set_cursorline(a:winid, s:PROMPT_LNUM + 1)
  endif
  let bnr = winbufnr(a:winid)
  let lines = getbufline(bnr, s:PROMPT_LNUM + 1, '$')
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
  call setbufline(bnr, s:PROMPT_LNUM + 1, lines)
  call popup_setoptions(a:winid, {
    \ 'title': printf(' [%s branch/%d files] %s ', s:get_branch_name(a:rootdir), a:count_ref[0], s:get_github_url(a:rootdir)),
    \ })
endfunction

function! s:job_callback(count_ref, winid, rootdir, bnr, query, d, ch, line) abort
  try
    let a:count_ref[0] += 1
    let last_lnum = line('$', a:winid)
    if last_lnum < s:HEIGHT
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
  call setbufline(bnr, s:PROMPT_LNUM, s:PROMPT_STRING .. a:query .. s:PROMPT_CURSOR)
  let s:PROMPT_CACHES[a:rootdir] = a:query
endfunction

function! s:get_query_from_prompt(winid) abort
  let bnr = winbufnr(a:winid)
  return getbufline(bnr, s:PROMPT_LNUM)[0][1:-2]
endfunction

function! s:set_cursorline(winid, lnum) abort
  call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
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

function! s:build_path2status() abort
  let d = {}
  for line in gitdiff#git_system(gitdiff#get_rootdir(), ['status', '-s'])
    let m = matchlist(line, '^\(..\) \(.*\)$')
    if !empty(m)
      let d[m[2]] = trim(m[1])
    endif
  endfor
  return d
endfunction

