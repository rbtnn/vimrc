
function! git#diff#open_diffwindow(args, path) abort
    if s:execute_gitdiff('diff', ['diff'] + a:args + ['--', a:path])
        let b:gitdiff = { 'args': a:args, 'path': a:path, }
        nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_enter()<cr>
        nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
        nnoremap <buffer><C-o> <nop>
        nnoremap <buffer><C-i> <nop>
    endif
endfunction

function! git#diff#open_numstatwindow(q_args) abort
    if s:execute_gitdiff('gitdiff-numstat', ['diff', '--numstat'] + split(a:q_args, '\s\+'))
        let b:gitdiff = { 'args': split(a:q_args, '\s\+'), 'rootdir': git#internal#get_rootdir(), }
        nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_enter()<cr>
        nnoremap <buffer>D     <Cmd>call <SID>bufferkeymap_enter()<cr>
        nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
        nnoremap <buffer><C-o> <nop>
        nnoremap <buffer><C-i> <nop>
    endif
endfunction



function! s:execute_gitdiff(ft, cmd) abort
    let exists = v:false
    for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
        if a:ft == getbufvar(w['bufnr'], '&filetype', '')
            execute printf('%dwincmd w', w['winnr'])
            let exists = v:true
            break
        endif
    endfor
    if !exists
        if !&modified && &modifiable && empty(&buftype) && !filereadable(bufname())
            " use the current buffer.
        else
            new
        endif
        execute 'setfiletype' a:ft
        setlocal nolist
    endif
    if &filetype == a:ft
        let &l:statusline = printf('[git] %s', join(a:cmd))
        let lines = filter(git#internal#system(a:cmd), { _,x -> !empty(x) })
        if empty(lines)
            call git#internal#echo('No modified')
            if (1 < winnr('$')) || (1 < tabpagenr('$'))
                close
            endif
        else
            call git#internal#setbuflines(lines)
            " The lines encodes after redrawing.
            if get(g:, 'git_enabled_qficonv', v:false)
                " Redraw windows because the encoding process is very slowly.
                redraw
                for i in range(0, len(lines) - 1)
                    let lines[i] = utils#iconv#exec(lines[i])
                endfor
                call git#internal#setbuflines(lines)
            endif
            return v:true
        endif
    endif
    return v:false
endfunction

function! s:bufferkeymap_enter() abort
    if &filetype == 'diff'
        call git#diff#diff#jumpdiffline()
    elseif &filetype == 'gitdiff-numstat'
        let path = trim(get(split(getline('.'), "\t") , 2, ''))
        let path = expand(b:gitdiff['rootdir'] .. '/' .. path)
        if filereadable(path)
            call git#diff#open_diffwindow(b:gitdiff['args'], path)
        endif
    endif
endfunction

function! s:bufferkeymap_bang() abort
    let wnr = winnr()
    let lnum = line('.')
    if &filetype == 'diff'
        call git#diff#open_diffwindow(b:gitdiff['args'], b:gitdiff['path'])
    elseif &filetype == 'gitdiff-numstat'
        call git#diff#open_numstatwindow(join(b:gitdiff['args']))
    endif
    execute printf(':%dwincmd w', wnr)
    call cursor(lnum, 0)
endfunction
