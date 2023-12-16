
function! git#status() abort
    if isdirectory(git#internal#get_rootdir())
        call vimrc#init()
        call git#status#exec()
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#grep(q_args) abort
    if isdirectory(git#internal#get_rootdir())
        call vimrc#init()
        call git#grep#exec(a:q_args)
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#show(q_args) abort
    if isdirectory(git#internal#get_rootdir())
        call vimrc#init()
        call git#show#exec(a:q_args)
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#blame() abort
    if isdirectory(git#internal#get_rootdir())
        call vimrc#init()
        echo trim(get(git#internal#system(['blame', '-L', line('.') .. ',' .. line('.'), '--', expand('%')]), 0, ''))
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#lsfiles(q_bang) abort
    if isdirectory(git#internal#get_rootdir())
        call vimrc#init()
        call git#lsfiles#exec(a:q_bang)
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#diff(q_bang) abort
    if isdirectory(git#internal#get_rootdir())
        call vimrc#init()
        call git#diff#numstat#exec('!', a:q_bang)
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction
