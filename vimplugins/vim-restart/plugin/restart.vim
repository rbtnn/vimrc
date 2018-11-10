
let g:loaded_restart = 1

if has('win32') && has('gui_running')
    function! s:restart(q_args) abort
        let path = v:progpath
        if filereadable(path)
            let new_servername = printf('GVIM-%d', len(serverlist()))
            rviminfo!
            execute printf('!start %s --servername %s %s', fnameescape(path), new_servername, a:q_args)
            while index(split(serverlist(), '\n'), new_servername) < 0
                sleep 250m
            endwhile
            qall!
        endif
    endfunction

    command! -nargs=0 -bar Restart             :call <SID>restart('')
    command! -nargs=0 -bar RestartNoPlugin     :call <SID>restart('-u NONE -N --noplugin')
endif
