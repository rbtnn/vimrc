
if exists(':scriptversion')
    scriptversion 3
else
    finish
endif

let s:vim_version = ''

function version#get() abort
    if empty(s:vim_version)
        let lines = split(execute('version'), "\n")
        let patches = substitute(get(lines, 2, ''), 'Included patches: 1-', '', '')
        let s:vim_version = printf('Vim %d.%d.%04s', v:version / 100, v:version % 100, patches)
    endif
    return s:vim_version
endfunction

