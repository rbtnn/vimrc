
function! f#echo#error(text) abort
	echohl Error
	echo a:text
	echohl None
endfunction

function! f#echo#info(text) abort
	echohl Title
	echo a:text
	echohl None
endfunction

