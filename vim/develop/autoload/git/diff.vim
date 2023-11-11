
function! git#diff#open_diffwindow(args, path) abort
    let exists = v:false
    for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
        if 'diff' == getbufvar(w['bufnr'], '&filetype', '')
            execute printf('%dwincmd w', w['winnr'])
            let exists = v:true
            break
        endif
    endfor
    let lines = git#internal#system(['diff'] + a:args + ['--', a:path])
    if empty(lines)
        call git#internal#echo('No modified')
        if exists
            close
        endif
    else
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
        setfiletype diff
        setlocal nolist
        let &l:statusline = printf('[git] diff %s -- %s', join(a:args), a:path)
        call s:setbuflines(lines)

        nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_enter()<cr>
        nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
        nnoremap <buffer><C-o> <nop>
        nnoremap <buffer><C-i> <nop>

        " The lines encodes after redrawing.
        if get(g:, 'git_enabled_qficonv', v:false)
            " Redraw windows because the encoding process is very slowly.
            redraw
            for i in range(0, len(lines) - 1)
                let lines[i] = utils#iconv#exec(lines[i])
            endfor
            call s:setbuflines(lines)
        endif
        let b:gitdiff_current_args = a:args
        let b:gitdiff_current_path = a:path
    endif
endfunction



function! s:bufferkeymap_enter() abort
    call git#diff#diff#jumpdiffline()
endfunction

function! s:bufferkeymap_bang() abort
    let wnr = winnr()
    let lnum = line('.')
    call git#diff#open_diffwindow(b:gitdiff_current_args, b:gitdiff_current_path)
    if &filetype == 'diff'
        execute printf(':%dwincmd w', wnr)
        call cursor(lnum, 0)
    endif
endfunction

function! s:setbuflines(lines) abort
    setlocal modifiable noreadonly
    silent! call deletebufline(bufnr(), 1, '$')
    call setbufline(bufnr(), 1, a:lines)
    setlocal buftype=nofile nomodifiable readonly
endfunction
