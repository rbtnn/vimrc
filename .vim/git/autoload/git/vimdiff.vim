
function! git#vimdiff#exec(q_args) abort
    if !git#check_git()
        return
    endif

    let curr_ftype = &filetype
    let rev = empty(a:q_args) ? 'HEAD' : a:q_args
    let rootdir = git#get_rootdir()
    let relpath = s:get_current_relpath(rootdir)
    if empty(relpath)
        return git#echo_error('The current buffer is not managed by git repository')
    endif

    let diff_lines = git#git_system(rootdir, ['diff', '--numstat', rev])
    if 0 == len(filter(diff_lines, { i, x -> x =~# '^\d\+\t\d\+\t' .. relpath .. '$' }))
        return git#echo_error('There are no differences')
    endif

    let show_lines = git#git_system(rootdir, ['show', rev .. ':' .. relpath])
    if get(show_lines, 0, '') =~# '^fatal: '
        return git#echo_error(join(show_lines, "\n"))
    endif

    call s:close_diff_scratches()

    diffthis
    vnew
    let b:[(g:git_config.vimdiff.buffer_name)] = 1
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
        if getbufvar(w['bufnr'], g:git_config.vimdiff.buffer_name, 0)
            call win_execute(w['winid'], 'close')
        endif
    endfor
endfunction

function! s:get_current_relpath(rootdir) abort
    let fullpath = expand("%:p")
    if filereadable(fullpath)
        for path in git#git_system(a:rootdir, ['ls-files'])
            if git#fix_path(expand(a:rootdir .. '/' .. path)) == git#fix_path(fullpath)
                return path
            endif
        endfor
    endif
    return ''
endfunction
