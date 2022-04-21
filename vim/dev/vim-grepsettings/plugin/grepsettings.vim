
let g:loaded_grepsettings = 1

command! -nargs=0 GrepSettingsInternal
	\ :set grepformat&
	\ |set grepprg=internal

if executable('git')
	command! -nargs=0 GrepSettingsGit
		\ :set grepformat=%f:%l:%c:%m
		\ |let &grepprg = 'git --no-pager grep --column --line --no-color'
endif

if executable('rg')
	command! -nargs=0 GrepSettingsRg
		\ :set grepformat=%f:%l:%c:%m
		\ |let &grepprg = 'rg --vimgrep --glob "!.git" --glob "!.svn" -uu'
endif

