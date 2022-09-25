
if !has('vim9script')
	finish
endif

vim9script

g:loaded_terminal = 1

var term_cmd = [&shell]

if has('win32') && executable('wmic') && has('gui_running')
	def OutCb(ch: channel, mes: string)
		if 14393 < str2nr(trim(mes))
			const fg = 0
			const bg = 1
			const clr = '$e[0m'
			const sp = '$S'
			const arrow = nr2char(0xe0b0)
			const xs = ['$e[4' .. bg .. 'm', '$e[3' .. fg .. 'm', sp, clr, '$e[3' .. bg .. 'm', arrow, clr]
			term_cmd = [&shell, '/K', 'doskey pwd=cd & doskey ls=dir /b & doskey g=git $* & prompt ' .. join(xs, '')]
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

command! -nargs=0 Terminal :call Terminal()

