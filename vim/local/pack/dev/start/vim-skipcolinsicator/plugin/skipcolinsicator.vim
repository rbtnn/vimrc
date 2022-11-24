
let g:loaded_skipcolinsicator = 1

function! s:skipcolinsicator(timer) abort
	try
		let s:winid = get(s:, 'winid', -1)
		if -1 != s:winid
			call popup_close(s:winid)
			let s:winid = -1
		endif
		if 0 < winsaveview()['leftcol']
			let info = getwininfo(win_getid())[0]
			let s:winid = popup_create(get(g:, 'skipcolinsicator_text', ' <<< '), {
				\ 'highlight': 'SkipColInsicator',
				\ 'line': info['winrow'],
				\ 'col': info['wincol'],
				\ })
		endif
	catch
	endtry
endfunction

if has('vim_starting') && !has('nvim')
	augroup skipcolinsicator
		autocmd!
		autocmd ColorScheme * :highlight default SkipColInsicator guifg=#ffffff guibg=#ff9933 gui=BOLD
	augroup END
	call timer_start(get(g:, 'skipcolinsicator_msec', 500), function('s:skipcolinsicator'), { 'repeat': -1, })
endif
