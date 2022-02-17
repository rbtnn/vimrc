
function! pack#sync(pack_dir, d, ...) abort
	let opts = 0 < a:0 ? a:1 : {}
	let base_cmd = get(opts, 'base_cmd', 'git -c credential.helper= ')
	let params = []
	for username in keys(a:d)
		let pack_dir = expand(join([a:pack_dir, 'pack', username, 'start'], '/'))
		if !isdirectory(pack_dir)
			call mkdir(pack_dir, 'p')
		endif
		for plugin_name in a:d[username]
			let plugin_dir = pack_dir .. '/' .. plugin_name
			if isdirectory(plugin_dir)
				let params += [{
					\   'name': printf('%s/%s', username, plugin_name),
					\   'cmd': printf('%s fetch', base_cmd),
					\   'cwd': plugin_dir,
					\   'arg': has('nvim') ? { 'lines': [] } : tempname(),
					\   'job': v:null,
					\ }]
			else
				let params += [{
					\   'name': printf('%s/%s', username, plugin_name),
					\   'cmd': printf(
					\     '%s clone --origin origin --depth 1 https://github.com/%s.git', base_cmd, printf('%s/%s', username, plugin_name)
					\   ),
					\   'cwd': pack_dir,
					\   'arg': has('nvim') ? { 'lines': [] } : tempname(),
					\   'job': v:null,
					\ }]
			endif
		endfor
	endfor
	if has('nvim')
		for param in params
			let param['job'] = jobstart(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'on_stdout': function('s:system_onevent', [param['arg']]),
				\ 'on_stderr': function('s:system_onevent', [param['arg']]),
				\ })
		endfor
		let n = 0
		for param in params
			let n += 1
			echohl Title
			echomsg printf('%3d/%d. %s', n, len(params), param['name'])
			echohl None
			call jobwait([param['job']])
			echomsg trim(join(param['arg']['lines'], "\n"))
		endfor
	else
		for param in params
			let param['job'] = job_start(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'out_io': 'file',
				\ 'out_name': param['arg'],
				\ 'err_io': 'out',
				\ })
		endfor
		let n = 0
		for param in params
			let n += 1
			echohl Title
			echomsg printf('%3d/%d. %s', n, len(params), param['name'])
			echohl None
			while 'run' == job_status(param['job'])
			endwhile
			if filereadable(param['arg'])
				echomsg join(readfile(param['arg']), "\n")
				call delete(param['arg'])
			endif
		endfor
	endif
endfunction

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
endfunction

