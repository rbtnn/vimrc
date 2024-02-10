
let g:loaded_develop_terminal = 1
let s:term_cmd = [&shell]

if has('win32') && executable('wmic') && has('gui_running')
    function! s:outcb(ch, mes) abort
        if 14393 < str2nr(trim(a:mes))
            let s:term_cmd = ['cmd.exe', '/k', 'doskey pwd=cd && doskey ls=dir /b && set prompt=$E[32m$$$E[0m']
        endif
    endfunction
    call job_start('wmic os get BuildNumber', { 'out_cb': function('s:outcb'), })
endif

command! -nargs=0 Terminal
    \ :call term_start(s:term_cmd, {
    \   'term_highlight' : 'Terminal',
    \   'term_finish' : 'close',
    \   'term_kill' : 'kill',
    \ })
