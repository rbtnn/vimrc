
let s:FT_NUMSTAT = 'gitdiff-numstat'
let s:FT_DIFF = 'diff'



function! git#diff#numstat#exec(q_bang, q_args) abort
    try
        let context = git#diff#get_current_context()
        let i = index(context['history'], a:q_args)
        if -1 != i
            call remove(context['history'], i)
        endif
        let context['history'] = [a:q_args] + context['history']
        let use_cache = v:false
        if '!' != a:q_bang
            if !empty(get(context, 'files', [])) && (get(context, 'q_args', '') == a:q_args)
                call s:open_numstatwindow(context, v:true)
                let use_cache = v:true
            endif
        endif
        if !use_cache
            let context['last_cursor_position'] = 1
            let context['q_args'] = a:q_args
            let context['cmd'] = ['diff', '--numstat', a:q_args]
            let context['files'] = {}
            let ok = v:true
            let error_lines = []
            for x in filter(git#internal#system(context['cmd']), { _,x -> !empty(x) })
                let m = split(x, '\t')
                if 3 == len(m)
                    let context['files'][m[2]] = {
                        \ 'added': str2nr(m[0]),
                        \ 'removed': str2nr(m[1]),
                        \ 'cmd': ['diff', a:q_args, '--', expand(context['rootdir'] .. '/' .. s:fix_path(m[2]))],
                        \ 'cached': [],
                        \ }
                else
                    let error_lines += [m[0]]
                    let ok = v:false
                endif
            endfor
            if ok
                if empty(context['files'])
                    throw 'No modified files!'
                endif
                call s:open_numstatwindow(context, v:false)
            else
                throw join(error_lines, "\n")
            endif
        endif
    catch
        echohl Error
        echo printf('[gitdiff] %s', v:exception)
        "echo printf('%s', v:throwpoint)
        echohl None
    endtry
endfunction



function! s:bufferkeymap_enter() abort
    let rootdir = git#internal#get_rootdir()
    call git#diff#diff#jumpdiffline(rootdir)
endfunction

function! s:bufferkeymap_bang() abort
    let wnr = winnr()
    let lnum = line('.')
    call s:open_diffwindow(b:gitdiff_current_path, v:false)
    execute printf(':%dwincmd w', wnr)
    call cursor(lnum, 0)
endfunction

function! s:open_numstatwindow(context, use_cached) abort
    let lines = []
    for key in sort(keys(a:context['files']))
        let file = a:context['files'][key]
        let lines += [printf("%d\t%d\t%s", file['added'], file['removed'], key)]
    endfor
    let opts = {
        \ 'title': s:make_title(s:FT_NUMSTAT, a:use_cached, a:context['cmd']),
        \ }
    call utils#popupwin#apply_size(opts)
    call utils#popupwin#apply_border(opts, 'VimrcDevPopupBorder')
    let winid = popup_menu(lines, opts)
    call win_execute(winid, 'setfiletype ' .. s:FT_NUMSTAT)
    call popup_setoptions(winid, {
        \ 'filter': function('s:popup_filter'),
        \ 'callback': function('s:popup_callback'),
        \ })
    call utils#popupwin#set_cursorline(winid, a:context['last_cursor_position'])
endfunction

function! s:make_title(ft, use_cached, cmd) abort
    return printf(' [%s]%s %s ',
        \ a:ft,
        \ (a:use_cached ? ' (cached)' : ''),
        \ a:cmd)
endfunction

function! s:popup_filter(winid, key) abort
    let lnum = line('.', a:winid)
    if (10 == char2nr(a:key)) || (14 == char2nr(a:key))
        " Ctrl-n or Ctrl-j
        if lnum == line('$', a:winid)
            call utils#popupwin#set_cursorline(a:winid, 1)
        else
            call utils#popupwin#set_cursorline(a:winid, lnum + 1)
        endif
        return 1
    elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
        " Ctrl-p or Ctrl-k
        if lnum == 1
            call utils#popupwin#set_cursorline(a:winid, line('$', a:winid))
        else
            call utils#popupwin#set_cursorline(a:winid, lnum - 1)
        endif
        return 1
    elseif 0x21 == char2nr(a:key)
        call popup_close(a:winid)
        let context = git#diff#get_current_context()
        call git#diff#numstat('!', context['q_args'])
        return 1
    elseif 0x20 == char2nr(a:key)
        return popup_filter_menu(a:winid, "\<cr>")
    elseif 0x0d == char2nr(a:key)
        return popup_filter_menu(a:winid, "\<cr>")
    else
        if char2nr(a:key) < 0x20
            return popup_filter_menu(a:winid, "\<esc>")
        else
            return popup_filter_menu(a:winid, a:key)
        endif
    endif
endfunction

function! s:popup_callback(winid, result) abort
    if -1 != a:result
        let lnum = a:result
        let line = trim(get(getbufline(winbufnr(a:winid), lnum), 0, ''))
        let path = trim(get(split(line, "\t") , 2, ''))
        let context = git#diff#get_current_context()
        if has_key(context['files'], path)
            let context['last_cursor_position'] = lnum
            call s:open_diffwindow(path, v:true)
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

function! s:open_diffwindow(path, use_cached) abort
    let context = git#diff#get_current_context()
    let cmd = context['files'][a:path]['cmd']
    if a:use_cached && !empty(context['files'][a:path]['cached'])
        let lines = context['files'][a:path]['cached']
    else
        let lines = git#internal#system(cmd)
    endif

    let exists = v:false
    for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
        if s:FT_DIFF == getbufvar(w['bufnr'], '&filetype', '')
            execute printf('%dwincmd w', w['winnr'])
            let exists = v:true
            break
        endif
    endfor
    if !exists
        if !&modified && &modifiable && empty(&buftype) && !filereadable(bufname())
            " use the current buffer.
        else
            if &lines < &columns / 2
                botright vnew
            else
                botright new
            endif
        endif
    endif
    execute printf('setfiletype %s', s:FT_DIFF)
    setlocal nolist
    let &l:statusline = s:make_title(s:FT_DIFF, a:use_cached, cmd)
    call s:setbuflines(lines)

    nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_enter()<cr>
    nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
    nnoremap <buffer><C-o> <nop>
    nnoremap <buffer><C-i> <nop>

    " The lines encodes after redrawing.
    if get(g:, 'gitdiff_enabled_qficonv', v:false)
        " Redraw windows because the encoding process is very slowly.
        redraw
        for i in range(0, len(lines) - 1)
            let lines[i] = utils#iconv#exec(lines[i])
        endfor
        call s:setbuflines(lines)
    endif
    let context['files'][a:path]['cached'] = lines
    let b:gitdiff_current_path = a:path
endfunction

function! s:setbuflines(lines) abort
    setlocal modifiable noreadonly
    silent! call deletebufline(bufnr(), 1, '$')
    call setbufline(bufnr(), 1, a:lines)
    setlocal buftype=nofile nomodifiable readonly
endfunction
