
function! fileopener#open_file(path, lnum = 0, col = 0) abort
    if filereadable(a:path)
        if s:find_window_by_path(a:path)
        elseif s:can_open_in_current() && (&filetype != 'diff')
            silent! execute printf('edit %s', fnameescape(a:path))
        else
            silent! execute printf('new %s', fnameescape(a:path))
        endif
        if (0 < a:lnum) || (0 < a:col)
            call cursor(a:lnum, a:col)
        endif
        normal! zz
    endif
endfunction

function! s:find_window_by_path(path) abort
    for x in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
        if x['bufnr'] == s:strict_bufnr(a:path)
            execute printf(':%dwincmd w', x['winnr'])
            return v:true
        endif
    endfor
    return v:false
endfunction

function! s:strict_bufnr(path) abort
    let bnr = bufnr(a:path)
    if -1 == bnr
        return -1
    else
        let fname1 = fnamemodify(a:path, ':t')
        let fname2 = fnamemodify(bufname(bnr), ':t')
        if fname1 == fname2
            return bnr
        else
            return -1
        endif
    endif
endfunction

function! s:can_open_in_current() abort
    let tstatus = term_getstatus(bufnr())
    if (tstatus != 'finished') && !empty(tstatus)
        return v:false
    elseif !empty(getcmdwintype())
        return v:false
    elseif &modified
        return v:false
    else
        return v:true
    endif
endfunction
