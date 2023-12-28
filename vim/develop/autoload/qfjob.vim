
let s:qfjobs = get(s:, 'qfjobs', {})

function! qfjob#start(cmd, ...) abort
    call qfjob#kill_jobs()
    cclose
    let id = sha256(tempname())
    let items = []
    let opts = get(a:000, 0, {})
    if has('nvim')
        let s:qfjobs[id] = jobstart(a:cmd, {
            \ 'cwd': get(opts, 'cwd', getcwd()),
            \ 'on_stdout': function('s:out_cb', [items]),
            \ 'on_stderr': function('s:out_cb', [items]),
            \ 'on_exit': function('s:exit_cb', [items, id, opts]),
            \ })
    else
        let s:qfjobs[id] = job_start(a:cmd, {
            \ 'cwd': get(opts, 'cwd', getcwd()),
            \ 'exit_cb': function('s:exit_cb', [items, id, opts]),
            \ 'out_cb': function('s:out_cb', [items]),
            \ 'err_io': 'out',
            \ })
    endif
    return id
endfunction

function! qfjob#show_jobs() abort
    for key in keys(s:qfjobs)
        if s:qfjobs[key] != v:null
            echo s:qfjobs[key]
        endif
    endfor
endfunction

function! qfjob#kill_jobs() abort
    for key in keys(s:qfjobs)
        if s:qfjobs[key] != v:null
            call job_stop(s:qfjobs[key], 'kill')
        endif
    endfor
endfunction

function! qfjob#stop(id) abort
    if get(s:qfjobs, 'id', v:null) != v:null
        if has('nvim')
            call jobstop(s:qfjobs[a:id])
        else
            if 'run' == job_status(s:qfjobs[a:id])
                call job_stop(s:qfjobs[a:id], 'kill')
            endif
        endif
    endif
    let s:qfjobs[a:id] = v:null
endfunction

function s:out_cb(items, ch, msg, ...) abort
    if has('nvim')
        call extend(a:items, a:msg)
    else
        call extend(a:items, [a:msg])
    endif
endfunction

function s:exit_cb(items, id, opts, ...) abort
    let title = get(a:opts, 'title', 'NO NAME')
    let xs = []
    try
        if has_key(a:opts, 'line_parser')
            for item in a:items
                let x = a:opts.line_parser(item)
                if !empty(x)
                    let xs += [x]
                    redraw
                endif
                echo printf('[%s] The job has finished! Please wait to build the quickfix... (%d%%)', title, len(xs) * 100 / len(a:items))
            endfor
        endif
    catch /^Vim:Interrupt$/
        redraw
        echo printf('[%s] Interrupt!', title)
    finally
        if empty(xs)
            echo printf('[%s] No result', title)
        else
            call setqflist(xs)
            let bnr = bufnr()
            silent! copen
            if has_key(a:opts, 'keep_cursor')
                if a:opts.keep_cursor
                    call win_gotoid(bufwinid(bnr))
                endif
            endif
        endif
        call qfjob#stop(a:id)
    endtry
endfunction

