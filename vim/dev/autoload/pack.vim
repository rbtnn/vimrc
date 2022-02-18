
function! pack#sync(pack_dir, d, ...) abort
	let opts = 0 < a:0 ? a:1 : {}
	let params = s:make_params(a:pack_dir, a:d, opts)
	call s:wait_and_echomsg(params)
	call s:delete_unmanaged_plugins(a:pack_dir, a:d)
endfunction

function! s:make_params(pack_dir, d, opts) abort
	let base_cmd = get(a:opts, 'base_cmd', 'git -c credential.helper= ')
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
					\   'msg': 'Updating',
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
					\   'msg': 'Installing',
					\ }]
			endif
		endfor
	endfor
	return params
endfunction

function! s:delete_unmanaged_plugins(pack_dir, d) abort
	for x in split(globpath(join([a:pack_dir, 'pack', '*', 'start'], '/'), '*'), "\n")
		let exists = v:false
		for username in keys(a:d)
			for plugin_name in a:d[username]
				if x =~# '[\/]' .. username .. '[\/]start[\/]' .. plugin_name .. '$'
					let exists = v:true
					break
				endif
			endfor
		endfor
		if !exists
			call s:delete_carefull(a:pack_dir, x)
		endif
	endfor
	for x in split(globpath(join([a:pack_dir, 'pack', '*'], '/'), 'start'), "\n")
		if !len(readdir(x))
			call s:delete_carefull(a:pack_dir, fnamemodify(x, ':h'))
		endif
	endfor
	for x in split(globpath(join([a:pack_dir, 'pack'], '/'), '*'), "\n")
		if !len(readdir(x))
			call s:delete_carefull(a:pack_dir, x)
		endif
	endfor
endfunction

function! s:delete_carefull(pack_dir, path) abort
	if (-1 != index(split(a:path, '[\/]'), 'pack')) && (a:path[:(len(a:pack_dir) - 1)] == a:pack_dir)
		call s:echomsg('Deleting', printf('the unmanaged directory: "%s"', a:path))
		call delete(a:path, 'rf')
	endif
endfunction

function! s:wait_and_echomsg(params) abort
	if has('nvim')
		for param in a:params
			let param['job'] = jobstart(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'on_stdout': function('s:system_onevent', [param['arg']]),
				\ 'on_stderr': function('s:system_onevent', [param['arg']]),
				\ })
		endfor
		let n = 0
		for param in a:params
			let n += 1
			call s:echomsg(param['msg'], param['name'])
			call jobwait([param['job']])
			for line in param['arg']['lines']
				echomsg '  ' .. line
			endfor
		endfor
	else
		for param in a:params
			let param['job'] = job_start(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'out_io': 'file',
				\ 'out_name': param['arg'],
				\ 'err_io': 'out',
				\ })
		endfor
		let n = 0
		for param in a:params
			let n += 1
			call s:echomsg(param['msg'], param['name'])
			while 'run' == job_status(param['job'])
			endwhile
			if filereadable(param['arg'])
				for line in readfile(param['arg'])
					echomsg '  ' .. line
				endfor
				call delete(param['arg'])
			endif
		endfor
	endif
endfunction

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
endfunction

function s:echomsg(msg, text) abort
	if a:msg == 'Updating'
		echohl Title
	elseif a:msg == 'Installing'
		echohl Type
	else
		echohl PreProc
	endif
	echomsg printf('%s %s', a:msg, a:text)
	echohl None
endfunction

