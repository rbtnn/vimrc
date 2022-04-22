
let g:loaded_csvfilter = 1

function! s:main(line1, line2, q_bang, q_args) abort
	let lines = []
	let target_columns = map(split(a:q_args, '\s'), { _,x -> str2nr(x) })
	for lnum in range(a:line1, a:line2)
		let xs = split(getline(lnum), '[;,]')
		let lines += [join(map(deepcopy(target_columns), { _,x -> get(xs, x - 1, '') }), ',')]
	endfor
	if a:q_bang == '!'
		new
		setlocal buftype=nofile bufhidden=hide
		call setbufline(bufnr(), 1, lines)
	else
		echo join(lines, "\n")
	endif
endfunction

command! -bang -range -nargs=* CSVFilter :call s:main(<line1>, <line2>, <q-bang>, <q-args>) 

