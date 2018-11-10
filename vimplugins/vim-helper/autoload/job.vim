
let s:jobs = []
let s:cnt = 0

function! job#new(cmd, cwd, callback) abort
    let expanded_cwd = expand(a:cwd)
    let job = job_start(a:cmd, {
            \ 'close_cb' : function('s:handler_close_cb', [(a:callback)]),
            \ 'cwd' : expand(a:cwd),
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

function! s:job_outcb(timer) abort
    let nojob = 1
    for x in s:jobs
        if job_status(x.job) == 'run'
            call helper#echo(printf('(%s) %s', x.job, repeat('.', s:cnt)))
            let s:cnt = (s:cnt + 1) % 5
            let nojob = 0
            break
        endif
    endfor
    if nojob
        call timer_stop(a:timer)
    endif
endfunction

function! job#list() abort
    let newjobs = []
    for x in s:jobs
        if job_info(x.job).status == 'run'
            let newjobs += [x]
        endif
    endfor
    let xs = [printf('--- JOBS(%d) ---', len(newjobs))]
    for x in newjobs
        let xs += [printf('%s: %s: %s', x.timestamp, x.job, x.cmd)]
    endfor
    call helper#echo(join(xs, "\n"))
    let s:jobs = newjobs
endfunction

function! job#kill() abort
    for x in s:jobs
        if job_info(x.job).status == 'run'
            call job_stop(x.job, 'kill')
        endif
    endfor
endfunction

function! job#new_on_toplevel(cmd, target, callback) abort
    if executable('git')
        call job#new(['git', 'rev-parse', '--show-toplevel'], a:target,
                \ function('s:handler_new_on_toplevel', [(a:callback), (a:cmd)]))
    else
        call helper#error('Can not execute git!')
    endif
endfunction

function! s:handler_close_cb(callback, channel) abort
    let lines = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let lines += [ch_read(a:channel)]
    endwhile
    call a:callback(lines)
endfunction

function! s:handler_new_on_toplevel(callback, cmd, output) abort
    let toplevel = substitute(get(a:output, 0, ''), "\n", '', 'g')
    if empty(toplevel) || (toplevel =~# '^fatal:')
        call helper#error('fatal: Not a git repository (or any of the parent directories): .git')
    else
        call job#new(a:cmd, toplevel, function(a:callback, [toplevel]))
    endif
endfunction

