vim9script

const NO_MATCHES = 'no matches'
const NUMSTAT_HEAD = 12
const ERR_MESSAGE_1 = 'No modified files'
const ERR_MESSAGE_2 = 'Not a git repository'
const ERR_MESSAGE_3 = 'No such file'
const ERR_MESSAGE_4 = 'Could not jump this'
const ERR_MESSAGE_5 = 'Could not execute "git"'

var s:search_winid = -1

def vimrc#git#grep()
	if s:change_to_the_toplevel()
		echohl Label
		var text = trim(input('gitgrep>'))
		echohl None
		if !empty(text)
			var args = split(text, '\s\+')
			var cmd = ['git', '--no-pager', 'grep', '--full-name', '-I', '--no-color', '-n'] + args
			var xs = []
			for line in s:system(cmd)
				var m = matchlist(line, '^\(..[^:]*\):\(\d\+\):\(.*$\)$')
				if !empty(m)
					var lines = [m[3]]
					call s:decode_lines(lines)
					xs += [{
						\ 'filename': m[1],
						\ 'lnum': str2nr(m[2]),
						\ 'text': lines[0],
						\ }]
				else
					echo line
				endif
			endfor
			call setqflist(xs)
			copen
		endif
	endif
enddef

def vimrc#git#diff(q_args: string)
	if s:change_to_the_toplevel()
		var args = split(q_args, '\s\+')
		var dict = {}
		var cmd = ['git', '--no-pager', 'diff', '--numstat'] + args
		for line in s:system(cmd)
			var m = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$')
			if !empty(m)
				var key = m[3]
				if !has_key(dict, key)
					dict[key] = { 'additions': m[1], 'deletions': m[2], 'path': key, }
				endif
			endif
		endfor
		var lines = keys(dict)
		if !empty(lines)
			call map(lines, { i, key ->
				\ printf('%5s %5s %s', '+' .. dict[key]['additions'], '-' .. dict[key]['deletions'], key)
				\ })
			call sort(lines, { x, y ->
				\ x[NUMSTAT_HEAD:] == y[NUMSTAT_HEAD:]
				\ ? 0
				\ : (
				\   x[NUMSTAT_HEAD:] > y[NUMSTAT_HEAD:]
				\   ? 1
				\   : -1
				\ )})
			var winid = s:open(lines, join(cmd), function('s:cb_diff'))
			call setwinvar(winid, 'args', args)
			call setwinvar(winid, 'info', dict)
			call win_execute(winid, 'setlocal wrap')
			call win_execute(winid, 'call clearmatches()')
			call win_execute(winid, 'call matchadd("DiffAdd", "+\\d\\+")')
			call win_execute(winid, 'call matchadd("DiffDelete", "-\\d\\+")')
		else
			call s:error(ERR_MESSAGE_1, getcwd())
		endif
	endif
enddef

def vimrc#git#lsfiles()
	if s:change_to_the_toplevel()
		var cmd = ['git', '--no-pager', 'ls-files']
		var files = s:system(cmd)
		if empty(files)
			call s:error(ERR_MESSAGE_3, join(cmd))
		else
			var winid = s:open(files, join(cmd), function('s:cb_lsfiles'))
			call win_execute(winid, 'setlocal wrap')
		endif
	endif
enddef



def s:cb_diff(winid: number, key: number)
	if -1 != key
		var lnum = key
		var path = getbufline(winbufnr(winid), lnum, lnum)[0]
		if NO_MATCHES != path
			path = path[NUMSTAT_HEAD:]
			var args = getwinvar(winid, 'args')
			var cmd = ['git', '--no-pager', 'diff'] + args + ['--', path]
			var lines = s:system(cmd)
			call s:decode_lines(lines)
			call s:new_window(lines, cmd)
			var fullpath = s:expand2fullpath(path)
			execute printf('nnoremap <buffer><silent><nowait><space>    :<C-w>call <SID>jump_diff(%s)<cr>', string(fullpath))
			execute printf('nnoremap <buffer><silent><nowait><cr>       :<C-w>call <SID>jump_diff(%s)<cr>', string(fullpath))
			execute printf('nnoremap <buffer><silent><nowait>R          :<C-w>call <SID>rediff(%s)<cr>', string(cmd))
		endif
	endif
enddef

def s:jump_diff(fullpath: string)
	var ok = v:false
	var lnum = search('^@@', 'bnW')
	if 0 < lnum
		var n1 = 0
		var n2 = 0
		for n in range(lnum + 1, line('.'))
			var line = getline(n)
			if line =~# '^-'
				n2 += 1
			elseif line =~# '^+'
				n1 += 1
			endif
		endfor
		var n3 = line('.') - lnum - n1 - n2 - 1
		var m = []
		var m2 = matchlist(getline(lnum), '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@\(.*\)$')
		var m3 = matchlist(getline(lnum), '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
		if !empty(m2)
			m = m2
		elseif !empty(m3)
			m = m3
		endif
		if !empty(m)
			for i in [1, 3, 5]
				if '+' == m[i]
					call s:open_file(fullpath, str2nr(m[i + 1]) + n1 + n3)
					ok = v:true
					break
				endif
			endfor
		endif
	endif
	if !ok
		call s:error(ERR_MESSAGE_4, '')
	endif
enddef

def s:open_file(path: string, lnum: number)
	if filereadable(path)
		var fullpath = s:expand2fullpath(path)
		var b = v:false
		for x in filter(getwininfo(), { i, x -> x['tabnr'] == tabpagenr() })
			if s:expand2fullpath(bufname(x['bufnr'])) is fullpath
				execute ':' .. x['winnr'] .. 'wincmd w'
				# reload the buffer
				silent! edit
				b = v:true
				break
			endif
		endfor
		if b
			execute printf(':%d', lnum)
		else
			if 0 < lnum
				execute printf('new %s', fnameescape(fullpath))
				execute printf(':%d', lnum)
			else
				execute printf('new %s', fnameescape(fullpath))
			endif
		endif
		normal! zz
	endif
enddef

def s:rediff(cmd: list<string>)
	var pos = getcurpos()
	var lines = s:system(cmd)
	call s:decode_lines(lines)
	call s:new_window(lines, cmd)
	call setpos('.', pos)
enddef

def s:new_window(lines: list<string>, cmd: list<string>)
	var exists = v:false
	for info in getwininfo()
		if (info['tabnr'] == tabpagenr()) && (getbufvar(info['bufnr'], '&filetype') == 'diff')
			execute printf(':%dwincmd w', info['winnr'])
			setlocal noreadonly modifiable
			exists = v:true
			break
		endif
	endfor
	if !exists
		new
	endif
	call deletebufline('%', 1, '$')
	call setbufline('%', 1, lines)
	setlocal readonly nomodifiable buftype=nofile nocursorline
	&l:filetype = 'diff'
	&l:statusline = join(cmd)
enddef

def s:system(cmd: list<string>): list<string>
	var lines = []
	var path = tempname()
	try
		var job = job_start(cmd, {
			\ 'out_io': 'file',
			\ 'out_name': path,
			\ })
		while 'run' == job_status(job)
		endwhile
		if filereadable(path)
			lines = readfile(path)
		endif
	finally
		if filereadable(path)
			call delete(path)
		endif
	endtry
	return lines
enddef

def s:error(text: string, info: string)
	call popup_notification(printf('%s%s%s', text, empty(info) ? '' : ': ', string(info)), {
		\ 'highlight': 'ErrorMsg',
		\ })
enddef

def s:expand2fullpath(path: string): string
	return substitute(resolve(fnamemodify(path, ':p')), '\', '/', 'g')
enddef

def s:cb_lsfiles(winid: number, key: number)
	if 0 < key
		var lnum = key
		var path = getbufline(winbufnr(winid), lnum, lnum)[0]
		if NO_MATCHES != path
			var fullpath = s:expand2fullpath(path)
			var matches = filter(getbufinfo(), {i, x -> s:expand2fullpath(x.name) == fullpath })
			if !empty(matches)
				execute printf(':%s %d', 'buffer', matches[0]['bufnr'])
			else
				execute printf(':%s %s', 'edit', fnameescape(fullpath))
			endif
		endif
	endif
enddef

def s:open(lines: list<string>, cmd: string, cb: func): number
	var winid = popup_menu(lines, {})
	s:search_winid = -1

	var lines_width = 0
	for line in lines
		if lines_width < strwidth(line)
			lines_width = strwidth(line)
		endif
	endfor

	call setwinvar(winid, 'options', {
		\ 'curr_filter_text': '',
		\ 'prev_filter_text': '',
		\ 'search_mode': v:false,
		\ 'cmd': cmd,
		\ 'user_callback': cb,
		\ 'orig_lines': lines,
		\ 'lines_width': lines_width,
		\ })

	call s:update_lines(winid, v:true, v:true)
	call s:set_options(winid)

	return winid
enddef

def s:set_options(winid: number)
	var opts = getwinvar(winid, 'options')
	if winid != -1
		var orig_len = len(opts.orig_lines)
		var filter_lines = getbufline(winbufnr(winid), 1, '$')
		var filter_len = (get(filter_lines, 0, '') == NO_MATCHES) ? 0 : len(filter_lines)
		var base_opts = {}
		try
			base_opts = pterm#build_options()
		catch
		endtry
		call popup_setoptions(winid, extend(base_opts, {
			\ 'title': printf(' %s (%d/%d) ', opts.cmd, filter_len, orig_len),
			\ 'zindex': 100,
			\ 'padding': [(opts.search_mode ? 1 : 0), 1, 0, 1],
			\ 'filter': function('s:filter'),
			\ 'callback': function('s:callback'),
			\ }, 'force'))
	endif
	if s:search_winid != -1
		call popup_settext(s:search_winid, '/' .. opts.curr_filter_text)
		var parent_pos = popup_getpos(winid)
		call popup_setoptions(s:search_winid, {
			\ 'pos': 'topleft',
			\ 'zindex': 200,
			\ 'line': parent_pos['line'] + 1,
			\ 'col': parent_pos['col'] + 2,
			\ 'minwidth': parent_pos['core_width'],
			\ 'highlight': 'Terminal',
			\ 'padding': [0, 0, 0, 0],
			\ 'border': [0, 0, 0, 0],
			\ })
	endif
enddef

def s:callback(winid: number, key: number)
	var opts = getwinvar(winid, 'options')
	call popup_close(s:search_winid)
	call(opts.user_callback, [winid, key])
enddef

def s:filter(winid: number, key: string): bool
	#echo printf('%x,"%s"', char2nr(a:key), a:key)
	var opts = getwinvar(winid, 'options')
	if opts.search_mode
		if ("\<esc>" == key) || ("\<cr>" == key)
			opts.search_mode = v:false
			call popup_close(s:search_winid)
			s:search_winid = -1
			call s:set_options(winid)
			return v:true
		else
			var chars = split(opts.curr_filter_text, '\zs')
			if 21 == char2nr(key)
				opts.curr_filter_text = ''
			elseif (8 == char2nr(key)) || ("\x80kb" == key)
				if 0 < len(chars)
					if 1 == len(chars)
						chars = []
					else
						chars = chars[:len(chars) - 2]
					endif
				else
					chars = []
					opts.search_mode = v:false
					call popup_close(s:search_winid)
					s:search_winid = -1
				endif
				opts.curr_filter_text = join(chars, '')
			elseif (0x20 <= char2nr(key)) && (char2nr(key) <= 0x7f)
				opts.curr_filter_text = opts.curr_filter_text .. key
			endif
			opts.curr_filter_text = trim(opts.curr_filter_text)
			call s:update_lines(winid, v:false, v:false)
			call s:set_options(winid)
			return v:true
		endif
	else
		if '/' ==# key
			opts.search_mode = v:true
			call s:update_lines(winid, v:false, v:false)
			s:search_winid = popup_create('', {})
			call s:set_options(winid)
			return v:true
		elseif 'g' ==# key
			call s:set_curpos(winid, 1)
			return v:true
		elseif 'G' ==# key
			call s:set_curpos(winid, line('$', winid))
			return v:true
		else
			return popup_filter_menu(winid, key)
		endif
	endif
enddef

def s:update_lines(winid: number, force: bool, set_currfile: bool)
	var opts = getwinvar(winid, 'options')
	if (opts.prev_filter_text != opts.curr_filter_text) || force
		opts.prev_filter_text = opts.curr_filter_text
		var lines = opts.orig_lines
		if !empty(opts.curr_filter_text)
			lines = matchfuzzy(deepcopy(lines), opts.curr_filter_text)
		endif
		call popup_settext(winid, !empty(lines) ? lines : NO_MATCHES)
		call s:set_options(winid)
		var init_lnum = 1
		if set_currfile && !empty(bufname())
			var target = substitute(s:expand2fullpath(bufname()), s:get_toplevel() .. '[/\\]\?', '', '')
			for i in range(0, len(lines) - 1)
				if lines[i] =~# target .. '$'
					init_lnum = i + 1
				endif
			endfor
		endif
		call s:set_curpos(winid, init_lnum)
		redraw
	endif
enddef

def s:set_curpos(winid: number, lnum: number)
	call win_execute(winid, printf('call setpos(".", [0, %d, 0, 0])', lnum))
enddef

def s:change_to_the_toplevel(): bool
	if executable('git')
		var toplevel = s:get_toplevel()
		if !empty(toplevel) && (s:expand2fullpath(getcwd()) != toplevel)
			execute printf('lcd %s', escape(toplevel, ' '))
			echohl WarningMsg
			echo printf('Changed the current directory to "%s" in the current window.', toplevel)
			echohl None
		endif
		if isdirectory(toplevel)
			return v:true
		else
			call s:error(ERR_MESSAGE_2, getcwd())
			return v:false
		endif
	else
		call s:error(ERR_MESSAGE_5, getcwd())
		return v:false
	endif
enddef

def s:get_toplevel(): string
	for dir in [expand('%:p:h'), getcwd()]
		for do_resolve in [v:false, v:true]
			var xs = split((do_resolve ? resolve(dir) : dir), '[\/]')
			var prefix = (has('mac') || has('linux')) ? '/' : ''
			while !empty(xs)
				if isdirectory(prefix .. join(xs + ['.git'], '/'))
					return s:expand2fullpath(prefix .. join(xs, '/'))
				endif
				call remove(xs, -1)
			endwhile
		endfor
	endfor
	return ''
enddef

def s:decode_lines(lines: list<string>)
	for i in range(0, len(lines) - 1)
		if vimrc#sillyiconv#utf_8(lines[i]) && ('utf-8' == &encoding)
			# nop
		elseif vimrc#sillyiconv#shift_jis(lines[i]) && ('cp932' != &encoding) && ('shift_jis' != &encoding)
			lines[i] = iconv(lines[i], 'shift_jis', &encoding)
		endif
	endfor
enddef

