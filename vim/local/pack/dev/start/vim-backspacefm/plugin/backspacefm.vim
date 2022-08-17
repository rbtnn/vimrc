
let s:path = expand('~/Desktop/ghost-backspacefm-theme/deploy-theme')

if isdirectory(s:path)
	command! -nargs=0 DeployTheme :call term_start(['node', 'index.js'], { 'cwd': s:path, })

	function! s:hbs() abort
		if filereadable(expand('%')) && (get(readfile(expand('%'), 1), 0, '') == '<style>')
			setfiletype css
		else
			setfiletype html
		endif
		call matchadd('Comment', '{{!--.*--}}')
	endfunction

	augroup hbs
		autocmd!
		autocmd BufEnter *.hbs :call s:hbs()
	augroup END
endif
