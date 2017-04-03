
let s:jobs = []
let s:cnt = 0

function! diffy#exec(target, q_bang, q_args) abort
    let ok = 0
    if &filetype != 'diffy'
        let args = s:trim(a:q_args)
        let cmd = ['git', 'diff', '--stat-width=800', '--stat']
        if a:q_bang == '!'
            if args =~# '^[0-9a-f]\{7,\}$'
                let cmd += [printf('%s~1..%s', args, args)]
                let ok = 1
            endif
        else
            if !empty(args)
                let cmd += split(args, '\s\+')
            endif
            let ok = 1
        endif
    endif
    if ok
        call s:job_new_on_toplevel(cmd, a:target, function('s:handler_diffy_exec', [(cmd)]))
    endif
endfunction

function! s:handler_diffy_exec(cmd, toplevel, output)
    let lines = []
    let max = 0

    call map(a:output, { i,x -> sillyiconv#iconv_one_nothrow(x) })

    " calcate the width of first column
    for line in a:output
        let xs = split(line, '|')
        if 2 == len(xs)
            if xs[1] !~ 'Bin'
                let w = strdisplaywidth(s:trim(xs[0]))
                if max < w
                    let max = w
                endif
            endif
        endif
    endfor

    " make lines
    for line in a:output
        let xs = split(line, '|')
        if 2 == len(xs)
            if xs[1] !~ 'Bin'
                let lines += [printf('%s | %s',
                        \ s:padding_right_space(s:trim(xs[0]), max), xs[1])]
            endif
        endif
    endfor

    " find the line about insertions and deletions
    for line in a:output
        if line =~# '^\s*\d\+ files changed, \d\+ insertions(+), \d\+ deletions(-)$'
            let lines = [('#' . line), '#'] + lines
            break
        endif
    endfor

    if 1 == len(lines)
        call diffy#git_diff(a:toplevel, lines[0], a:cmd)
    elseif 0 < len(lines)
        let lines = [
                \ '#',
                \ '# GitRootDirectory',
                \ '#   ' . a:toplevel,
                \ '#',
                \ '# KeyMapping',
                \ '#   return key: Open the file under the cursor',
                \ '#   d key:      Open diff-window under the cursor',
                \ '#   q key:      Close this window',
                \ '#',
                \ ] + lines
        call s:new_window(lines)
        setlocal filetype=diffy
        let &l:statusline = printf('[diffy] %s', join(a:cmd))
        execute printf("nnoremap <silent><buffer><nowait>d       :<C-u>call diffy#git_diff(%s, getline('.'), %s)<cr>", string(a:toplevel), string(a:cmd))
        execute printf("nnoremap <silent><buffer><nowait><cr>    :<C-u>call diffy#git_open(%s, getline('.'))<cr>", string(a:toplevel))
    else
        call s:error('No modified file!')
    endif
endfunction

function! s:close_handler_diff(cmd, toplevel, output)
    let lines = a:output
    if !empty(lines)
        let lines = [
                \ '#',
                \ '# GitRootDirectory',
                \ '#   ' . a:toplevel,
                \ '#',
                \ '# KeyMapping',
                \ '#   return key: Open the file at the cursor line',
                \ '#   [ key:      Go to a previous diff-section',
                \ '#   ] key:      Go to a next diff-section',
                \ '#   q key:      Close this window',
                \ '#',
                \ ] + lines
        call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
        call s:new_window(lines)
        wincmd H
        redraw!
        setlocal filetype=diff
        let &l:statusline = printf('[diffy] %s', join(a:cmd))
        execute printf('nnoremap <silent><buffer><nowait><cr>    :<C-u>call diffy#git_diff_jump(%s)<cr>', string(a:toplevel))
        execute printf('nnoremap <silent><buffer><nowait>[       :<C-u>call diffy#git_diff_prev(%s)<cr>zz', string(a:toplevel))
        execute printf('nnoremap <silent><buffer><nowait>]       :<C-u>call diffy#git_diff_next(%s)<cr>zz', string(a:toplevel))
    else
        call s:error('No modified!')
    endif
endfunction

function! diffy#git_open(toplevel, line) abort
    let path = diffy#get_path(a:toplevel, a:line)
    if filereadable(path)
        call s:open_file(path, -1)
    else
        call s:error('Can not jump this!')
    endif
endfunction

function! diffy#git_diff(toplevel, line, cmd) abort
    let path = diffy#get_path(a:toplevel, a:line)
    if filereadable(path)
        let args = ''
        let idx = index(a:cmd, '--stat')
        if 0 <= idx
            let args = join(a:cmd[(idx + 1):])
        endif
        let target = fnamemodify(path, ':h')
        let diffcmd = s:diffcmd(path, args)
        call s:job_new_on_toplevel(diffcmd, target,
            \ function('s:close_handler_diff', [diffcmd])
            \ )
    else
        call s:error('Can not jump this!')
    endif
endfunction

function! diffy#git_diff_prev(toplevel) abort
    if &l:filetype == 'diff'
        let pos = getpos('.')
        let found = 0
        let lnum = line('.')
        while 1
            if 0 < search('^[+-]', 'b')
                if lnum - 1 == line('.')
                    let lnum = line('.')
                else
                    let found = 1
                    break
                endif
            else
                break
            endif
        endwhile
        if !found
            call setpos('.', pos)
        endif
    else
        call s:error('filetype is not diff!')
    endif
endfunction

function! diffy#git_diff_next(toplevel) abort
    if &l:filetype == 'diff'
        let pos = getpos('.')
        let found = 0
        let lnum = line('.')
        while 1
            if 0 < search('^[+-]')
                if lnum + 1 == line('.')
                    let lnum = line('.')
                else
                    let found = 1
                    break
                endif
            else
                break
            endif
        endwhile
        if !found
            call setpos('.', pos)
        endif
    else
        call s:error('filetype is not diff!')
    endif
endfunction

function! diffy#git_diff_jump(toplevel) abort
    if &l:filetype == 'diff'
        let xs = s:get_path_and_lnum(a:toplevel)
        if !empty(xs)
            let [fullpath, lnum] = xs
            call s:open_file(fullpath, lnum)
        else
            call s:error('Can not jump this!')
        endif
    else
        call s:error('filetype is not diff!')
    endif
endfunction

function! diffy#get_path(toplevel, line) abort
    let m = matchlist(a:line, '^\s*\(.\{-\}\)\s*|.*$')
    if !empty(m)
        return fnamemodify(a:toplevel . '/' . m[1], ':p')
    else
        return ''
    endif
endfunction

function! s:diffcmd(fullpath, args) abort
    let cmd = ['git', 'diff', '--no-color']
    if !empty(a:args)
        let cmd += split(a:args, '\s\+')
    endif
    let cmd += ['--', (a:fullpath)]
    return cmd
endfunction

function! s:get_path_and_lnum(toplevel) abort
    let xs = []
    if getline('.') =~# '^[ +]'
        let lnum = search('^@@', 'bnW')
        let path = matchstr(getline(search('^+++ b/', 'bnW')), '^+++\s*b/\zs.*\ze$')
        let fullpath = fnamemodify(a:toplevel . '/' . path, ':p')
        let n = len(filter(map(range(lnum, line('.')), 'getline(v:val)'), 'v:val !~# "^-"'))
        let m2 = matchlist(getline(lnum), '^@@ [+-]\(\d\+\)\%(,\(\d\+\)\)\? [+-]\(\d\+\),\(\d\+\)\s*@@\(.*\)$')
        let m3 = matchlist(getline(lnum), '^@@@ [+-]\(\d\+\)\%(,\(\d\+\)\)\? [+-]\(\d\+\)\%(,\(\d\+\)\)\? [+-]\(\d\+\),\(\d\+\)\s*@@@\(.*\)$')
        if !empty(m2)
            let xs = [fullpath, (m2[3] + n - 2)]
        elseif !empty(m3)
            let xs = [fullpath, (m3[3] + n - 2)]
        endif
    endif
    return xs
endfunction

function! s:job_new(cmd, cwd, callback) abort
    let expanded_cwd = expand(sillyiconv#iconv_one_nothrow(a:cwd))
    let job = job_start(a:cmd, {
        \ 'close_cb' : function('s:handler_close_cb', [(a:callback)]),
        \ 'cwd' : expanded_cwd,
        \ 'in_io' : 'pipe',
        \ 'out_io' : 'pipe',
        \ 'err_io' : 'out',
        \ })
    let s:jobs += [{
        \   'timestamp' : strftime('%c'),
        \   'cmd' : join(a:cmd),
        \   'cwd' : expanded_cwd,
        \   'job' : job,
        \ }]
    call timer_start(1000, function('s:job_outcb'), { 'repeat' : -1, })
    return job
endfunction

function! s:job_outcb(timer) abort
    let nojob = 1
    for x in s:jobs
        if job_status(x.job) == 'run'
            call s:echo(printf('(%s) %s', x.job, repeat('.', s:cnt)))
            let s:cnt = (s:cnt + 1) % 5
            let nojob = 0
            break
        endif
    endfor
    if nojob
        call timer_stop(a:timer)
    endif
endfunction

function! s:job_new_on_toplevel(cmd, target, callback) abort
    if executable('git')
        call s:job_new(['git', 'rev-parse', '--show-toplevel'], a:target,
            \ function('s:handler_new_on_toplevel', [(a:callback), (a:cmd)]))
    else
        call s:error('Can not execute git!')
    endif
endfunction

function! s:handler_close_cb(callback, channel) abort
    let lines = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let lines += [ch_read(a:channel)]
    endwhile
    call a:callback(lines)
endfunction

function! s:handler_new_on_toplevel(callback, cmd, output) abort
    let toplevel = sillyiconv#iconv_one_nothrow(substitute(get(a:output, 0, ''), "\n", '', 'g'))
    if empty(toplevel) || (toplevel =~# '^fatal:')
        call s:error('fatal: Not a git repository (or any of the parent directories): .git')
    else
        call s:job_new(a:cmd, toplevel, function(a:callback, [toplevel]))
    endif
endfunction

function! s:padding_right_space(text, width)
    return a:text . repeat(' ', a:width - strdisplaywidth(a:text))
endfunction

function! s:trim(str) abort
    return matchstr(a:str, '^\s*\zs.\{-\}\ze\s*$')
endfunction

function! s:echo(msg) abort
    echohl ModeMsg
    echo printf('%s', a:msg)
    echohl None
endfunction

function! s:error(msg) abort
    echohl ErrorMsg
    echomsg printf('%s', a:msg)
    echohl None
endfunction

function! s:new_window(lines) abort
    new
    let pos = getpos('.')
    let lines = a:lines
    setlocal noreadonly modifiable
    silent % delete _
    silent put=lines
    silent 1 delete _
    setlocal readonly nomodifiable
    setlocal buftype=nofile nolist nocursorline
    call setpos('.', pos)
    nnoremap <silent><buffer>q       :<C-u>execute ((winnr('$') == 1) ? 'bdelete' : 'quit')<cr>
endfunction

function! s:open_file(path, lnum) abort
    if filereadable(a:path)
        let fullpath = substitute(fnamemodify(a:path, ':p'), '\', '/', 'g')
        let b = 0
        let saved_wnr = winnr()
        for wnr in range(1, winnr('$'))
            execute wnr . 'wincmd w'
            if expand('%' . ':p:gs!\!/!') is fullpath
                let b = 1
                break
            endif
        endfor
        if !b
            execute saved_wnr . 'wincmd w'
            new
        endif
        if 0 < a:lnum
            execute printf('edit +%d %s', a:lnum, fullpath)
        else
            execute printf('edit %s', fullpath)
        endif
        normal! zz
        return 1
    else
        return 0
    endif
endfunction

