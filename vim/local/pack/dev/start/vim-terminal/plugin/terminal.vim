
if !has('vim9script')
	finish
endif

vim9script

g:loaded_terminal = 1

var term_cmd = [&shell]

if has('win32') && executable('wmic') && has('gui_running')
	def OutCb(ch: channel, mes: string)
		if 14393 < str2nr(trim(mes))
			const fg = 1
			const bg = 0
			const clr = '$e[0m'
			const xs = [' & prompt ', '$e[4' .. bg .. 'm', '$e[3' .. fg .. 'm', '$$', clr]
			term_cmd = [&shell, '/K', 'doskey pwd=cd & doskey ls=dir /b & doskey g=git $* ' .. join(xs, '')]
		endif
	enddef
	job_start('wmic os get BuildNumber', { 'out_cb': OutCb, })
endif

def Terminal()
	var xs = filter(getwininfo(), (_, x): bool => x['terminal'] && (x['tabnr'] == tabpagenr()))
	if empty(xs)
		term_start(term_cmd, {
			\ 'term_kill': 'kill',
			\ 'term_finish': 'close',
			\ })
	else
		win_gotoid(xs[0]['winid'])
	endif
enddef

def FloatingTerminal()
	var exists_term = false
	for winid in popup_list()
		if get(getwininfo(winid), 0, { 'terminal': v:false })['terminal']
			popup_close(winid)
			exists_term = true
		endif
	endfor
	if !exists_term
		var bnr = get(filter(term_list(), (i, x) => term_getstatus(x) != 'finished'), 0, -1)
		if -1 == bnr
			bnr = term_start(term_cmd, {
				\   'hidden': 1,
				\   'term_kill': 'kill',
				\   'term_finish': 'close',
				\ })
		endif
		popup_create(bnr, git#utils#get_popupwin_options())
	endif
enddef

command! -nargs=0 FloatingTerminal :call FloatingTerminal()
