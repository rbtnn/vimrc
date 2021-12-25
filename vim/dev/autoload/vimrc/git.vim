
function! vimrc#git#get_rootdir(path) abort
	let xs = split(fnamemodify(a:path, ':p'), '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		let path = prefix .. join(xs + ['.git'], '/')
		if isdirectory(path) || filereadable(path)
			return prefix .. join(xs, '/')
		endif
		call remove(xs, -1)
	endwhile
	return ''
endfunction
