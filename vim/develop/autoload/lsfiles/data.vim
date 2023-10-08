
let s:data = get(s:, 'data', {})

function! s:init(rootdir) abort
    if empty(a:rootdir)
        return {}
    else
        let s:data[(a:rootdir)] = get(s:data, a:rootdir, {})
        return s:data[(a:rootdir)]
    endif
endfunction

function! lsfiles#data#get_query(rootdir) abort
    let d = s:init(a:rootdir)
    return get(d, 'query', '')
endfunction

function! lsfiles#data#set_query(rootdir, query_text) abort
    let d = s:init(a:rootdir)
    let d['query'] = a:query_text
endfunction

function! lsfiles#data#get_paths(rootdir) abort
    let d = s:init(a:rootdir)
    return get(d, 'paths', [])
endfunction

function! s:filtered(path) abort
    if a:path =~# '/$'
        return v:false
    elseif -1 != index(g:lsfiles_ignore_exts, fnamemodify(a:path, ':e'))
        return v:false
    else
        for pat in g:lsfiles_ignore_patterns
            if a:path =~# pat
                return v:false
            endif
        endfor
        return v:true
    endif
endfunction

function! lsfiles#data#set_paths(rootdir, paths) abort
    let d = s:init(a:rootdir)
    let d['paths'] = filter(a:paths, { _,x -> s:filtered(x) })
endfunction

function! lsfiles#data#get_elapsed_time(rootdir) abort
    let d = s:init(a:rootdir)
    return get(d, 'elapsed_time', -1.0)
endfunction

function! lsfiles#data#set_elapsed_time(rootdir, elapsed_time) abort
    let d = s:init(a:rootdir)
    let d['elapsed_time'] = a:elapsed_time
endfunction

function! lsfiles#data#get_cmd_name(rootdir) abort
    let d = s:init(a:rootdir)
    return get(d, 'cmd_name', '')
endfunction

function! lsfiles#data#set_cmd_name(rootdir, cmd_name) abort
    let d = s:init(a:rootdir)
    let d['cmd_name'] = a:cmd_name
endfunction

