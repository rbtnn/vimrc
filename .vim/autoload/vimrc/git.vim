
let s:NO_MATCHES = 'no matches'

function! vimrc#git#diff(q_args) abort
    if s:change_to_the_toplevel()
        let st = reltime()
        let args = split(a:q_args, '\s\+')
        let dict = {}
        let cmd = ['git', 'diff', '--numstat'] + args
        for line in s:system(cmd)
            let m = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$')
            if !empty(m)
                let key = m[3]
                if !has_key(dict, key)
                    let dict[key] = { 'additions' : m[1], 'deletions' : m[2], 'path' : key, }
                endif
            endif
        endfor
        let lines = keys(dict)
        if !empty(lines)
            call map(lines, { i,key ->
                \ printf('%5s %5s %s', '+' .. dict[key]['additions'], '-' .. dict[key]['deletions'], key)
                \ })
            call sort(lines, { x,y -> x[12:] == y[12:] ? 0 : x[12:] > y[12:] ? 1 : -1 })
            let winid = s:open(lines, reltimestr(reltime(st)), join(cmd), function('s:cb_diff'))
            call setwinvar(winid, 'args', args)
            call setwinvar(winid, 'info', dict)
            call win_execute(winid, 'setlocal wrap')
            call win_execute(winid, 'call clearmatches()')
            call win_execute(winid, 'call matchadd("DiffAdd", "+\\d\\+")')
            call win_execute(winid, 'call matchadd("DiffDelete", "-\\d\\+")')
        else
            call s:error('No modified files')
        endif
    else
        call s:error('Not a git repository')
    endif
endfunction

function! vimrc#git#lsfiles() abort
    if s:change_to_the_toplevel()
        let st = reltime()
        let cmd = ['git', 'ls-files']
        let cachepath = '.lsfiles.caches'
        if filereadable(cachepath)
            let files = readfile(cachepath)
            for path in files
                if !filereadable(path)
                    call delete(cachepath)
                    break
                endif
            endfor
        endif
        if !filereadable(cachepath)
            let files = s:system(cmd)
            call writefile(files, cachepath)
        endif
        if empty(files)
            call s:error('no such file')
        else
            let winid = s:open(files, reltimestr(reltime(st)), join(cmd), function('s:cb_lsfiles'))
            call win_execute(winid, 'setlocal wrap')
        endif
    else
        call s:error('not a git repository')
    endif
endfunction



function! s:cb_diff(winid, key) abort
    if -1 != a:key
        let lnum = a:key
        let path = getbufline(winbufnr(a:winid), lnum, lnum)[0]
        if s:NO_MATCHES != path
            let path = path[12:]
            let args = getwinvar(a:winid, 'args')
            let cmd = ['git', 'diff'] + args + ['--', path]
            call s:new_window(s:system(cmd), cmd)
            let fullpath = s:expand2fullpath(path)
            execute printf('nnoremap <buffer><silent><nowait><space>    :<C-w>call <SID>jump_diff(%s)<cr>', string(fullpath))
            execute printf('nnoremap <buffer><silent><nowait><cr>       :<C-w>call <SID>jump_diff(%s)<cr>', string(fullpath))
        endif
    endif
endfunction

function! s:jump_diff(fullpath) abort
    let ok = v:false
    let lnum = search('^@@', 'bnW')
    if 0 < lnum
        let n1 = 0
        let n2 = 0
        for n in range(lnum + 1, line('.'))
            let line = getline(n)
            if line =~# '^-'
                let n2 += 1
            elseif line =~# '^+'
                let n1 += 1
            endif
        endfor
        let n3 = line('.') - lnum - n1 - n2 - 1
        let m = []
        let m2 = matchlist(getline(lnum), '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@\(.*\)$')
        let m3 = matchlist(getline(lnum), '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
        if !empty(m2)
            let m = m2
        elseif !empty(m3)
            let m = m3
        endif
        if !empty(m)
            for i in [1, 3, 5]
                if '+' == m[i]
                    call s:open_file(a:fullpath, m[i + 1] + n1 + n3)
                    let ok = v:true
                    break
                endif
            endfor
        endif
    endif
    if !ok
        call s:error('Can not jump this!')
    endif
endfunction

function! s:open_file(path, lnum) abort
    if filereadable(a:path)
        let fullpath = s:expand2fullpath(a:path)
        let b = 0
        for x in filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
            if s:expand2fullpath(bufname(x['bufnr'])) is fullpath
                execute x['winnr'] .. 'wincmd w'
                let b = 1
                break
            endif
        endfor
        if b
            execute printf('%d', a:lnum)
        else
            if 0 < a:lnum
                execute printf('new +%d %s', a:lnum, fnameescape(fullpath))
            else
                execute printf('new %s', fnameescape(fullpath))
            endif
        endif
        normal! zz
        return 1
    else
        return 0
    endif
endfunction

function! s:new_window(lines, cmd) abort
    let exists = v:false
    for info in getwininfo()
        if (info['tabnr'] == tabpagenr()) && (getbufvar(info['bufnr'], '&filetype') == 'diff')
            execute printf('%dwincmd w', info['winnr'])
            setlocal noreadonly modifiable
            let exists = v:true
            break
        endif
    endfor
    if !exists
        new
    endif
    silent % delete _
    silent put=a:lines
    silent 1 delete _
    setlocal readonly nomodifiable buftype=nofile nocursorline
    let &l:filetype = 'diff'
    let &l:statusline = join(a:cmd)
endfunction

function! s:system(cmd) abort
    let lines = []
    let path = tempname()
    try
        let job = job_start(a:cmd, {
            \ 'out_io' : 'file',
            \ 'out_name' : path,
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
    if get(g:, 'vimrc_use_sillyiconv', v:false)
        return vimrc#sillyiconv#iconv(lines)
    else
        return lines
    endif
endfunction

function! s:error(text) abort
    echohl Error
    echo a:text
    echohl None
endfunction

function! s:expand2fullpath(path) abort
    return resolve(fnamemodify(a:path, ':p:gs?\\?/?'))
endfunction

function! s:cb_lsfiles(winid, key) abort
    if 0 < a:key
        let lnum = a:key
        let path = getbufline(winbufnr(a:winid), lnum, lnum)[0]
        if s:NO_MATCHES != path
            let fullpath = s:expand2fullpath(path)
            let matches = filter(getbufinfo(), {i,x -> s:expand2fullpath(x.name) == fullpath })
            if !empty(matches)
                execute printf('%s %d', 'buffer', matches[0]['bufnr'])
            else
                execute printf('%s %s', 'edit', fnameescape(fullpath))
            endif
        endif
    endif
endfunction

function! s:open(lines, time, cmd, cb) abort
    let winid = popup_menu(a:lines, {})
    let s:search_winid = -1

    let lines_width = 0
    for line in a:lines
        if lines_width < strwidth(line)
            let lines_width = strwidth(line)
        endif
    endfor

    call setwinvar(winid, 'options', #{
        \ curr_filter_text: '',
        \ prev_filter_text: '',
        \ search_mode: v:false,
        \ cmd: a:cmd,
        \ time: a:time,
        \ user_callback: a:cb,
        \ orig_lines: a:lines,
        \ lines_width: lines_width,
        \ })

    call s:update_lines(winid, v:true, v:true)
    call s:set_options(winid)

    return winid
endfunction

function! s:set_options(winid) abort
    let opts = getwinvar(a:winid, 'options')
    if a:winid != -1
        let orig_len = len(opts.orig_lines)
        let filter_lines = getbufline(winbufnr(a:winid), 1, '$')
        let filter_len = (get(filter_lines, 0, '') == s:NO_MATCHES) ? 0 : len(filter_lines)
        let base_opts = {}
        try
            let base_opts = pterm#build_options()
        catch
        endtry
        call popup_setoptions(a:winid, extend(base_opts, #{
            \ title: printf('[%s] %s (%d/%d)', opts.time, opts.cmd, filter_len, orig_len),
            \ zindex: 100,
            \ padding: [(opts.search_mode ? 1 : 0), 1, 0, 1],
            \ filter: function('s:filter'),
            \ callback: function('s:callback'),
            \ }, 'force'))
    endif
    if s:search_winid != -1
        call popup_settext(s:search_winid, '/' .. opts.curr_filter_text)
        let parent_pos = popup_getpos(a:winid)
        call popup_setoptions(s:search_winid, #{
            \ pos: 'topleft',
            \ zindex: 200,
            \ line: parent_pos['line'] + 1,
            \ col: parent_pos['col'] + 2,
            \ minwidth: parent_pos['core_width'],
            \ highlight: 'Terminal',
            \ padding: [0, 0, 0, 0],
            \ border: [0, 0, 0, 0],
            \ })
    endif
endfunction

function! s:callback(winid, key) abort
    let opts = getwinvar(a:winid, 'options')
    call popup_close(s:search_winid)
    call call(opts.user_callback, [(a:winid), (a:key)])
endfunction

function! s:filter(winid, key) abort
    "echo printf('%x,"%s"', char2nr(a:key), a:key)
    let opts = getwinvar(a:winid, 'options')
    if opts.search_mode
        if ("\<esc>" == a:key) || ("\<cr>" == a:key)
            let opts.search_mode = v:false
            call popup_close(s:search_winid)
            let s:search_winid = -1
            call s:set_options(a:winid)
            return 1
        else
            let chars = split(opts.curr_filter_text, '\zs')
            if 21 == char2nr(a:key)
                let opts.curr_filter_text = ''
            elseif (8 == char2nr(a:key)) || ("\x80kb" == a:key)
                if 0 < len(chars)
                    if 1 == len(chars)
                        let chars = []
                    else
                        let chars = chars[:len(chars) - 2]
                    endif
                else
                    let chars = []
                    let opts.search_mode = v:false
                    call popup_close(s:search_winid)
                    let s:search_winid = -1
                endif
                let opts.curr_filter_text = join(chars, '')
            elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
                let opts.curr_filter_text = opts.curr_filter_text .. a:key
            endif
            let opts.curr_filter_text = trim(opts.curr_filter_text)
            call s:update_lines(a:winid, v:false, v:false)
            call s:set_options(a:winid)
            return 1
        endif
    else
        if '/' ==# a:key
            let opts.search_mode = v:true
            call s:update_lines(a:winid, v:false, v:false)
            let parent_pos = popup_getpos(a:winid)
            let s:search_winid = popup_create('', {})
            call s:set_options(a:winid)
            return 1
        elseif 'g' ==# a:key
            call s:set_curpos(a:winid, 1)
            return 1
        elseif 'G' ==# a:key
            call s:set_curpos(a:winid, line('$', a:winid))
            return 1
        else
            return popup_filter_menu(a:winid, a:key)
        endif
    endif
endfunction

function! s:update_lines(winid, force, set_currfile) abort
    let opts = getwinvar(a:winid, 'options')
    if (opts.prev_filter_text != opts.curr_filter_text) || a:force
        let opts.prev_filter_text = opts.curr_filter_text
        let lines = opts.orig_lines
        if !empty(opts.curr_filter_text)
            let lines = matchfuzzy(deepcopy(lines), opts.curr_filter_text)
        endif
        call popup_settext(a:winid, !empty(lines) ? lines : s:NO_MATCHES)
        call s:set_options(a:winid)
        let init_lnum = 1
        if a:set_currfile && !empty(bufname())
            let target = substitute(s:expand2fullpath(bufname()), s:get_toplevel(), '', '')
            for i in range(0, len(lines) - 1)
                if lines[i] =~# target .. '$'
                    let init_lnum = i + 1
                endif
            endfor
        endif
        call s:set_curpos(a:winid, init_lnum)
        redraw
    endif
endfunction

function! s:set_curpos(winid, lnum) abort
    call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
endfunction

function! s:change_to_the_toplevel() abort
    let toplevel = s:get_toplevel()
    if s:expand2fullpath(getcwd()) != toplevel
        execute printf('lcd %s', escape(toplevel, ' '))
        echo printf('Changed the current directory to "%s".', toplevel)
    endif
    return isdirectory(toplevel)
endfunction

function! s:get_toplevel() abort
    for dir in [expand('%:p:h'), getcwd()]
        for do_resolve in [v:false, v:true]
            let xs = split((do_resolve ? resolve(dir) : dir), '[\/]')
            let prefix = (has('mac') || has('linux')) ? '/' : ''
            while !empty(xs)
                if isdirectory(prefix .. join(xs + ['.git'], '/'))
                    return s:expand2fullpath(prefix .. join(xs, '/'))
                endif
                call remove(xs, -1)
            endwhile
        endfor
    endfor
    return ''
endfunction

