
let g:loaded_develop_git = 1

if executable('git')
    command!                                                  GitStatus               :call git#status()
    command!       -nargs=*                                   GitGrep                 :call s:gitgrep(<q-args>)
    command!       -nargs=0                                   GitBlameCurrentLine     :call git#blame()
    command!       -nargs=0                                   GitDiffHistory          :call git#diff#history()
    command!       -nargs=0                                   GitDiffHistoryFirst     :call git#diff#history_first()
    command! -bang -nargs=*                                   GitLsFiles              :call git#lsfiles(<q-bang>)
    command! -bang -nargs=* -complete=customlist,GitDiffComp  GitDiffNumStat          :call git#diff#numstat(<q-bang>, <q-args>)

    function! GitDiffComp(ArgLead, CmdLine, CursorPos) abort
        let rootdir = gitdiff#rootdir#get()
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

    function! s:gitgrep(q_args) abort
        let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n', '--column'] + split(a:q_args, '\s\+')
        call qfjob#start(cmd, {
            \ 'title': 'git grep',
            \ 'line_parser': function('s:line_parser'),
            \ })
    endfunction

    function s:line_parser(line) abort
        let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(path, ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': utils#iconv#exec(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': utils#iconv#exec(m[4]),
                \ }
        else
            return { 'text': utils#iconv#exec(a:line), }
        endif
    endfunction
endif
