
function! label#string(...) abort
    let w = getwininfo((0 < a:0) ? a:1 : win_getid())[0]
    let ft = getbufvar(w.bufnr, '&filetype')
    if w.terminal
        if exists('*term_getstatus')
            return printf('[Terminal](%s)', term_getstatus(w.bufnr))
        else
            return '[Terminal]'
        endif
    elseif w.quickfix
        return '[QuickFix]'
    elseif w.loclist
        return '[LocList]'
    elseif (win_getid() == w.winid) && !empty(getcmdwintype())
        return '[Command Line]'
    elseif 'diff' == ft
        return '[Diff]'
    else
        for x in map(split(&runtimepath, ','), { i, x -> fnamemodify(x, ':t') })
            for m in [matchlist(x, '^vim-\(.\+\)$'), matchlist(x, '^\(.\+\)\.vim$')]
                if !empty(m)
                    if m[1] == ft
                        return '[' .. toupper(ft[0]) .. ft[1:] .. ']'
                    endif
                endif
            endfor
        endfor
        let s = '[No Name]'
        let name = bufname(w.bufnr)
        if !empty(name)
            let modi = getbufvar(w.bufnr, '&modified')
            let read = getbufvar(w.bufnr, '&readonly')
            if filereadable(name)
                let name = fnamemodify(name, ':t')
            endif
            let s = printf('%s%s%s', (read ? '[R]' : ''), (modi ? '[+]' : ''), name)
        endif
        return s
    endif
endfunction

