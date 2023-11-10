
function! git#diff#diff#jumpdiffline(rootdir) abort
    let x = s:calc_lnum(a:rootdir)
    if !empty(x)
        if filereadable(x['path'])
            if s:find_window_by_path(x['path'])
                execute printf(':%d', x['lnum'])
            else
                execute printf('new +%d %s', x['lnum'], fnameescape(x['path']))
            endif
        endif
        normal! zz
    endif
endfunction

function! s:calc_lnum(rootdir) abort
    let lines = getbufline(bufnr(), 1, '$')
    let curr_lnum = line('.')
    let lnum = -1
    let relpath = ''

    for m in range(curr_lnum, 1, -1)
        if lines[m - 1] =~# '^@@'
            let lnum = m
            break
        endif
    endfor
    for m in range(curr_lnum, 1, -1)
        if lines[m - 1] =~# '^+++ '
            let relpath = matchstr(lines[m - 1], '^+++ \zs.\+$')
            let relpath = substitute(relpath, '^b/', '', '')
            let relpath = substitute(relpath, '\s\+(working copy)$', '', '')
            let relpath = substitute(relpath, '\s\+(revision \d\+)$', '', '')
            break
        endif
    endfor

    if (lnum < curr_lnum) && (0 < lnum)
        let n1 = 0
        let n2 = 0
        for n in range(lnum + 1, curr_lnum)
            let line = lines[n - 1]
            if line =~# '^-'
                let n2 += 1
            elseif line =~# '^+'
                let n1 += 1
            endif
        endfor
        let n3 = curr_lnum - lnum - n1 - n2 - 1
        let m = []
        let m2 = matchlist(lines[lnum - 1], '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\?\s*@@\(.*\)$')
        let m3 = matchlist(lines[lnum - 1], '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
        if !empty(m2)
            let m = m2
        elseif !empty(m3)
            let m = m3
        endif
        if !empty(m)
            for i in [1, 3, 5]
                if '+' == m[i]
                    let lnum = str2nr(m[i + 1]) + n1 + n3
                    return { 'lnum': lnum, 'path': expand(a:rootdir .. '/' .. relpath) }
                endif
            endfor
        endif
    endif

    return {}
endfunction

function! s:strict_bufnr(path) abort
    let bnr = bufnr(a:path)
    let fname1 = fnamemodify(a:path, ':t')
    let fname2 = fnamemodify(bufname(bnr), ':t')
    if (-1 == bnr) || (fname1 != fname2)
        return -1
    else
        return bnr
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
