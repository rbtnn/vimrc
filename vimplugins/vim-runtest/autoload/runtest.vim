
let s:testlog = 'test.log'
let s:cnt = 0
let s:stop = 0

function! runtest#comp(ArgLead, CmdLine, CursorPos) abort
    return filter(split(glob('test_*.vim'), "\n"), { i,x -> -1 != match(x, a:ArgLead) })
endfunction

function! runtest#stop() abort
    let s:stop = 1
endfunction

function! runtest#start(args) abort
    let s:stop = 0
    let path = a:args
    if empty(path)
        let path = expand('%')
    endif
    if (fnamemodify(getcwd(), ':t') == 'testdir')
        if (executable('../vim'))
            if filereadable(s:testlog)
                call delete(s:testlog)
            endif
            let job = job_start(
                \ printf('../vim -u NONE -U NONE --noplugin --not-a-term -S runtest.vim %s', path),
                \ { 'exit_cb' : function('s:runtest_exitcb', [path]), }
                \ )
            call timer_start(1000, function('s:runtest_outcb', [path, job]), { 'repeat' : -1, })
        else
            call s:error('"../vim" is not executable!')
        endif
    else
        call s:error('Please change directory to testdir!')
    endif
endfunction

function! s:runtest_exitcb(path, channel, msg) abort
    if filereadable(s:testlog)
        call s:new_window(readfile(s:testlog))
    elseif s:stop
        call s:echo(printf('(stop) %s', a:path))
    else
        call s:echo(printf('(ok) %s', a:path))
    endif
endfunction

function! s:runtest_outcb(path, job, timer) abort
    if s:stop
        call job_stop(a:job , 'kill')
    endif
    if job_status(a:job) == 'run'
        call s:echo(printf('(%s) %s %s', a:job, a:path, repeat('.', s:cnt)))
    else
        call timer_stop(a:timer)
    endif
    let s:cnt = (s:cnt + 1) % 5
endfunction

function! s:error(msg) abort
    echohl ErrorMsg
    echo printf('[runtest] %s', a:msg) 
    echohl None
endfunction

function! s:echo(msg) abort
    echohl ModeMsg
    echo printf('[runtest] %s', a:msg) 
    echohl None
endfunction

function! s:new_window(lines) abort
    new
    let lines = a:lines
    setlocal noreadonly modifiable
    silent % delete _
    silent put=lines
    silent 1 delete _
    setlocal readonly nomodifiable
    setlocal buftype=nofile nolist nocursorline
    nnoremap <silent><buffer>q       :<C-u>quit<cr>
endfunction

