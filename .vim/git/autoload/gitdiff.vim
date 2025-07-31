
function! gitdiff#get_rootdir(path = '.') abort
    let xs = split(fnamemodify(a:path, ':p'), '[\/]')
    let prefix = (has('mac') || has('linux')) ? '/' : ''
    while !empty(xs)
        let path = prefix .. join(xs + ['.git'], '/')
        if isdirectory(path) || filereadable(path)
            return prefix .. join(xs, '/')
        endif
        call remove(xs, -1)
    endwhile
    return ''
endfunction

function! gitdiff#fix_path(path) abort
    return substitute(a:path, '[\/]', '/', 'g')
endfunction

function! gitdiff#echo_error(msg) abort
    echohl Error
    echo printf('[gitdiff] %s!', a:msg)
    echohl None
endfunction

function! gitdiff#echo_message(msg) abort
    echohl Title
    echo printf('[gitdiff] %s!', a:msg)
    echohl None
endfunction

function gitdiff#git_system(cwd, subcmd) abort
    let cmd_prefix = ['git', '--no-pager']
    if has('nvim')
        let params = [{ 'lines': [], }]
        let job = jobstart(cmd_prefix + a:subcmd, {
            \ 'cwd': a:cwd,
            \ 'on_stdout': function('s:nvim_event', params),
            \ })
        call jobwait([job])
        return params[0]['lines']
    else
        let lines = []
        let path = tempname()
        try
            let job = job_start(cmd_prefix + a:subcmd, {
                \ 'cwd': a:cwd,
                \ 'out_io': 'file',
                \ 'out_name': path,
                \ 'err_io': 'out',
                \ })
            while 'run' == job_status(job)
            endwhile
            if filereadable(path)
                let lines = readfile(path)
            endif
        finally
            if filereadable(path)
                call delete(path)
            endif
        endtry
        return lines
    endif
endfunction

function! gitdiff#check_git(rootdir) abort
    if !executable('git')
        call gitdiff#echo_error('Git command is not executable')
        return v:false
    endif

    if !isdirectory(a:rootdir)
        call gitdiff#echo_error('The current directory is not under git control')
        return v:false
    endif

    return v:true
endfunction



function s:nvim_event(...) abort
    let a:000[0]['lines'] += a:000[2]
    sleep 10m
endfunction
