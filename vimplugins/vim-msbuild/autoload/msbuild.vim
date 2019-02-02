
let s:jobs = []
let s:cnt = 0

function! msbuild#exec(q_args) abort
    let path = fnamemodify(findfile('msbuild.xml', ';.'), ':p')
    if filereadable(path)
        let rootdir = fnamemodify(path, ':h')
        let args = s:trim(a:q_args)
        let cmd = [(has('win32')
                \ ? 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe'
                \ : 'xbuild'), '/nologo']
        if !empty(args)
            let cmd += split(args, '\s\+')
        endif
        let cmd += [path]
        call s:job_new(cmd, rootdir, function('s:close_handler_msbuild', [rootdir, cmd]))
    else
        call s:error('Can not found msbuild.xml.')
    endif
endfunction

function! s:close_handler_msbuild(rootdir, cmd, output)
    let lines = a:output
    call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
    let xs = []
    let errcnt = 0
    for line in lines
        let dict = {}
        let m = matchlist(line, '^\s*\([^(]*\)(\(\d\+\),\(\d\+\)):\s*\(error\|warning\)\s\+\(.*\)$')
        if !empty(m)
            let fullpath = m[1]
            if !filereadable(fullpath)
                let fullpath = fnamemodify(printf('%s/%s', a:rootdir, m[1]), ':p')
            endif
            if filereadable(fullpath)
                let dict.filename = fullpath
            endif
        endif
        if has_key(dict, 'filename')
            let dict.lnum = m[2]
            let dict.col = m[3]
            if (m[4] == 'error')
                let dict.type = 'E'
                let errcnt += 1
            elseif (m[4] == 'warning')
                let dict.type = 'W'
            endif
            let dict.text = m[5]
        else
            let dict.text = line
        endif
        let xs += [dict]
    endfor
    call setqflist(xs)
    call setqflist([], 'r', { 'title': printf('(%s) %s', a:rootdir, join(a:cmd, ' ')), })
    if 0 < errcnt
        call s:error('Build failure.')
    else
        let not_exists = 0
        for line in lines
            if line =~# 'MSBUILD : error MSB1009:'
                let not_exists = 1
                call s:error(line)
                break
            endif
        endfor
        if !not_exists
            call s:echo('Build succeeded.')
        endif
    endif
endfunction

function! s:trim(str) abort
    return matchstr(a:str, '^\s*\zs.\{-\}\ze\s*$')
endfunction

function! s:echo(msg) abort
    echohl ModeMsg
    echo printf('%s', a:msg)
    echohl None
endfunction

function! s:error(msg) abort
    echohl ErrorMsg
    echomsg printf('%s', a:msg)
    echohl None
endfunction

function! s:job_new(cmd, cwd, callback) abort
    let expanded_cwd = expand(sillyiconv#iconv_one_nothrow(a:cwd))
    let job = job_start(a:cmd, {
        \ 'close_cb' : function('s:handler_close_cb', [(a:callback)]),
        \ 'cwd' : expanded_cwd,
        \ 'in_io' : 'pipe',
        \ 'out_io' : 'pipe',
        \ 'err_io' : 'out',
        \ })
    let s:jobs += [{
        \   'timestamp' : strftime('%c'),
        \   'cmd' : join(a:cmd),
        \   'cwd' : expanded_cwd,
        \   'job' : job,
        \ }]
    call timer_start(1000, function('s:job_outcb'), { 'repeat' : -1, })
    return job
endfunction

function! s:handler_close_cb(callback, channel) abort
    let lines = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let lines += [ch_read(a:channel)]
    endwhile
    call a:callback(lines)
endfunction

function! s:job_outcb(timer) abort
    let nojob = 1
    for x in s:jobs
        if job_status(x.job) == 'run'
            call s:echo(printf('(%s) %s', x.job, repeat('.', s:cnt)))
            let s:cnt = (s:cnt + 1) % 5
            let nojob = 0
            break
        endif
    endfor
    if nojob
        call timer_stop(a:timer)
    endif
endfunction
