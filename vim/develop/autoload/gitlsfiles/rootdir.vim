
function! gitlsfiles#rootdir#get(path = '.', cmdname = 'git') abort
    let xs = split(fnamemodify(a:path, ':p'), '[\/]')
    let prefix = (has('mac') || has('linux')) ? '/' : ''
    while !empty(xs)
        let path = prefix .. join(xs + ['.' .. a:cmdname], '/')
        if isdirectory(path) || filereadable(path)
            return prefix .. join(xs, '/')
        endif
        call remove(xs, -1)
    endwhile
    return ''
endfunction

