
let s:data = get(s:, 'data', {})

function! s:init(rootdir) abort
    if empty(a:rootdir)
        return {}
    else
        let s:data[(a:rootdir)] = get(s:data, a:rootdir, {})
        return s:data[(a:rootdir)]
    endif
endfunction

function! git#lsfiles#data#get_query(rootdir) abort
    let d = s:init(a:rootdir)
    return get(d, 'query', '')
endfunction

function! git#lsfiles#data#set_query(rootdir, query_text) abort
    let d = s:init(a:rootdir)
    let d['query'] = a:query_text
endfunction

function! git#lsfiles#data#get_paths(rootdir) abort
    let d = s:init(a:rootdir)
    return get(d, 'paths', [])
endfunction

function! s:filtered(path) abort
    if a:path =~# '/$'
        return v:false
    elseif -1 != index(g:git_lsfiles_ignore_exts, fnamemodify(a:path, ':e'))
        return v:false
    else
        for pat in g:git_lsfiles_ignore_patterns
            if a:path =~# pat
                return v:false
            endif
        endfor
        return v:true
    endif
endfunction

function! git#lsfiles#data#set_paths(rootdir, paths) abort
    let d = s:init(a:rootdir)
    let d['paths'] = filter(a:paths, { _,x -> s:filtered(x) })
endfunction
