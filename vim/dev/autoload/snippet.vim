
let s:snippets = get(s:, 'snippets', {})

function! snippet#clear(filetype) abort
	if !empty(a:filetype)
		let s:snippets[a:filetype] = {}
	endif
endfunction

function! snippet#add(filetype, trigger, input_text) abort
	if !empty(a:filetype) && !empty(a:trigger)
		let s:snippets[a:filetype] = get(s:snippets, a:filetype, {})
		let s:snippets[a:filetype][a:trigger] = a:input_text
	endif
endfunction

function! snippet#expand() abort
	if has_key(s:snippets, &filetype)
		let word = s:inputting_text()
		for trigger in keys(s:snippets[&filetype])
			if word =~# '^' .. trigger
				return repeat("\<bs>", len(word)) .. s:snippets[&filetype][trigger]
			endif
		endfor
	endif
	return ''
endfunction

function! s:inputting_text() abort
	let chs = split(getline('.'), '\zs')
	let word = ''
	if !empty(chs)
		let i = len(chs) - 1
		while (0 <= i) && (' ' == chs[i])
			let word = chs[i] .. word
			let i -= 1
		endwhile
		while 0 <= i
			if chs[i] =~# '\k'
				let word = chs[i] .. word
			else
				break
			endif
			let i -= 1
		endwhile
	endif
	return word
endfunction
