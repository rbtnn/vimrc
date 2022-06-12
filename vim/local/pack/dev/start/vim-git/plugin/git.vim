
let g:loaded_diffview = 1

if !has('nvim') && executable('git')
	command! -bang -nargs=0 GitLsFiles       :call git#lsfiles#main(<q-bang>) 
	command!       -nargs=* GitDiff          :call git#diff#main(<q-args>)
	command!       -nargs=* GitLog           :call git#log#main(<q-args>)
endif

