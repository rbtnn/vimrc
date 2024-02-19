
let s:curr_job = get(s:, 'curr_job', v:null)
let s:match_items = get(s:, 'match_items', [])

function! qfjob#start(cmd, ...) abort
    call s:kill_job()
    let s:match_items = []
    call setqflist(s:match_items)
    let opts = get(a:000, 0, {})
    let s:curr_job = job_start(a:cmd, {
        \ 'cwd': get(opts, 'cwd', getcwd()),
        \ 'close_cb': function('s:close_cb', [opts]),
        \ 'out_cb': function('s:out_cb'),
        \ 'err_io': 'out',
        \ })
endfunction

function! s:kill_job() abort
    if (v:null != s:curr_job) && ('run' == job_status(s:curr_job))
        call job_stop(s:curr_job, 'kill')
        let s:curr_job = v:null
    endif
endfunction

function s:out_cb(ch, msg, ...) abort
    call extend(s:match_items, [a:msg])
endfunction

function s:close_cb(opts, ...) abort
    let title = get(a:opts, 'title', 'NO NAME')
    let xs = []
    try
        if has_key(a:opts, 'line_parser')
            for item in s:match_items
                let x = a:opts.line_parser(item)
                if !empty(x)
                    let xs += [x]
                    redraw
                endif
                if get(a:opts, 'echo', v:true)
                    echo printf('[%s] The job has finished! Please wait to build the quickfix... (%d%%)', title, len(xs) * 100 / len(s:match_items))
                endif
            endfor
        endif
    catch /^Vim:Interrupt$/
        redraw
        if get(a:opts, 'echo', v:true)
            echo printf('[%s] Interrupt!', title)
        endif
    finally
        if empty(xs)
            if get(a:opts, 'echo', v:true)
                echo printf('[%s] No result', title)
            endif
        else
            call setqflist(xs)
            if get(a:opts, 'echo', v:true)
                echo printf('[%s] %d results', title, len(xs))
            endif
        endif
        if has_key(a:opts, 'then_cb')
            call a:opts.then_cb()
        endif
    endtry
endfunction
