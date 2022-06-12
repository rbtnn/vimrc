
function! git#log#main(q_args) abort
	let cmd = 'git --no-pager log --pretty="format:%C(yellow)%h %C(green)%cd %C(reset)%s" --date=iso -100'
	let rootdir = git#utils#get_rootdir('.', 'git')
	let winid = git#utils#create_popupwin(rootdir, [])
	if -1 != winid
		call popup_setoptions(winid, {
			\ 'filter': function('git#log#popup_filter', [rootdir]),
			\ 'callback': function('git#log#popup_callback', [rootdir]),
			\ })
		let lines = git#utils#system(cmd, rootdir)
		call popup_settext(winid, lines)
	endif
endfunction

function! git#log#popup_filter(rootdir, winid, key) abort
	return git#diff#popup_filter(a:rootdir, a:winid, a:key)
endfunction

function! git#log#popup_callback(rootdir, winid, result) abort
	if -1 != a:result
		let line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
		let hash = matchstr(line, '^[0-9a-f]\+\ze\s')
		let cmd = 'git --no-pager diff -w ' .. printf('%s~1..%s', hash, hash)
		call git#utils#open_diffwindow()
		let lines = git#utils#system(cmd, a:rootdir)
		call git#utils#setlines(a:rootdir, cmd, lines)
	endif
endfunction

