
function! gitdiff#history() abort
    call gitdiff#history#exec()
endfunction

function! gitdiff#history_first() abort
    call gitdiff#history#exec_first()
endfunction

function! gitdiff#numstat(q_bang, q_args) abort
    call gitdiff#numstat#exec(a:q_bang, a:q_args)
endfunction

function! gitdiff#get_current_context() abort
    let rootdir = gitdiff#rootdir#get()
    if !isdirectory(rootdir)
        throw 'The directory is not under git control!'
    endif
    let s:gitdiff = get(s:, 'gitdiff', {})
    let s:gitdiff[rootdir] = get(s:gitdiff, rootdir, {})
    let s:gitdiff[rootdir]['rootdir'] = rootdir
    let s:gitdiff[rootdir]['history'] = get(s:gitdiff[rootdir], 'history', [])
    return s:gitdiff[rootdir]
endfunction
