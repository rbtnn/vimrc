
let g:loaded_develop_git = 1

if executable('git')
    command!       -nargs=0                                   GitStatus    :call git#status()
    command!       -nargs=*                                   GitGrep      :call git#grep(<q-args>)
    command!       -nargs=0                                   GitBlame     :call git#blame()
    command!       -nargs=* -complete=customlist,GitDiffComp  GitDiff      :call git#diff(<q-args>)

    function! GitDiffComp(ArgLead, CmdLine, CursorPos) abort
        let rootdir = git#internal#get_rootdir()
        let xs = ['--cached', 'HEAD']
        if isdirectory(rootdir)
            if isdirectory(rootdir .. '/.git/refs/heads')
                let xs += readdir(rootdir .. '/.git/refs/heads')
            endif
            if isdirectory(rootdir .. '/.git/refs/tags')
                let xs += readdir(rootdir .. '/.git/refs/tags')
            endif
        endif
        return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
    endfunction
endif
