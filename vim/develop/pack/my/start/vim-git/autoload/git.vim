
function! git#init() abort
    let g:git_enabled_qficonv = get(g:, 'git_enabled_qficonv', v:false)
endfunction

function! git#status() abort
    if isdirectory(git#internal#get_rootdir())
        call git#init()
        if popupwin#check_able_to_open('git-status')
            call git#status#exec()
        endif
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#grep(q_args) abort
    if isdirectory(git#internal#get_rootdir())
        call git#init()
        call git#grep#exec(a:q_args)
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#blame() abort
    if isdirectory(git#internal#get_rootdir())
        call git#init()
        echo trim(get(git#internal#system(['blame', '-L', line('.') .. ',' .. line('.'), '--', expand('%')]), 0, ''))
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction

function! git#diff(q_bang) abort
    if isdirectory(git#internal#get_rootdir())
        call git#init()
        call git#diff#open_numstatwindow(a:q_bang)
    else
        call git#internal#echo('The directory is not under git control!')
    endif
endfunction
