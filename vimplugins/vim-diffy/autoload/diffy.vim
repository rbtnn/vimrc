
let s:jobs = []
let s:cnt = 0

function! diffy#exec(target, q_bang, q_args) abort
    if &filetype != 'gstat'
        let args = s:trim(a:q_args)
        "if !empty(a:q_bang)
        "    let rev = args
        "    if !empty(rev)
        "        let args = printf('%s^..%s', rev, rev)
        "    else
        "        call s:error('Invalid revision!')
        "        return
        "    endif
        "endif
        let cmd = ['git', 'diff', '--stat-width=800', '--stat']
        if !empty(args)
            let cmd += split(args, '\s\+')
        endif
        call s:job_new_on_toplevel(cmd, a:target, function('s:close_handler_stat', [(cmd)]))
    endif
endfunction

"function! git#cmd_diffhash(target, hash) abort
"    let cmd = ['git', 'diff', (a:hash . '~1'), (a:hash)]
"    call s:job_new_on_toplevel(cmd, a:target, function('s:close_handler_diff', [(cmd)]))
"endfunction

function! s:close_handler_stat(cmd, toplevel, output)
    call s:echo(join(a:cmd, ' '))
    let lines = []
    let max = 0
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
    for line in a:output
        let xs = split(line, '|')
        if 2 == len(xs)
            if xs[1] !~ 'Bin'
                let lines += [printf('%s | %s',
                        \ s:padding_right_space(s:trim(xs[0]), max), xs[1])]
            endif
        endif
    endfor
    if 1 == len(lines)
        call diffy#git_diff(a:cmd, diffy#get_path(a:toplevel, lines[0]))
    elseif 0 < len(lines)
        call s:new_window(lines)
        setlocal filetype=diffy
        let &l:statusline = join(a:cmd)
        execute printf("nnoremap <silent><buffer><nowait>d       :<C-u>call diffy#git_diff(%s, diffy#get_path(%s, getline('.')))<cr>", string(a:cmd), string(a:toplevel))
        execute printf("nnoremap <silent><buffer><nowait><cr>    :<C-u>call diffy#git_open(%s, getline('.'))<cr>", string(a:toplevel))
    else
        call s:error('No modified file!')
    endif
endfunction

function! s:close_handler_diff(cmd, toplevel, output)
    call s:echo(join(a:cmd, ' '))
    let lines = a:output
    if !empty(lines)
        call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
        call s:new_window(lines)
        wincmd H
        redraw!
        setlocal filetype=diff
        let &l:statusline = join(a:cmd)
        execute printf('nnoremap <silent><buffer><nowait><cr>    :<C-u>call diffy#git_diff_jump(%s)<cr>', string(a:toplevel))
    else
        call s:error('No modified!')
    endif
endfunction

function! diffy#git_open(toplevel, line) abort
    let path = diffy#get_path(a:toplevel, a:line)
    if filereadable(path)
        call s:open_file(path, -1)
    endif
endfunction

function! diffy#git_diff(cmd, fullpath) abort
    if filereadable(a:fullpath)
        let args = ''
        let idx = index(a:cmd, '--stat')
        if 0 <= idx
            let args = join(a:cmd[(idx + 1):])
        endif
        let target = fnamemodify(a:fullpath, ':h')
        let diffcmd = s:diffcmd(a:fullpath, args)
        call s:job_new_on_toplevel(diffcmd, target,
                \ function('s:close_handler_diff', [diffcmd])
                \ )
    else
        call s:error('Can not get the file path in this buffer!')
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
    let expanded_cwd = expand(a:cwd)
    let job = job_start(a:cmd, {
            \ 'close_cb' : function('s:handler_close_cb', [(a:callback)]),
            \ 'cwd' : expand(a:cwd),
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
"
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
    let toplevel = substitute(get(a:output, 0, ''), "\n", '', 'g')
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

