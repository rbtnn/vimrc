
function! git#diff#diff#jumpdiffline() abort
    let x = s:parse_diffoutput()
    if !empty(x)
        call fileopener#open_file(x['path'], x['after_lnum'])
    endif
endfunction

function! s:parse_diffoutput() abort
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
            break
        endif
    endfor

    if (lnum < curr_lnum) && (0 < lnum)
        let after_n = 0
        let before_n = 0
        for n in range(lnum + 1, curr_lnum)
            let line = lines[n - 1]
            if line =~# '^-'
                let before_n += 1
            elseif line =~# '^+'
                let after_n += 1
            endif
        endfor
        let n3 = curr_lnum - lnum - after_n - before_n - 1
        let m = []
        let m2 = matchlist(lines[lnum - 1], '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\?\s*@@\(.*\)$')
        let m3 = matchlist(lines[lnum - 1], '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
        if !empty(m2)
            let m = m2
        elseif !empty(m3)
            let m = m3
        endif
        if !empty(m)
            let after_lnum = -1
            let before_lnum = -1
            for i in [1, 3, 5]
                if '+' == m[i]
                    let after_lnum = str2nr(m[i + 1]) + after_n + n3
                elseif '-' == m[i]
                    let before_lnum = str2nr(m[i + 1]) + before_n + n3
                endif
            endfor
            return { 'after_lnum': after_lnum, 'before_lnum': before_lnum, 'path': expand(git#internal#get_rootdir() .. '/' .. relpath) }
        endif
    endif

    return {}
endfunction
