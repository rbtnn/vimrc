
function! gitdiff#cdrootdir#exec() abort
    let rootdir = gitdiff#get_rootdir()
    if !empty(rootdir)
        if !empty(chdir(rootdir))
            call gitdiff#echo_message('Changed to git rootdir:')
            verbose pwd
            return
        endif
    endif
    call gitdiff#echo_error('Could not find a git rootdir!')
endfunction
