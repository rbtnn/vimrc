let s:special_buffer = 'gitdiff_special_buffer'

function! gitdiff#unifieddiff#exec(q_args) abort
  let rootdir = gitdiff#get_rootdir()
  if !gitdiff#check_git(rootdir)
    return
  endif

  let cmd = ['diff', '--numstat'] + split(a:q_args, '\s\+')
  let lines = gitdiff#git_system(rootdir, cmd)
  if empty(lines)
    call gitdiff#echo_error('No modified files!')
  else
    if get(g:, 'gitdiff_use_popupwin', v:true)
      let curr_bufpath = ''
      if &filetype == 'diff'
        for line in getbufline('%', 1, 10)
          if line =~# '^\(+++\|---\) [ab]/'
            let curr_bufpath = line[len('+++ b/'):]
            break
          endif
        endfor
      else
        let curr_bufpath = substitute(expand('%:p'), rootdir .. '/\?', '', '')
      endif
      let winid = popup_menu(lines, {
        \   'padding': [1, 1, 1, 1],
        \   'title': printf(' %s ', join(['git'] + cmd)),
        \   'maxwidth': &columns * 2 / 3,
        \   'maxheight': &lines * 2 / 3,
        \   'callback': function('s:selected', [a:q_args, rootdir, lines]),
        \ })
      call win_execute(winid, 'runtime syntax/diff.vim')
      call win_execute(winid, 'call matchadd("diffAdded", "^\\d\\+")')
      call win_execute(winid, 'call matchadd("diffRemoved", "^\\d\\+\\t\\zs\\d\\+")')
      if !empty(curr_bufpath)
        echo win_execute(winid, printf('call search(''^\d\+\t\d\+\t%s$'')', curr_bufpath))
        echo win_execute(winid, 'redraw')
      endif
    else
      call s:open_special_buffer('numstat', lines)
      execute printf('nnoremap <buffer><cr>    <Cmd>call <SID>show_diff(%s,%s, getline("."))<cr>', string(a:q_args), string(rootdir))
      execute printf('nnoremap <buffer>!       <Cmd>call <SID>gitdiff#unifieddiff#exec(%s)<cr>', string(a:q_args))
    endif
  endif
endfunction



function! s:selected(q_args, rootdir, lines, id, result) abort
  if -1 != a:result
    call s:show_diff(a:q_args, a:rootdir, a:lines[a:result - 1])
  endif
endfunction

function! s:open_special_buffer(btype, lines) abort
  let wnr = winnr()
  let lnum = line('.')

  let exists = v:false
  for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
    if getbufvar(w['bufnr'], s:special_buffer, 0)
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
  endif

  call setbufvar(bufnr(), s:special_buffer, 1)
  setlocal nolist
  execute 'setfiletype ' .. a:btype

  if empty(a:lines)
    close
  else
    setlocal modifiable noreadonly
    silent! call deletebufline(bufnr(), 1, '$')
    call setbufline(bufnr(), 1, a:lines)
    setlocal buftype=nofile nomodifiable readonly
  endif
endfunction

function! s:show_diff(q_args, rootdir, line) abort
  let path = trim(get(split(a:line, "\t") ,2, ''))
  call s:show_diff_with_path(a:q_args, a:rootdir, path)
endfunction

function! s:show_diff_with_path(q_args, rootdir, path) abort
  let path = gitdiff#fix_path(expand(a:rootdir .. '/' .. a:path))
  if filereadable(path)
    let lines = gitdiff#git_system(a:rootdir, ['--no-pager', 'diff'] + split(a:q_args, '\s\+') + ['--', path])
    call s:open_special_buffer('diff', lines)
    if !empty(lines)
      execute printf('nnoremap <buffer><cr>  <Cmd>call <SID>jump_diffline(%s)<cr>', string(a:rootdir))
      execute printf('nnoremap <buffer>!     <Cmd>call <SID>show_diff_with_path(%s,%s,%s)<cr>', string(a:q_args), string(a:rootdir), string(a:path))
    endif
  endif
endfunction

function! s:jump_diffline(rootdir) abort
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

function! s:find_window_by_path(path) abort
  for x in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
    if x['bufnr'] == s:strict_bufnr(a:path)
      execute printf(':%dwincmd w', x['winnr'])
      return v:true
    endif
  endfor
  return v:false
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

