
let g:loaded_qficonv = 1

command! -bar -nargs=0 QfIconv  :call s:qficonv()

function! s:qficonv() abort
	let enc_from = 'shift_jis'
	if enc_from != &encoding
		let xs = getqflist()
		for x in xs
			if qficonv#encoding#contains_multichar(x['text'])
				if !qficonv#encoding#is_utf8(x['text'])
					let x['text'] = iconv(x['text'], enc_from, &encoding)
				endif
			endif
		endfor
		call setqflist(xs)
	endif
endfunction
