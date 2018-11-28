
function! git#cmd_stat(target, q_bang, q_args) abort
    if &filetype != 'gstat'
        let args = helper#trim(a:q_args)
        if !empty(a:q_bang)
            let rev = args
            if !empty(rev)
                let args = printf('%s^..%s', rev, rev)
            else
                call helper#error('Invalid revision!')
                return
            endif
        endif
        let cmd = ['git', 'diff', '--stat-width=800', '--stat']
        if !empty(args)
            let cmd += split(args, '\s\+')
        endif
        call job#new_on_toplevel(cmd, a:target, function('s:close_handler_stat', [(cmd)]))
    endif
endfunction

function! git#cmd_diffthis(target, q_bang, q_args) abort
    let args = helper#trim(a:q_args)
    let fullpath = expand('%:p', 1)
    if filereadable(fullpath)
        let target = fnamemodify(fullpath, ':h')
        let diffcmd = s:diffcmd(fullpath, args)
        call job#new_on_toplevel(diffcmd, target,
                \ function('s:close_handler_diff', [diffcmd, (fullpath), []])
                \ )
    else
        call helper#error('Can not get the file path in this buffer!')
    endif
endfunction

function! git#cmd_grep(target, q_args) abort
    let args = helper#trim(a:q_args)
    let cmd = ['git', 'grep']
    let cmd += ['--line-number']
    " Don’t match the pattern in binary files.
    let cmd += ['-I']
    let cmd += ['--fixed-strings']
    " let cmd += ['--word-regexp']
    let cmd += ['--ignore-case']
    let cmd += ['--no-color']
    if !empty(args)
        let cmd += [(args)]
    endif
    let job = job#new_on_toplevel(cmd, a:target,
            \ function('s:close_handler_grep')
            \ )
endfunction



function! s:close_handler_stat(cmd, toplevel, output)
    call helper#echo(join(a:cmd, ' '))
    let lines = []
    let max = 0
    for line in a:output
        let xs = split(line, '|')
        if 2 == len(xs)
            if xs[1] !~ 'Bin'
                let w = strdisplaywidth(helper#trim(xs[0]))
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
                        \ helper#padding_right_space(helper#trim(xs[0]), max), xs[1])]
            endif
        endif
    endfor
    if 1 == len(lines)
        call git#diff(a:cmd, git#get_path(a:toplevel, lines[0]))
    elseif 0 < len(lines)
        call helper#new_window(lines)
        setlocal filetype=gstat
        let &l:statusline = join(a:cmd)
        execute printf("nnoremap <silent><buffer><nowait>d       :<C-u>call git#diff(%s, git#get_path(%s, getline('.')))<cr>", string(a:cmd), string(a:toplevel))
        execute printf("nnoremap <silent><buffer><nowait><cr>    :<C-u>call git#open(%s, getline('.'))<cr>", string(a:toplevel))
    else
        call helper#error('No modified file!')
    endif
endfunction

function! s:close_handler_diff(cmd, fullpath, pos, toplevel, output)
    call helper#echo(join(a:cmd, ' '))
    let lines = a:output
    if !empty(lines)
        call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
        call helper#new_window(lines)
        wincmd H
        if !empty(a:pos)
            call setpos('.', a:pos)
        endif
        redraw!
        setlocal filetype=diff
        let &l:statusline = join(a:cmd)
        execute printf('nnoremap <silent><buffer><nowait><cr>    :<C-u>call git#diff_jump(%s)<cr>', string(a:toplevel))
        execute printf("nnoremap <silent><buffer><nowait>r       :<C-u>call git#rediff(%s, %s)<cr>", string(a:cmd), string(a:fullpath))
    else
        call helper#error('No modified!')
    endif
endfunction

function! s:close_handler_grep(toplevel, output)
    let xs = []
    for line in a:output
        let m = matchlist(line, '^\([^:]*\):\s*\(\d\+\):\(.*\)$')
        if !empty(m)
            let xs += [{
                    \ 'filename' : fnamemodify(a:toplevel . '/'. m[1], ':p'),
                    \ 'lnum' : m[2],
                    \ 'text' : sillyiconv#iconv_one_nothrow(m[3]),
                    \ }]
        endif
    endfor
    call setqflist(xs)
    if !empty(xs)
        copen
        wincmd J
    endif
    call helper#echo('finished')
endfunction



function! git#open(toplevel, line) abort
    let path = git#get_path(a:toplevel, a:line)
    if filereadable(path)
        call helper#open_file(path, -1)
    endif
endfunction

function! git#rediff(cmd, fullpath) abort
    let pos = getpos('.')
    close
    if filereadable(a:fullpath)
        let target = fnamemodify(a:fullpath, ':h')
        call job#new_on_toplevel(a:cmd, target,
                \ function('s:close_handler_diff', [(a:cmd), (a:fullpath), pos])
                \ )
    else
        call helper#error('Can not get the file path in this buffer!')
    endif
endfunction

function! git#diff(cmd, fullpath) abort
    if filereadable(a:fullpath)
        let args = ''
        let idx = index(a:cmd, '--stat')
        if 0 <= idx
            let args = join(a:cmd[(idx + 1):])
        endif
        let target = fnamemodify(a:fullpath, ':h')
        let diffcmd = s:diffcmd(a:fullpath, args)
        call job#new_on_toplevel(diffcmd, target,
                \ function('s:close_handler_diff', [diffcmd, (a:fullpath), []])
                \ )
    else
        call helper#error('Can not get the file path in this buffer!')
    endif
endfunction

function! git#diff_jump(toplevel) abort
    if &l:filetype == 'diff'
        let xs = s:get_path_and_lnum(a:toplevel)
        if !empty(xs)
            let [fullpath, lnum] = xs
            call helper#open_file(fullpath, lnum)
        else
            call helper#error('Can not jump this!')
        endif
    else
        call helper#error('filetype is not diff!')
    endif
endfunction

function! git#get_path(toplevel, line) abort
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

