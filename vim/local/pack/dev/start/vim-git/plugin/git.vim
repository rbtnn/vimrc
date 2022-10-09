
let g:loaded_git = 1

if !has('nvim') && executable('git')
	command! -bang -nargs=0 GitLsFiles       :call git#lsfiles#main()
	command!       -nargs=* GitDiff          :call git#diff#main(<q-args>)
	command!       -nargs=0 GitDiffRecently  :call git#diff#recently()
	command!       -nargs=* GitLog           :call git#log#main(<q-args>)
	command!       -nargs=* GitGotoRootDir   :call git#utils#goto_rootdir()
endif

