
let s:snippets = get(s:, 'snippets', {})

function! vimrc#snippet#add(filetype, trigger, input_text) abort
	if !has_key(s:snippets, a:filetype)
		let s:snippets[a:filetype] = {}
	endif
	let s:snippets[a:filetype][a:trigger] = a:input_text
endfunction

function! vimrc#snippet#expand() abort
	if has_key(s:snippets, &filetype)
		let word = s:inputting_text()
		echo string(word)
		for trigger in keys(s:snippets[&filetype])
			if word == trigger
				return s:snippets[&filetype][trigger]
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
		if ' ' == chs[i]
			let word = chs[i] .. word
			let i -= 1
		endif
		while 0 <= i
			if chs[i] =~# '[0-9a-zA-Z_]'
				let word = chs[i] .. word
			else
				break
			endif
			let i -= 1
		endwhile
	endif
	return word
endfunction

