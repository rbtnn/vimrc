let g:loaded_vimdev = 1

command! -nargs=0 VimdevScreenCapture  :echo vimdev#screen_capture()
command! -nargs=0 VimdevClean          :call vimdev#clean()
command! -nargs=0 VimdevBuild          :call vimdev#build()
command! -nargs=0 VimdevTags           :call vimdev#tags()
command! -nargs=0 VimdevCmdIdxs        :call vimdev#cmdidxs()
command! -nargs=0 VimdevTest           :call vimdev#test()
command! -nargs=1 VimdevSetMaxRunNr    :call vimdev#set_max_run_nr(<q-args>)
command! -nargs=1 -complete=customlist,vimdev#load_dumps_list  VimdevLoadDumps
  \ :call vimdev#load_dumps(<q-args>)
command! -nargs=1 -complete=customlist,vimdev#load_failed_list VimdevLoadFailed
  \ :call vimdev#load_failed(<q-args>)
command! -nargs=1 -complete=customlist,vimdev#dump_diff_list   VimdevDumpDiff
  \ :call vimdev#dump_diff(<q-args>)
