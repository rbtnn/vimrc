
let s:cwd = expand('<sfile>:h')

if has('win32') && !has('nvim')
  function! s:run(fname) abort
    let path = s:cwd .. '/pause'
    if filereadable(path)
      call delete(path)
    endif
    call term_start(['cmd.exe', '/c', (a:fname)], {
      \ 'cwd': s:cwd,
      \ 'exit_cb': {-> writefile([], path) },
      \ })
  endfunction

  "command! -bar -nargs=0  DevClean      :call <SID>run('.\vim-build_clean.bat')
  "command! -bar -nargs=0  DevVimBuild   :call <SID>run('.\vim-build_vim.bat')
  "command! -bar -nargs=0  DevGvimBuild  :call <SID>run('.\vim-build_gvim.bat')
  "execute printf('command! -bar -nargs=0  DevVimRun     :!start %s\Desktop\vim\src\vim.exe', $USERPROFILE)
  "execute printf('command! -bar -nargs=0  DevGvimRun    :!start %s\Desktop\vim\src\gvim.exe', $USERPROFILE)
endif
