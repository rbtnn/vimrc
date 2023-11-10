
function! git#diff#history() abort
    call git#diff#history#exec()
endfunction

function! git#diff#history_first() abort
    call git#diff#history#exec_first()
endfunction

function! git#diff#numstat(q_bang, q_args) abort
    call git#diff#numstat#exec(a:q_bang, a:q_args)
endfunction

function! git#diff#get_current_context() abort
    let rootdir = git#internal#get_rootdir()
    if !isdirectory(rootdir)
        throw 'The directory is not under git control!'
    endif
    let s:gitdiff = get(s:, 'gitdiff', {})
    let s:gitdiff[rootdir] = get(s:gitdiff, rootdir, {})
    let s:gitdiff[rootdir]['rootdir'] = rootdir
    let s:gitdiff[rootdir]['history'] = get(s:gitdiff[rootdir], 'history', [])
    return s:gitdiff[rootdir]
endfunction
