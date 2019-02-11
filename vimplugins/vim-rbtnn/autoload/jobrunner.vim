
let s:jobs = get(s:, 'jobs', [])
let s:cnt = 0

function jobrunner#killall() abort
    for x in s:jobs
        call job_stop(x.job, 'kill')
    endfor
endfunction

function jobrunner#new(cmd, cwd, callback) abort
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

function jobrunner#echo(msg) abort
    echohl ModeMsg
    echo printf('%s', a:msg)
    echohl None
endfunction

function jobrunner#error(msg) abort
    echohl ErrorMsg
    echomsg printf('%s', a:msg)
    echohl None
endfunction

function jobrunner#new_window(lines) abort
    new
    let pos = getpos('.')
    let lines = a:lines
    setlocal noreadonly modifiable
    silent % delete _
    silent put=lines
    silent 1 delete _
    setlocal readonly nomodifiable
    setlocal buftype=nofile nolist nocursorline
    call setpos('.', pos)
    nnoremap <silent><buffer>q       :<C-u>execute ((winnr('$') == 1) ? 'bdelete' : 'quit')<cr>
endfunction

function s:job_outcb(timer) abort
    let nojob = 1
    for x in s:jobs
        if job_status(x.job) == 'run'
            call jobrunner#echo(printf('(%s) %s', x.job, repeat('.', s:cnt)))
            let s:cnt = (s:cnt + 1) % 5
            let nojob = 0
            break
        endif
    endfor
    if nojob
        call timer_stop(a:timer)
    endif
endfunction

function s:handler_close_cb(callback, channel) abort
    let lines = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let lines += [ch_read(a:channel)]
    endwhile
    call a:callback(lines)
endfunction

