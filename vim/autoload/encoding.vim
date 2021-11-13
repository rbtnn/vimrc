
" check if the line contains a multibyte-character.
function! encoding#contains_multichar(input) abort
	return 0 < len(filter(split(a:input, '\zs'), { _, x -> 0x80 < char2nr(x) }))
endfunction

" http://tools.ietf.org/html/rfc3629
function! encoding#is_utf8(input) abort
	let cs = a:input
	let i = 0
	while i < len(cs)
		let bits = s:char2binary(cs[i])
		let c = s:count_1_prefixed(bits)

		" 1 byte utf-8 char. this is an asci char.
		if c == 0
			let i += 1

			" 2~4 byte utf-8 char.
		elseif 2 <= c && c <= 4
			let i += 1
			for _ in range(1, c - 1)
				let bits = s:char2binary(cs[i])
				let c = s:count_1_prefixed(bits)
				if c == 1
					" ok
				else
					" not utf-8
					return v:false
				endif
				let i += 1
			endfor
		else
			" not utf-8
			return v:false
		endif
	endwhile
	return v:true
endfunction

" echo s:char2binary('c')
" [0, 1, 1, 0 ,0, 0, 1, 1]
function! s:char2binary(c) abort
	let bits = repeat([0], 8)
	if len(a:c) == 1
		let n = 1
		for i in range(7, 0, -1)
			let bits[i] = and(char2nr(a:c), n) != 0
			let n *= 2
		endfor
	endif
	return bits
endfunction

" echo s:count_1_prefixed([1, 1, 0, 0, 0, 0, 1, 1])
" 2
function! s:count_1_prefixed(bits) abort
	let c = 0
	for b in a:bits
		if b
			let c += 1
		else
			break
		endif
	endfor
	return c
endfunction
