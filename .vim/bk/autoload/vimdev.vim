
function! s:init() abort
  let g:vimdev_dir = get(g:, 'vimdev_dir', '~/work/vim')
endfunction

function! vimdev#screen_capture() abort
  let s = []
  for row in range(1, &lines - 1)
    let s += [join(map(range(1,&columns), {_,col -> nr2char(screenchar(row, col))}), '')]
  endfor
  return join(s, '')
endfunction

function! vimdev#clean() abort
  call s:init()
  call term_start(['make', 'clean'], {
    \   'term_name': 'VimdevClean',
    \   'cwd': expand(g:vimdev_dir),
    \ })
endfunction

function! vimdev#build() abort
  call s:init()
  call term_start(['make'], {
    \   'term_name': 'VimdevBuild',
    \   'cwd': expand(g:vimdev_dir),
    \ })
endfunction

function! vimdev#tags() abort
  call s:init()
  call term_start(['make', 'tags'], {
    \   'term_name': 'VimdevTags',
    \   'cwd': expand(g:vimdev_dir .. '/runtime/doc'),
    \ })
endfunction

function! vimdev#cmdidxs() abort
  call s:init()
  call term_start(['make', 'cmdidxs'], {
    \   'term_name': 'VimdevCmdIdxs',
    \   'cwd': expand(g:vimdev_dir .. '/src'),
    \ })
endfunction

function! vimdev#test() abort
  call s:init()
  tabnew
  call vimdev#set_max_run_nr(1)
  call term_start([
    \       'make', 'clean', 'test_codestyle.res',
    \       'test_cmd_lists.res', 'test_conceal.res',
    \       'test_breakindent.res', 'test_options_all.res',
    \       'test_tabpanel.res', 'report'], {
    \   'term_name': 'VimdevTest',
    \   'curwin': v:true,
    \   'exit_cb': function('s:test_exit_cb'),
    \   'cwd': expand(g:vimdev_dir .. '/src/testdir'),
    \ })
endfunction

function! s:test_exit_cb(...) abort
  call vimdev#set_max_run_nr(5)
endfunction

function! vimdev#set_max_run_nr(q_args) abort
  call s:init()
  let path = expand(g:vimdev_dir .. '/src/testdir/runtest.vim')
  let lines = readfile(path)
  for i in range(0, len(lines) - 1)
    if lines[i] =~# '^\s*let g:max_run_nr = \d\+$'
      let lines[i] = '  let g:max_run_nr = ' .. a:q_args
      echo lines[i]
      break
    endif
  endfor
  call writefile(lines, path)
endfunction

function! vimdev#popupwin(bnr) abort
  let wid = win_getid()
  let pid = popup_create(a:bnr, { 'border': [], })
  let pos = popup_getpos(win_getid())
  let width = pos['core_width']
  let height = pos['core_height']
  call popup_setoptions(pid, {
    \   'title': printf(' width:%d, height:%d ', width, height),
    \   'minwidth': width, 'maxwidth': width, 'minheight': height, 'maxheight': height,
    \ })
  call win_execute(wid, 'close')
  call win_execute(pid, 'nnoremap <buffer>q <Cmd>quit<cr>')
endfunction

function! vimdev#load_dumps(q_args) abort
  call s:init()
  let bnr = term_dumpload(expand(g:vimdev_dir .. '/src/testdir/dumps/' .. a:q_args))
  call vimdev#popupwin(bnr)
endfunction

function! vimdev#load_dumps_list(ArgLead, CmdLine, CursorPos) abort
  call s:init()
  let xs = []
  for x in readdir(expand(g:vimdev_dir .. '/src/testdir/dumps'))
    if -1 == match(a:CmdLine, x)
      let xs += [x]
    endif
  endfor
  return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
endfunction

function! vimdev#load_failed(q_args) abort
  call s:init()
  let bnr = term_dumpload(expand(g:vimdev_dir .. '/src/testdir/failed/' .. a:q_args))
  call vimdev#popupwin(bnr)
endfunction

function! vimdev#load_failed_list(ArgLead, CmdLine, CursorPos) abort
  call s:init()
  let xs = []
  for x in readdir(expand(g:vimdev_dir .. '/src/testdir/failed'))
    if -1 == match(a:CmdLine, x)
      let xs += [x]
    endif
  endfor
  return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
endfunction

function! vimdev#dump_diff(q_args) abort
  call s:init()
  let dumps = expand(g:vimdev_dir .. '/src/testdir/dumps/' .. a:q_args)
  let failed = expand(g:vimdev_dir .. '/src/testdir/failed/' .. a:q_args)
  let bnr = term_dumpdiff(dumps, failed)
  call vimdev#popupwin(bnr)
endfunction

function! vimdev#dump_diff_list(ArgLead, CmdLine, CursorPos) abort
  call s:init()
  let xs = []
  for x in readdir(expand(g:vimdev_dir .. '/src/testdir/dumps'))
    for y in readdir(expand(g:vimdev_dir .. '/src/testdir/failed'))
      if x == y
        if -1 == match(a:CmdLine, x)
          let xs += [x]
        endif
        break
      endif
    endfor
  endfor
  return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
endfunction
