
let g:loaded_diffview = 1

if !has('nvim') && executable('git')
	command! -bang -nargs=0 GitLsFiles       :call git#lsfiles#main(get(g:, 'git_lsfiles_args', <q-args>))
	command!       -nargs=* GitDiff          :call git#diff#main(get(g:, 'git_diff_args', <q-args>))
	command!       -nargs=* GitLog           :call git#log#main(get(g:, 'git_log_args', <q-args>))
endif

