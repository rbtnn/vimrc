
let g:loaded_develop_gitdiff = 1

command! -bang -nargs=* -complete=customlist,GitDiffComp   GitDiffNumStat          :call gitdiff#numstat(<q-bang>, <q-args>)
command!       -nargs=0                                    GitDiffHistory          :call gitdiff#history()
command!       -nargs=0                                    GitDiffHistoryFirst     :call gitdiff#history_first()

function! GitDiffComp(ArgLead, CmdLine, CursorPos) abort
  let rootdir = gitdiff#rootdir#get()
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

