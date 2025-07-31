let s:bufvarname = 'gitdiff_scratch'

function! gitdiff#vimdiff#exec(q_args) abort
    let curr_ftype = &filetype
    let rev = empty(a:q_args) ? 'HEAD' : a:q_args

    let rootdir = gitdiff#get_rootdir()
    if !gitdiff#check_git(rootdir)
        return
    endif

    let relpath = s:get_current_relpath(rootdir)
    if empty(relpath)
        return gitdiff#echo_error('The current buffer is not managed by git repository')
    endif

    let diff_lines = gitdiff#git_system(rootdir, ['diff', '--numstat', rev])
    if 0 == len(filter(diff_lines, { i, x -> x =~# '^\d\+\t\d\+\t' .. relpath .. '$' }))
        return gitdiff#echo_error('There are no differences')
    endif

    let show_lines = gitdiff#git_system(rootdir, ['show', rev .. ':' .. relpath])
    if get(show_lines, 0, '') =~# '^fatal: '
        return gitdiff#echo_error(join(show_lines, "\n"))
    endif

    call s:close_diff_scratches()

    diffthis
    vnew
    let b:[(s:bufvarname)] = 1
    setlocal modifiable noreadonly
    call setbufline(bufnr(), 1, show_lines)
    setlocal buftype=nofile nomodifiable readonly
    let &l:filetype = curr_ftype
    diffthis
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

function! s:get_current_relpath(rootdir) abort
    let fullpath = expand("%:p")
    if filereadable(fullpath)
        for path in gitdiff#git_system(a:rootdir, ['ls-files'])
            if gitdiff#fix_path(expand(a:rootdir .. '/' .. path)) == gitdiff#fix_path(fullpath)
                return path
            endif
        endfor
    endif
    return ''
endfunction
