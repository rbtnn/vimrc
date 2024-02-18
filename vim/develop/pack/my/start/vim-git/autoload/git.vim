
function! git#init() abort
    let g:git_lsfiles_ignore_exts = get(g:, 'git_lsfiles_ignore_exts', [
        \ 'exe', 'o', 'obj', 'xls', 'doc', 'xlsx', 'docx', 'dll', 'png', 'jpg', 'ico', 'pdf', 'mp3', 'zip',
        \ 'ttf', 'gif', 'otf', 'wav', 'm4a', 'ai', 'tgz'
        \ ])
    let g:git_lsfiles_ignore_patterns = get(g:, 'git_lsfiles_ignore_patterns', [])
    let g:git_lsfiles_maximum = get(g:, 'git_lsfiles_maximum', 100)
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

function! git#show(q_args) abort
    if isdirectory(git#internal#get_rootdir())
        call git#init()
        call git#show#exec(a:q_args)
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

function! git#lsfiles(q_bang) abort
    if isdirectory(git#internal#get_rootdir())
        call git#init()
        if popupwin#check_able_to_open('git-lsfiles')
            call git#lsfiles#exec(a:q_bang)
        endif
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
