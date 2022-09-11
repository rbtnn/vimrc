
let g:loaded_git = 1

if !has('nvim') && executable('git')
	command! -bang -nargs=0 GitLsFiles       :call git#lsfiles#main(get(t:, 'git_lsfiles_args', <q-args>))
	command!       -nargs=* GitDiff          :call git#diff#main(get(t:, 'git_diff_args', <q-args>))
	command!       -nargs=* GitLog           :call git#log#main(get(t:, 'git_log_args', <q-args>))
endif

