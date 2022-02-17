
let s:base_cmd = 'git -c credential.helper= '

function! pack#sync(pack_dir, xs) abort
	if !isdirectory(expand(a:pack_dir))
		call mkdir(expand(a:pack_dir), 'p')
	endif
	let params = []
	for x in (type([]) == type(a:xs)) ? a:xs : [(a:xs)]
		let plugin_dir = expand(a:pack_dir .. '/' .. split(x, '/')[1])
		if isdirectory(plugin_dir)
			let params += [[
				\ x,
				\ printf('%s fetch', s:base_cmd),
				\ plugin_dir,
				\ has('nvim') ? { 'lines': [] } : tempname(),
				\ v:null,
				\ ]]
		else
			let params += [[
				\ x,
				\ printf('%s clone --origin origin --depth 1 https://github.com/%s.git', s:base_cmd, x),
				\ expand(a:pack_dir),
				\ has('nvim') ? { 'lines': [] } : tempname(),
				\ v:null,
				\ ]]
		endif
	endfor
	if has('nvim')
		for param in params
			let param[4] = jobstart(param[1], {
				\ 'cwd': param[2],
				\ 'on_stdout': function('s:system_onevent', [param[3]]),
				\ 'on_stderr': function('s:system_onevent', [param[3]]),
				\ })
		endfor
		let n = 0
		for param in params
			let n += 1
			echohl Title
			echomsg printf('%3d/%d. %s', n, len(params), param[0])
			echohl None
			call jobwait([param[4]])
			echomsg trim(join(param[3]['lines'], "\n"))
		endfor
	else
		for param in params
			let param[4] = job_start(param[1], {
				\ 'cwd': param[2],
				\ 'out_io': 'file',
				\ 'out_name': param[3],
				\ 'err_io': 'out',
				\ })
		endfor
		let n = 0
		for param in params
			let n += 1
			echohl Title
			echomsg printf('%3d/%d. %s', n, len(params), param[0])
			echohl None
			while 'run' == job_status(param[4])
			endwhile
			if filereadable(param[3])
				echomsg join(readfile(param[3]), "\n")
				call delete(param[3])
			endif
		endfor
	endif
endfunction

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
endfunction

