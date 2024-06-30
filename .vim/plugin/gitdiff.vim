let s:bufvarname = 'gitdiff_scratch'

command! -nargs=* GitDiff :call s:git_diff(<q-args>)

function! s:git_diff(q_args) abort
    let curr_ftype = &filetype
    let rootdir = s:git_get_rootdir()
    let relpath = s:get_current_relpath(rootdir)
    let lines = s:git_system(rootdir, ['show', (empty(a:q_args) ? 'HEAD' : a:q_args) .. ':' .. relpath])

    if !executable('git')
        return s:error('git command is not executable')
    endif
    if !isdirectory(rootdir)
        return s:error('The directory is not under git control')
    endif
    if empty(relpath)
        return s:error('The current buffer is not managed by git repository')
    endif
    if get(lines, 0, '') =~# '^fatal: '
        return s:error(join(lines, "\n"))
    endif

    call s:close_diff_scratches()

    diffthis
    vnew
    let b:[(s:bufvarname)] = 1
    setlocal modifiable noreadonly
    call setbufline(bufnr(), 1, lines)
    setlocal buftype=nofile nomodifiable readonly
    let &l:filetype = curr_ftype
    diffthis
endfunction

function! s:get_current_relpath(rootdir) abort
    let fullpath = expand("%:p")
    if filereadable(fullpath)
        for path in s:git_system(a:rootdir, ['ls-files'])
            if s:fix_path(expand(a:rootdir .. '/' .. path)) == s:fix_path(fullpath)
                return path
            endif
        endfor
    endif
    return ''
endfunction

function! s:fix_path(path) abort
    return substitute(a:path, '[\/]', '/', 'g')
endfunction

function! s:error(msg) abort
    echohl Error
    echo printf('[gitdiff] %s!', a:msg)
    echohl None
endfunction

function! s:close_diff_scratches() abort
    for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
        if &diff
            call win_execute(w['winid'], 'diffoff')
        endif
        if getbufvar(w['bufnr'], s:bufvarname, 0)
            call win_execute(w['winid'], 'close')
        endif
    endfor
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

function s:git_system(cwd, subcmd) abort
    let cmd_prefix = ['git', '--no-pager']
    if has('nvim')
        let params = [{ 'lines': [], }]
        let job = jobstart(cmd_prefix + a:subcmd, {
            \ 'cwd': a:cwd,
            \ 'on_stdout': function('s:nvim_event', params),
            \ })
        call jobwait([job])
        return params[0]['lines']
    else
        let lines = []
        let path = tempname()
        try
            let job = job_start(cmd_prefix + a:subcmd, {
                \ 'cwd': a:cwd,
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
    endif
endfunction

function s:nvim_event(...) abort
    let a:000[0]['lines'] += a:000[2]
    sleep 10m
endfunction
