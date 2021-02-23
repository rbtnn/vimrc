
function! f#io#search(rootdir, path, pattern, maxdepth, lnum, maxwidth) abort
	let interrupts = v:false
	let lnum = a:lnum
	let maxwidth = a:maxwidth
	if 0 < a:maxdepth
		try
			for fname in s:readdir(a:path)
				let abspath = f#io#fix_path(a:path .. '/' .. fname)
				if s:is_ignore(abspath)
					continue
				endif
				let dict = {}
				if filereadable(abspath)
					" depend on &ignorecase
					if fname =~ a:pattern
						let dict = s:search_cb(a:rootdir, lnum, maxwidth, abspath, interrupts)
					endif
				elseif isdirectory(abspath)
					let dict = f#io#search(a:rootdir, abspath, a:pattern, a:maxdepth - 1, lnum, maxwidth)
				endif
				if !empty(dict)
					let lnum = dict['lnum']
					let maxwidth = dict['maxwidth']
					if dict['interrupts']
						let interrupts = v:true
						break
					endif
				endif
			endfor
		catch /^Vim:Interrupt$/
			let interrupts = v:true
		endtry
	endif
	return { 'lnum' : lnum, 'maxwidth' : maxwidth, 'interrupts' : interrupts }
endfunction

function! f#io#driveletters() abort
	let xs = []
	if has('win32')
		for n in range(char2nr('A'), char2nr('Z'))
			if isdirectory(nr2char(n) .. ':')
				let xs += [nr2char(n) .. ':/']
			endif
		endfor
	endif
	return xs
endfunction

function! f#io#fix_path(path) abort
	return substitute(a:path, '[\/]\+', '/', 'g')
endfunction

function! f#io#readdir(path) abort
	let xs = []
	let rootdir = a:path
	if !empty(rootdir) && ('/' != split(rootdir, '\zs')[-1])
		let rootdir = rootdir .. '/'
	endif
	for fname in s:readdir(rootdir)
		let relpath = f#io#fix_path(rootdir .. fname)
		if s:is_ignore(relpath)
			continue
		endif
		if filereadable(relpath)
			if rootdir == relpath[:len(rootdir) - 1]
				let xs += [relpath[len(rootdir):]]
			else
				let xs += [relpath]
			endif
		elseif isdirectory(relpath) && (fnamemodify(fname, ':t') !~# '^\$')
			if rootdir == relpath[:len(rootdir) - 1]
				let xs += [relpath[len(rootdir):] .. '/']
			else
				let xs += [relpath .. '/']
			endif
		endif
	endfor
	return xs
endfunction

function! s:is_ignore(path) abort
	return empty(expand(a:path))
endfunction

function! s:readdir(path) abort
	let xs = []
	try
		if exists('*readdir')
			silent! let xs = readdir(a:path)
		else
			let saved = getcwd()
			try
				lcd `=a:path`
				let xs = split(glob('.*') .. "\n" .. glob('*'), "\n")
				call filter(xs, { _,x -> (x != '.') && (x != '..') })
			finally
				lcd `=saved`
			endtry
		endif
	catch /^Vim\%((\a\+)\)\=:E484:/
		" skip the directory.
		" E484: Can't open file ...
	endtry
	return xs
endfunction

function! s:search_cb(rootdir, lnum, maxwidth, line, interrupts) abort
	let line = a:line
	if line =~# '^' .. a:rootdir
		let relpath = line[len(a:rootdir):]
		if relpath =~# '^/'
			let relpath = relpath[1:]
		endif
		let line = relpath
	endif
	call setbufline('%', a:lnum, line)
	call cursor('$', 1)
	redraw
	let maxwidth = a:maxwidth
	if maxwidth < strdisplaywidth(line) + 1
		let maxwidth = strdisplaywidth(line) + 1
	endif
	execute printf('vertical resize %d', maxwidth)
	return { 'lnum' : a:lnum + 1, 'maxwidth' : maxwidth, 'interrupts' : a:interrupts }
endfunction

