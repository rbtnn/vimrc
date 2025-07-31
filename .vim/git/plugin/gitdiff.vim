command! -nargs=* GitVimDiff         :call gitdiff#vimdiff#exec(<q-args>)
command! -nargs=* GitUnifiedDiff     :call gitdiff#unifieddiff#exec(<q-args>)
command! -nargs=0 GitCdRootDir       :call gitdiff#cdrootdir#exec()
command! -nargs=1 GitGrep            :call gitdiff#grep#exec(<q-args>)
