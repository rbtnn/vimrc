
function! pack#sync(pack_dir, start_d, ...) abort
	let opt_d = 0 < a:0 ? a:1 : {}
	let params = s:make_params(a:pack_dir, a:start_d, opt_d)
	call s:start_jobs(params)
	call s:wait_jobs(params)
	call s:delete_unmanaged_plugins(a:pack_dir, a:start_d, opt_d)
endfunction

function! s:make_params(pack_dir, start_d, opt_d) abort
	let base_cmd = 'git -c credential.helper= '
	let params = []
	for d in [a:start_d, a:opt_d]
		let start_or_opt = (d == a:start_d ? 'start' : 'opt')
		for username in keys(d)
			let pack_dir = expand(join([a:pack_dir, 'pack', username, start_or_opt], '/'))
			if !isdirectory(pack_dir)
				call mkdir(pack_dir, 'p')
			endif
			for plugin_name in d[username]
				let plugin_dir = pack_dir .. '/' .. plugin_name
				if isdirectory(plugin_dir)
					let params += [{
						\   'name': printf('%s/%s', username, plugin_name),
						\   'cmd': printf('%s fetch', base_cmd),
						\   'cwd': plugin_dir,
						\   'arg': has('nvim') ? { 'lines': [] } : tempname(),
						\   'job': v:null,
						\   'msg': 'Updating',
						\   'running': v:true,
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
						\   'running': v:true,
						\ }]
				endif
			endfor
		endfor
	endfor
	return params
endfunction

function! s:delete_unmanaged_plugins(pack_dir, start_d, opt_d) abort
	for d in [a:start_d, a:opt_d]
		let start_or_opt = (d == a:start_d ? 'start' : 'opt')
		for x in split(globpath(join([a:pack_dir, 'pack', '*', start_or_opt], '/'), '*'), "\n")
			let exists = v:false
			for username in keys(d)
				for plugin_name in d[username]
					if x =~# '[\/]' .. username .. '[\/]' .. start_or_opt .. '[\/]' .. plugin_name .. '$'
						let exists = v:true
						break
					endif
				endfor
			endfor
		endfor
		if !exists
			call s:delete_carefull(a:pack_dir, x)
		endif
		for x in split(globpath(join([a:pack_dir, 'pack', '*'], '/'), start_or_opt), "\n")
			if !len(readdir(x))
				call s:delete_carefull(a:pack_dir, x)
			endif
		endfor
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

function! s:start_jobs(params) abort
	if has('nvim')
		for param in a:params
			let param['job'] = jobstart(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'on_stdout': function('s:system_onevent', [param['arg']]),
				\ 'on_stderr': function('s:system_onevent', [param['arg']]),
				\ })
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
	endif
endfunction

function! s:wait_jobs(params) abort
	let n = 0
	while n < len(a:params)
		for param in a:params
			if !param['running']
				continue
			endif

			if has('nvim')
				if -1 == jobwait([param['job']], 0)[0]
					continue
				endif
			else
				if 'run' == job_status(param['job'])
					continue
				endif
			endif

			let n += 1
			let param['running'] = v:false
			call s:echomsg(param['msg'], param['name'])

			if has('nvim')
				for line in param['arg']['lines']
					if !empty(trim(line))
						echomsg '  ' .. line
					endif
				endfor
			else
				if filereadable(param['arg'])
					for line in readfile(param['arg'])
						if !empty(trim(line))
							echomsg '  ' .. line
						endif
					endfor
					call delete(param['arg'])
				endif
			endif
		endfor
	endwhile
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

