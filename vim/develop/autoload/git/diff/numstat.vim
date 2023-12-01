
let s:FT_NUMSTAT = 'gitdiff-numstat'



function! git#diff#numstat#exec(q_bang, q_args) abort
    let context = {}
    let context['rootdir'] = git#internal#get_rootdir()
    let context['q_args'] = split(a:q_args, '\s\+')
    let context['cmd'] = ['diff', '--numstat'] + split(a:q_args, '\s\+')
    let context['files'] = {}
    let ok = v:true
    let error_lines = []
    for x in filter(git#internal#system(context['cmd']), { _,x -> !empty(x) })
        let m = split(x, '\t')
        if 3 == len(m)
            let context['files'][m[2]] = {
                \ 'added': str2nr(m[0]),
                \ 'removed': str2nr(m[1]),
                \ 'cmd': ['diff'] + split(a:q_args, '\s\+') + ['--', expand(context['rootdir'] .. '/' .. s:fix_path(m[2]))],
                \ }
        else
            let error_lines += [m[0]]
            let ok = v:false
        endif
    endfor
    if ok
        if empty(context['files'])
            call git#internal#echo('No modified files!')
        else
            call s:open_numstatwindow(context)
        endif
    else
        throw join(error_lines, "\n")
    endif
endfunction



function! s:open_numstatwindow(context) abort
    let lines = []
    for key in sort(keys(a:context['files']))
        let file = a:context['files'][key]
        let lines += [printf("%d\t%d\t%s", file['added'], file['removed'], key)]
    endfor
    let opts = {
        \ 'title': printf(' [%s] %s ', git#internal#branch_name(), join(a:context['cmd'])),
        \ }
    call utils#popupwin#apply_size(opts)
    call utils#popupwin#apply_border(opts)
    let winid = popup_menu(lines, opts)
    call win_execute(winid, 'setfiletype ' .. s:FT_NUMSTAT)
    call popup_setoptions(winid, {
        \ 'filter': function('s:popup_filter', [a:context]),
        \ 'callback': function('s:popup_callback', [a:context]),
        \ })
endfunction

function! s:popup_filter(context, winid, key) abort
    let lnum = line('.', a:winid)
    if char2nr('!') == char2nr(a:key)
        call popup_close(a:winid)
        call git#diff#numstat#exec('!', a:context['q_args'])
        return 1
    elseif char2nr('D') == char2nr(a:key)
        call git#diff#open_diffwindow(a:context['q_args'], s:get_current_path(a:winid, lnum))
        return 1
    else
        return utils#popupwin#common_filter(a:winid, a:key)
    endif
endfunction

function! s:get_current_path(winid, lnum) abort
    if -1 != a:lnum
        let rootdir = git#internal#get_rootdir()
        let line = trim(get(getbufline(winbufnr(a:winid), a:lnum), 0, ''))
        let path = trim(get(split(line, "\t") , 2, ''))
        let path = expand(rootdir .. '/' .. path)
        if filereadable(path)
            return path
        endif
    endif
    return ''
endfunction

function! s:popup_callback(context, winid, result) abort
    if -1 != a:result
        let path = s:get_current_path(a:winid, a:result) abort
        if has_key(a:context['files'], path)
            call git#diff#open_diffwindow(a:context['q_args'], path)
        endif
    endif
endfunction

function! s:fix_path(path) abort
    let s = a:path
    let m = matchlist(s, '^\(.*\){\([^}]*\) => \([^}]*\)}\(.*\)$')
    if !empty(m)
        let s = m[1] .. m[3] .. m[4]
        if filereadable(s)
            return s
        endif
    endif
    return s
endfunction

