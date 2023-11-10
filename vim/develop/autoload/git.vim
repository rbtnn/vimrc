
function! git#status() abort
    try
        if !isdirectory(git#internal#get_rootdir())
            throw 'The directory is not under git control!'
        endif
        call git#status#exec()
    catch
        echohl Error
        echo printf('[git] %s %s', v:exception, v:throwpoint)
        echohl None
    endtry
endfunction

function! git#blame() abort
    try
        if !isdirectory(git#internal#get_rootdir())
            throw 'The directory is not under git control!'
        endif
        echo trim(get(git#internal#system(['blame', '-L', line('.') .. ',' .. line('.'), '--', expand('%')]), 0, ''))
    catch
        echohl Error
        echo printf('[git] %s %s', v:exception, v:throwpoint)
        echohl None
    endtry
endfunction

function! git#lsfiles(q_bang) abort
    try
        if !isdirectory(git#internal#get_rootdir())
            throw 'The directory is not under git control!'
        endif
        call git#lsfiles#exec(a:q_bang)
    catch
        echohl Error
        echo printf('[git] %s %s', v:exception, v:throwpoint)
        echohl None
    endtry
endfunction
