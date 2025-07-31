let g:loaded_git = 1

command! -bang -nargs=0 GitLsFiles       :call git#lsfiles#exec(<q-bang>) 
command!       -nargs=* GitUnifiedDiff   :call git#unifieddiff#exec(<q-args>)
command! -bang -nargs=0 GitCdRootDir     :call git#cdrootdir#exec()
command!       -nargs=1 GitGrep          :call git#grep#exec(<q-args>)
command!       -nargs=* GitVimDiff       :call git#vimdiff#exec(<q-args>)

let g:git_config = {
  \   'common': {
  \     'popupwin_border': [1, 1, 1, 1],
  \     'popupwin_padding': [0, 0, 0, 0],
  \     'popupwin_minwidth': 60,
  \     'popupwin_minheight': 1,
  \     'popupwin_maxheight': 10,
  \   },
  \   'lsfiles': {
  \     'caches': {},
  \     'prompt_lnum': 1,
  \     'prompt_string': '>',
  \     'prompt_cursor': '|',
  \   },
  \   'unifieddiff': {
  \     'buffer_name': 'git_unifieddiff',
  \   },
  \   'vimdiff': {
  \     'buffer_name': 'git_vimdiff',
  \   },
  \ }
