
function! git#unifieddiff#exec(q_args) abort
  if !git#check_git()
    return
  endif

  let rootdir = git#get_rootdir()
  let cmd = ['diff', '--numstat'] + split(a:q_args, '\s\+')
  let lines = git#git_system(rootdir, cmd)
  if empty(lines)
    call git#echo_error('No modified files!')
  else
    let winid = git#popup_menu_ex(rootdir, join(['git'] + cmd), lines, {
      \   'filter': function('s:popup_filter'),
      \   'callback': function('s:popup_callback', [a:q_args, rootdir, lines]),
      \ })
    call win_execute(winid, 'runtime syntax/diff.vim')
    call win_execute(winid, 'call matchadd("diffAdded", "^\\d\\+")')
    call win_execute(winid, 'call matchadd("diffRemoved", "^\\d\\+\\t\\zs\\d\\+")')
    call git#set_position_of(winid, rootdir, '\d\+\t\d\+\t')
  endif
endfunction



function! s:popup_filter(winid, key) abort
  if 10 == char2nr(a:key) || 14 == char2nr(a:key)
    " Ctrl-j or Ctrl-n
    return popup_filter_menu(a:winid, 'j')
  elseif 11 == char2nr(a:key) || 16 == char2nr(a:key)
    " Ctrl-k or Ctrl-p
    return popup_filter_menu(a:winid, 'k')
  else
    return popup_filter_menu(a:winid, a:key)
  endif
endfunction

function! s:popup_callback(q_args, rootdir, lines, id, result) abort
  if -1 != a:result
    let path = trim(get(split(a:lines[a:result - 1], "\t") ,2, ''))
    call s:show_diff_with_path(a:q_args, a:rootdir, path)
  endif
endfunction

function! s:show_diff_with_path(q_args, rootdir, path) abort
  let path = git#fix_path(expand(a:rootdir .. '/' .. a:path))
  if filereadable(path)
    let lines = git#git_system(a:rootdir, ['--no-pager', 'diff'] + split(a:q_args, '\s\+') + ['--', path])
    let wnr = winnr()
    let lnum = line('.')

    let exists = v:false
    for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
      if getbufvar(w['bufnr'], g:git_config.unifieddiff.buffer_name, 0)
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

    call setbufvar(bufnr(), g:git_config.unifieddiff.buffer_name, 1)
    setlocal nolist
    setfiletype diff

    if empty(lines)
      close
    else
      setlocal modifiable noreadonly
      silent! call deletebufline(bufnr(), 1, '$')
      call setbufline(bufnr(), 1, lines)
      setlocal buftype=nofile nomodifiable readonly
    endif
    if !empty(lines)
      execute printf('nnoremap <buffer><cr>  <Cmd>call <SID>jump_diffline(%s)<cr>', string(a:rootdir))
      execute printf('nnoremap <buffer>!     <Cmd>call <SID>show_diff_with_path(%s,%s,%s)<cr>', string(a:q_args), string(a:rootdir), string(a:path))
    endif
  endif
endfunction

function! s:jump_diffline(rootdir) abort
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
          call git#open_file(expand(a:rootdir .. '/' .. relpath), lnum, v:true)
        endif
      endfor
    endif
  endif
endfunction
