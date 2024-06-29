if executable('git')
    command! -nargs=* -complete=customlist,GitDiffComp  GitDiff      :call s:git_diff(<q-args>)
    command! -nargs=1                                   GitGrep      :call s:git_grep(<q-args>)

    function! s:git_diff(q_bang) abort
        if isdirectory(s:git_get_rootdir())
            call s:gitdiff_open_numstatwindow(a:q_bang)
        else
            echohl Error
            echo '[git] The directory is not under git control!'
            echohl None
        endif
    endfunction

    function! s:git_grep(q_args) abort
        let rootdir = s:git_get_rootdir()
        if isdirectory(rootdir)
            let lines = s:git_system(['grep', '--line-number', '--column', '--no-color', a:q_args])
            call setqflist([])
            if !empty(lines)
                let xs = []
                for line in lines
                    let m = matchlist(line, '^\(.\+\):\(\d\+\):\(\d\+\):\(.*\)$')
                    if !empty(m)
                        let xs += [{
                            \ 'filename': rootdir .. '/' .. s:iconv_wrapper(m[1]),
                            \ 'lnum': str2nr(m[2]),
                            \ 'col': m[3],
                            \ 'text': s:iconv_wrapper(m[4]), }]
                    else
                        let xs += [{ 'text': line, }]
                    endif
                endfor
                call setqflist(xs)
                copen
            endif
        else
            echohl Error
            echo '[git] The directory is not under git control!'
            echohl None
        endif
    endfunction

    function! GitDiffComp(ArgLead, CmdLine, CursorPos) abort
        let rootdir = s:git_get_rootdir()
        let xs = ['--cached', 'HEAD']
        if isdirectory(rootdir)
            if isdirectory(rootdir .. '/.git/refs/heads')
                let xs += readdir(rootdir .. '/.git/refs/heads')
            endif
            if isdirectory(rootdir .. '/.git/refs/tags')
                let xs += readdir(rootdir .. '/.git/refs/tags')
            endif
        endif
        return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
    endfunction

    function! s:gitdiff_open_diffwindow(args, path) abort
        if s:execute_gitdiff('diff', ['diff'] + a:args + ['--', a:path])
            let b:gitdiff = { 'args': a:args, 'path': a:path, }
            nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_enter()<cr>
            nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
            nnoremap <buffer><C-o> <nop>
            nnoremap <buffer><C-i> <nop>
        endif
    endfunction

    function! s:gitdiff_open_numstatwindow(q_args) abort
        if s:execute_gitdiff('gitdiff-numstat', ['diff', '--numstat'] + split(a:q_args, '\s\+'))
            let b:gitdiff = { 'args': split(a:q_args, '\s\+'), 'rootdir': s:git_get_rootdir(), }
            nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_openfile()<cr>
            nnoremap <buffer>D     <Cmd>call <SID>bufferkeymap_enter()<cr>
            nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
            nnoremap <buffer><C-o> <nop>
            nnoremap <buffer><C-i> <nop>
        endif
    endfunction

    function! s:execute_gitdiff(ft, cmd) abort
        let exists = v:false
        for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
            if a:ft == getbufvar(w['bufnr'], '&filetype', '')
                execute printf('%dwincmd w', w['winnr'])
                let exists = v:true
                break
            endif
        endfor
        if !exists
            if !&modified && &modifiable && empty(&buftype) && !filereadable(bufname())
                " use the current buffer.
            else
                new
            endif
            execute 'setfiletype' a:ft
            setlocal nolist
        endif
        if &filetype == a:ft
            if &filetype == 'gitdiff-numstat'
                syntax match  DiffAdd     '^\d\+'
                syntax match  DiffDelete  '\t\d\+\t'
            endif
            let &l:statusline = printf('[git] %s', join(a:cmd))
            let lines = filter(s:git_system(a:cmd), { _,x -> !empty(x) })
            if empty(lines)
                echohl Error
                echo '[git] No modified'
                echohl None
                if (1 < winnr('$')) || (1 < tabpagenr('$'))
                    close
                endif
            else
                call s:setbuflines(lines)
                " The lines encodes after redrawing.
                if g:vimrc.git_enabled_qficonv
                    " Redraw windows because the encoding process is very slowly.
                    redraw
                    for i in range(0, len(lines) - 1)
                        let lines[i] = s:iconv_wrapper(lines[i])
                    endfor
                    call s:setbuflines(lines)
                endif
                return v:true
            endif
        endif
        return v:false
    endfunction

    function! s:bufferkeymap_enter() abort
        if &filetype == 'diff'
            call s:gitdiff_jumpdiffline()
        elseif &filetype == 'gitdiff-numstat'
            let path = trim(get(split(getline('.'), "\t") , 2, ''))
            let path = expand(b:gitdiff['rootdir'] .. '/' .. path)
            if filereadable(path)
                call s:gitdiff_open_diffwindow(b:gitdiff['args'], path)
            endif
        endif
    endfunction

    function! s:bufferkeymap_openfile() abort
        if &filetype == 'gitdiff-numstat'
            let path = trim(get(split(getline('.'), "\t") , 2, ''))
            let path = expand(b:gitdiff['rootdir'] .. '/' .. path)
            if filereadable(path)
                call s:open_file(path, -1)
            endif
        endif
    endfunction

    function! s:bufferkeymap_bang() abort
        let wnr = winnr()
        let lnum = line('.')
        if &filetype == 'diff'
            call s:gitdiff_open_diffwindow(b:gitdiff['args'], b:gitdiff['path'])
        elseif &filetype == 'gitdiff-numstat'
            call s:gitdiff_open_numstatwindow(join(b:gitdiff['args']))
        endif
        execute printf(':%dwincmd w', wnr)
        call cursor(lnum, 0)
    endfunction

    function! s:gitdiff_jumpdiffline() abort
        let x = s:parse_diffoutput()
        if !empty(x)
            call s:open_file(x['path'], x['after_lnum'])
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
                return { 'after_lnum': after_lnum, 'before_lnum': before_lnum, 'path': expand(s:git_get_rootdir() .. '/' .. relpath) }
            endif
        endif

        return {}
    endfunction

    function! s:setbuflines(lines) abort
        setlocal modifiable noreadonly
        silent! call deletebufline(bufnr(), 1, '$')
        call setbufline(bufnr(), 1, a:lines)
        setlocal buftype=nofile nomodifiable readonly
    endfunction

    function! s:git_get_rootdir(path = '.') abort
        let xs = split(fnamemodify(a:path, ':p'), '[\/]')
        let prefix = (has('mac') || has('linux')) ? '/' : ''
        while !empty(xs)
            let path = prefix .. join(xs + ['.git'], '/')
            if isdirectory(path) || filereadable(path)
                return prefix .. join(xs, '/')
            endif
            call remove(xs, -1)
        endwhile
        return ''
    endfunction

    function s:git_system(subcmd) abort
        let cmd_prefix = ['git', '--no-pager']
        let cwd = s:git_get_rootdir()
        let lines = []
        let path = tempname()
        try
            let job = job_start(cmd_prefix + a:subcmd, {
                \ 'cwd': cwd,
                \ 'out_io': 'file',
                \ 'out_name': path,
                \ 'err_io': 'out',
                \ })
            while 'run' == job_status(job)
            endwhile
            if filereadable(path)
                let lines = readfile(path)
            endif
        finally
            if filereadable(path)
                call delete(path)
            endif
        endtry
        return lines
    endfunction

    function s:iconv_wrapper(text) abort
        if has('win32') && (&encoding == 'utf-8') && exists('g:loaded_qficonv') && (len(a:text) < g:vimrc.qficonv_columns)
            return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
        else
            return a:text
        endif
    endfunction

    function! s:open_file(path, lnum = 0, col = 0) abort
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
endif
