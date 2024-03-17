scriptencoding utf-8
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')
let $VIMRC_PKGSYNC_DIR = expand('$VIMRC_VIM/github/pack/rbtnn/start/vim-pkgsync')

if &compatible
    set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

language messages C
set winaltkeys=yes
set guioptions=mM
set mouse=a
set belloff=all
set clipboard=unnamed

set autoread
set cmdheight=1
set cmdwinheight=5
set complete-=t
set completeslash=slash
set diffopt+=iwhiteall
set expandtab shiftwidth=4 tabstop=4
set fileencodings=ucs-bom,utf-8,cp932
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set incsearch
set isfname-==
set keywordprg=:help
set list listchars=tab:-->
set matchpairs+=<:>
set matchtime=1
set nobackup
set noignorecase
set nonumber norelativenumber nocursorline
set noshowmode
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats&
set pumheight=10
set ruler
set rulerformat=%{&fileencoding}/%{&fileformat}
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set showcmd
set showmatch
set softtabstop=-1
set synmaxcol=300
set tags=./tags;
set timeout timeoutlen=500 ttimeoutlen=100
set updatetime=500
set wildmenu

" https://github.com/vim/vim/commit/3908ef5017a6b4425727013588f72cc7343199b9
if has('patch-8.2.4325')
    set wildoptions=pum
endif

" https://github.com/vim/vim/commit/aaad995f8384a77a64efba6846c9c4ac99de0953
if has('patch-8.2.0860')
    set nrformats-=octal
    set nrformats+=unsigned
endif

if has('persistent_undo')
    set undofile
    " https://github.com/neovim/neovim/commit/6995fad260e3e7c49e4f9dc4b63de03989411c7b
    if has('nvim')
        let &undodir = expand('$VIMRC_VIM/undofiles/neovim')
    else
        let &undodir = expand('$VIMRC_VIM/undofiles/vim')
    endif
    silent! call mkdir(&undodir, 'p')
else
    set noundofile
endif

let &cedit = "\<C-q>"
let g:vim_indent_cont = &g:shiftwidth
let g:restart_sessionoptions = &sessionoptions
let g:molder_show_hidden = 1
let g:quickrun_config = {
    \   "_" : {
    \       "outputter": "error",
    \       "outputter/error/success": "buffer",
    \       "outputter/error/error": "quickfix",
    \   },
    \   "java" : {
    \       "hook/output_encode/encoding": has('win32') ? 'cp932' : &encoding,
    \   },
    \   "vb" : {
    \       "command"   : "vbc",
    \       "exec" : ['%c /nologo /out:"Prog.exe" "%s:p"', 'Prog.exe'],
    \       "hook/output_encode/encoding": has('win32') ? 'cp932' : &encoding,
    \   },
    \}
let g:term_cmd = [&shell]
if has('win32') && executable('wmic') && has('gui_running')
    function! s:outcb(ch, mes) abort
        if 14393 < str2nr(trim(a:mes))
            let g:term_cmd = ['cmd.exe', '/k', 'doskey pwd=cd && doskey ls=dir /b && set prompt=$E[32m$$$E[0m']
        endif
    endfunction
    call job_start('wmic os get BuildNumber', { 'out_cb': function('s:outcb'), })
endif

if has('vim_starting')
    set hlsearch
    set laststatus=2
    set statusline&
    set showtabline=0
    set tabline&
    set termguicolors
endif

" script functions and variables
if v:true
    let s:delcmds = [
        \ 'MANPAGER', 'Man', 'Tutor', 'VimFoldh',
        \ 'TextobjBetweenDefaultKeyMappings', 'TextobjParameterDefaultKeyMappings', 'TextobjStringDefaultKeyMappings',
        \ 'CurrentLineWhitespaceOff', 'CurrentLineWhitespaceOn', 'DisableStripWhitespaceOnSave',
        \ 'DisableWhitespace', 'EnableStripWhitespaceOnSave', 'EnableWhitespace',
        \ 'NextTrailingWhitespace', 'PrevTrailingWhitespace', 'StripWhitespace',
        \ 'StripWhitespaceOnChangedLines', 'ToggleStripWhitespaceOnSave', 'ToggleWhitespace',
        \ 'TextobjLineDefaultKeyMappings', 'VimTweakDisableCaption', 'VimTweakDisableMaximize', 'VimTweakDisableTopMost',
        \ 'VimTweakEnableCaption', 'VimTweakEnableMaximize', 'VimTweakEnableTopMost',
        \ ]

    const s:hlname1 = 'VimrcDevPWBG'
    const s:hlname2 = 'VimrcDevPWSCH'

    let s:curr_job = get(s:, 'curr_job', v:null)
    let s:curr_timer = get(s:, 'curr_timer', v:null)
    let s:spinner_chars = ['/', '-', '\', '|']
    let s:spinner_index = 0

    let s:executor_id2query = get(s:, 'executor_id2query', {})
    let s:executor_id2title = get(s:, 'executor_id2title', {})
    let s:executor_id2prefixcmd = get(s:, 'executor_id2prefixcmd', {})
    let s:executor_id2postcmd = get(s:, 'executor_id2postcmd', {})
    let s:executor_id2maximum = get(s:, 'executor_id2maximum', {})
    let s:executor_id2ignores = get(s:, 'executor_id2ignores', {})
    let s:executor_id2withquery = get(s:, 'executor_id2withquery', {})
    let s:executor_id2position = get(s:, 'executor_id2position', {})
    let s:executor_id2matchitems = get(s:, 'executor_id2matchitems', {})

    function! s:exists_font(fname) abort
        return filereadable(expand('$USERPROFILE/AppData/Local/Microsoft/Windows/Fonts/' .. a:fname))
            \ || filereadable(expand('C:/Windows/Fonts/' .. a:fname))
    endfunction

    function! s:source_plugin_settings(dirname) abort
        if isdirectory($VIMRC_PKGSYNC_DIR)
            for s:setting in sort(split(globpath($VIMRC_VIM, printf('settings/plugins/%s/*', a:dirname)), '\n'))
                for s:plugin in sort(split(globpath($VIMRC_VIM, 'github/pack/*/*/*'), '\n'))
                    let s:x = split(s:setting, '[\/]')[-1]
                    let s:y = split(s:plugin, '[\/]')[-1]
                    if (tolower(s:x) == tolower(s:y .. '.vim')) || (tolower(s:x) == tolower(s:y))
                        execute 'source' s:setting
                    endif
                endfor
            endfor
        endif
    endfunction

    function! s:colorscheme() abort
        const colors_name = 'aylin'
        execute 'colorscheme' colors_name
        let normal_hl = hlget('Normal')[0]

        execute printf('highlight!       TabSideBar               guifg=%s   guibg=%s   gui=NONE cterm=NONE', '#777777', normal_hl['guibg'])
        execute printf('highlight!       TabSideBarFill           guifg=NONE guibg=%s   gui=NONE cterm=NONE',            normal_hl['guibg'])
        execute printf('highlight!       TabSideBarCurTab         guifg=%s   guibg=%s   gui=BOLD cterm=NONE', '#bcbcbc', normal_hl['guibg'])
        execute printf('highlight!       VimrcDevPWBG             guifg=%s   guibg=%s   gui=NONE cterm=NONE', '#ffffff', '#000000')
        execute printf('highlight!       VimrcDevPWSCH            guifg=%s   guibg=NONE gui=NONE cterm=NONE', '#ecc48d')

        highlight! CursorIM                 guifg=NONE    guibg=#d70000

        " itchyny/vim-parenmatch
        if exists('g:loaded_parenmatch')
            let g:parenmatch_highlight = 0
            highlight! link  ParenMatch  MatchParen
        endif

        " itchyny/vim-lightline
        if exists('g:loaded_lightline') && !empty(colors_name)
            let g:lightline = { 'colorscheme': colors_name }
            call lightline#enable()
        endif
        highlight!       SpecialKey               guifg=#444411
    endfunction

    function! s:vb_regex() abort
        return '^\s*\(Public\|Private\|Protected\)\?\s*\(Overridable\|Shared\)\?\s*\(Structure\|Enum\|Sub\|Function\)'
    endfunction

    function! s:vb_bufenter() abort
        let ext = fnamemodify(bufname(), ':e')
        if ('frm' == ext) || ('bas' == ext) || ('cls' == ext)
            setfiletype vb
        endif
        if &filetype == 'vb'
            syntax keyword vbKeyword MustOverride MustInherit ReadOnly Protected Imports Module Try Catch Overrides Overridable Throw Partial NotInheritable
            syntax keyword vbKeyword Shared Class Finally Using Continue Of Inherits Default Region Structure AndAlso OrElse
            syntax keyword vbKeyword Namespace Strict My MyBase IsNot Handles And Or Delegate MarshalAs Not In
            nnoremap <buffer><nowait><silent>[[      :<C-u>call search(<SID>vb_regex(), 'b')<cr>
            nnoremap <buffer><nowait><silent>]]      :<C-u>call search(<SID>vb_regex(), '')<cr>
        endif
    endfunction

    function! s:ripgrep_files() abort
        call s:ripgrep_init()
        let prefixcmd = ['rg'] + g:ripgrep_glob_args + ['--files', '--hidden']
        let postcmd = []
        call s:ripgrep_common_exec('ripgrep#files', 'files', prefixcmd, postcmd, v:false, function('s:files_callback'), get(g:, 'ripgrep_ignore_patterns', [
            \ 'min.js$', 'min.js.map$', 'Thumbs.db$',
            \ ]), g:ripgrep_maximum)
    endfunction

    function! s:ripgrep_livegrep() abort
        call s:ripgrep_init()
        let prefixcmd = ['rg'] + g:ripgrep_glob_args + ['--vimgrep', '-uu']
        let postcmd = (has('win32') ? ['.\'] : ['.'])
        call s:ripgrep_common_exec('ripgrep#livegrep#exec', 'livegrep', prefixcmd, postcmd, v:true, function('s:livegrep_callback'), get(g:, 'ripgrep_ignore_patterns', [
            \ '(os error \d\+)', '^[^:]*\<_viminfo:', '^[^:]*\<assets\>[^:]*:',
            \ ]), g:ripgrep_maximum)
    endfunction

    function! s:ripgrep_init() abort
        let g:ripgrep_maximum = get(g:, 'ripgrep_maximum', 100)
        let g:ripgrep_glob_args = get(g:, 'ripgrep_glob_args', [
            \ '--glob', '!NTUSER.DAT*',
            \ '--glob', '!.git',
            \ '--glob', '!.svn',
            \ '--glob', '!bin',
            \ '--glob', '!obj',
            \ '--glob', '!node_modules',
            \ '--line-buffered'
            \ ])
    endfunction

    function! s:files_callback(line) abort
        let path = fnamemodify(resolve(a:line), ':p:gs?\\?/?')
        call s:open_file(path)
    endfunction

    function! s:livegrep_callback(line) abort
        let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            let lnum = str2nr(m[2])
            let col = str2nr(m[3])
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
            endif
            call s:open_file(path, lnum, col)
        endif
    endfunction

    function! s:git_diff(q_bang) abort
        if isdirectory(s:git_get_rootdir())
            let g:git_enabled_qficonv = get(g:, 'git_enabled_qficonv', v:false)
            call s:gitdiff_open_numstatwindow(a:q_bang)
        else
            echohl Error
            echo '[git] The directory is not under git control!'
            echohl None
        endif
    endfunction

    function! GitDiffComp(ArgLead, CmdLine, CursorPos) abort
        let rootdir = s:git_get_rootdir()
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

    function! s:gitdiff_open_diffwindow(args, path) abort
        if s:execute_gitdiff('diff', ['diff'] + a:args + ['--', a:path])
            let b:gitdiff = { 'args': a:args, 'path': a:path, }
            nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_enter()<cr>
            nnoremap <buffer>!     <Cmd>call <SID>bufferkeymap_bang()<cr>
            nnoremap <buffer><C-o> <nop>
            nnoremap <buffer><C-i> <nop>
        endif
    endfunction

    function! s:gitdiff_open_numstatwindow(q_args) abort
        if s:execute_gitdiff('gitdiff-numstat', ['diff', '--numstat'] + split(a:q_args, '\s\+'))
            let b:gitdiff = { 'args': split(a:q_args, '\s\+'), 'rootdir': s:git_get_rootdir(), }
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
            if &filetype == 'gitdiff-numstat'
                syntax match  GitDiffNumstatAdd     '^\d\+'
                syntax match  GitDiffNumstatDelete  '\t\d\+\t'
                highlight default link GitDiffNumstatAdd       DiffAdd
                highlight default link GitDiffNumstatDelete    DiffDelete
            endif
            let &l:statusline = printf('[git] %s', join(a:cmd))
            let lines = filter(s:git_system(a:cmd), { _,x -> !empty(x) })
            if empty(lines)
                echohl Error
                echo '[git] No modified'
                echohl None
                if (1 < winnr('$')) || (1 < tabpagenr('$'))
                    close
                endif
            else
                call s:setbuflines(lines)
                " The lines encodes after redrawing.
                if get(g:, 'git_enabled_qficonv', v:false)
                    " Redraw windows because the encoding process is very slowly.
                    redraw
                    for i in range(0, len(lines) - 1)
                        let lines[i] = s:iconv_wrapper(lines[i])
                    endfor
                    call s:setbuflines(lines)
                endif
                return v:true
            endif
        endif
        return v:false
    endfunction

    function! s:bufferkeymap_enter() abort
        if &filetype == 'diff'
            call s:gitdiff_jumpdiffline()
        elseif &filetype == 'gitdiff-numstat'
            let path = trim(get(split(getline('.'), "\t") , 2, ''))
            let path = expand(b:gitdiff['rootdir'] .. '/' .. path)
            if filereadable(path)
                call s:gitdiff_open_diffwindow(b:gitdiff['args'], path)
            endif
        endif
    endfunction

    function! s:bufferkeymap_bang() abort
        let wnr = winnr()
        let lnum = line('.')
        if &filetype == 'diff'
            call s:gitdiff_open_diffwindow(b:gitdiff['args'], b:gitdiff['path'])
        elseif &filetype == 'gitdiff-numstat'
            call s:gitdiff_open_numstatwindow(join(b:gitdiff['args']))
        endif
        execute printf(':%dwincmd w', wnr)
        call cursor(lnum, 0)
    endfunction

    function! s:gitdiff_jumpdiffline() abort
        let x = s:parse_diffoutput()
        if !empty(x)
            call s:open_file(x['path'], x['after_lnum'])
        endif
    endfunction

    function! s:parse_diffoutput() abort
        let lines = getbufline(bufnr(), 1, '$')
        let curr_lnum = line('.')
        let lnum = -1
        let relpath = ''

        for m in range(curr_lnum, 1, -1)
            if lines[m - 1] =~# '^@@'
                let lnum = m
                break
            endif
        endfor

        for m in range(curr_lnum, 1, -1)
            if lines[m - 1] =~# '^+++ '
                let relpath = matchstr(lines[m - 1], '^+++ \zs.\+$')
                let relpath = substitute(relpath, '^b/', '', '')
                break
            endif
        endfor

        if (lnum < curr_lnum) && (0 < lnum)
            let after_n = 0
            let before_n = 0
            for n in range(lnum + 1, curr_lnum)
                let line = lines[n - 1]
                if line =~# '^-'
                    let before_n += 1
                elseif line =~# '^+'
                    let after_n += 1
                endif
            endfor
            let n3 = curr_lnum - lnum - after_n - before_n - 1
            let m = []
            let m2 = matchlist(lines[lnum - 1], '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\?\s*@@\(.*\)$')
            let m3 = matchlist(lines[lnum - 1], '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
            if !empty(m2)
                let m = m2
            elseif !empty(m3)
                let m = m3
            endif
            if !empty(m)
                let after_lnum = -1
                let before_lnum = -1
                for i in [1, 3, 5]
                    if '+' == m[i]
                        let after_lnum = str2nr(m[i + 1]) + after_n + n3
                    elseif '-' == m[i]
                        let before_lnum = str2nr(m[i + 1]) + before_n + n3
                    endif
                endfor
                return { 'after_lnum': after_lnum, 'before_lnum': before_lnum, 'path': expand(s:git_get_rootdir() .. '/' .. relpath) }
            endif
        endif

        return {}
    endfunction

    function! s:setbuflines(lines) abort
        setlocal modifiable noreadonly
        silent! call deletebufline(bufnr(), 1, '$')
        call setbufline(bufnr(), 1, a:lines)
        setlocal buftype=nofile nomodifiable readonly
    endfunction

    function! s:git_get_rootdir(path = '.') abort
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

    function s:git_system(subcmd) abort
        let cmd_prefix = ['git', '--no-pager']
        let cwd = s:git_get_rootdir()
        let lines = []
        let path = tempname()
        try
            let job = job_start(cmd_prefix + a:subcmd, {
                \ 'cwd': cwd,
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
    endfunction

    function s:iconv_wrapper(text) abort
        if has('win32') && (&encoding == 'utf-8') && exists('g:loaded_qficonv') && (len(a:text) < 500)
            return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
        else
            return a:text
        endif
    endfunction

    function! s:open_file(path, lnum = 0, col = 0) abort
        if filereadable(a:path)
            if s:find_window_by_path(a:path)
            elseif s:can_open_in_current() && (&filetype != 'diff')
                silent! execute printf('edit %s', fnameescape(a:path))
            else
                silent! execute printf('new %s', fnameescape(a:path))
            endif
            if (0 < a:lnum) || (0 < a:col)
                call cursor(a:lnum, a:col)
            endif
            normal! zz
        endif
    endfunction

    function! s:find_window_by_path(path) abort
        for x in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
            if x['bufnr'] == s:strict_bufnr(a:path)
                execute printf(':%dwincmd w', x['winnr'])
                return v:true
            endif
        endfor
        return v:false
    endfunction

    function! s:strict_bufnr(path) abort
        let bnr = bufnr(a:path)
        if -1 == bnr
            return -1
        else
            let fname1 = fnamemodify(a:path, ':t')
            let fname2 = fnamemodify(bufname(bnr), ':t')
            if fname1 == fname2
                return bnr
            else
                return -1
            endif
        endif
    endfunction

    function! s:can_open_in_current() abort
        let tstatus = term_getstatus(bufnr())
        if (tstatus != 'finished') && !empty(tstatus)
            return v:false
        elseif !empty(getcmdwintype())
            return v:false
        elseif &modified
            return v:false
        else
            return v:true
        endif
    endfunction

    function! s:ripgrep_common_exec(executor_id, title, prefix_cmd, post_cmd, withquery, callback, ignores, maximum) abort
        let s:executor_id2query[a:executor_id] = get(s:executor_id2query, a:executor_id, [])
        let s:executor_id2title[a:executor_id] = a:title
        let s:executor_id2prefixcmd[a:executor_id] = a:prefix_cmd
        let s:executor_id2postcmd[a:executor_id] = a:post_cmd
        let s:executor_id2maximum[a:executor_id] = a:maximum
        let s:executor_id2ignores[a:executor_id] = a:ignores
        let s:executor_id2withquery[a:executor_id] = a:withquery
        let s:executor_id2position[a:executor_id] = get(s:executor_id2position, a:executor_id, 1)
        let s:executor_id2matchitems[a:executor_id] = get(s:executor_id2matchitems, a:executor_id, [])
        if executable('rg') && !has('nvim')
            let winid = popup_menu([], s:get_title_option(a:executor_id))
            if -1 != winid
                let maxwidth = &columns - 2 - s:get_tabsidebarcolumns()
                let maxheight = &lines - 3 - &cmdheight
                call popup_setoptions(winid, {
                    \ 'filter': function('s:popup_filter', [a:executor_id]),
                    \ 'callback': function('s:popup_callback', [a:callback]),
                    \ 'highlight': s:hlname1,
                    \ 'border': [0, 0, 0, 0],
                    \ 'padding': [0, 0, 0, 0],
                    \ 'wrap': 0,
                    \ 'minwidth': maxwidth, 'maxwidth': maxwidth,
                    \ 'minheight': maxheight, 'maxheight': maxheight,
                    \ 'line': 2,
                    \ 'col': 2,
                    \ 'pos': 'topleft',
                    \ })
                if !empty(s:executor_id2query[a:executor_id])
                    call s:set_text(winid, a:executor_id, get(s:executor_id2matchitems, a:executor_id, []))
                    call s:set_cursorline(winid, a:executor_id, s:executor_id2position[a:executor_id])
                    call win_execute(winid, 'redraw')
                else
                    let s:executor_id2query[a:executor_id] = get(s:executor_id2query, a:executor_id, [])
                    call s:job_runner(winid, a:executor_id)
                endif
            endif
        endif
    endfunction

    function! s:get_title_option(executor_id) abort
        let status = ''
        if v:null != s:curr_job
            let status = job_status(s:curr_job)
        endif
        let s:spinner_index = (s:spinner_index + 1) % len(s:spinner_chars)
        return { 'title': printf(' %s %s>%s ',
            \   (status == 'run' ? ('(' .. s:spinner_chars[s:spinner_index] .. ')') : '   '),
            \   s:executor_id2title[a:executor_id],
            \   join(s:executor_id2query[a:executor_id], '')
            \ )}
    endfunction

    function! s:get_tabsidebarcolumns() abort
        let d = 0
        if has('tabsidebar')
            if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
                let d = &tabsidebarcolumns
            endif
        endif
        return d
    endfunction

    function! s:popup_filter(executor_id, winid, key) abort
        let lnum = line('.', a:winid)
        let s:executor_id2position[a:executor_id] = lnum
        let xs = s:executor_id2query[a:executor_id]
        if 21 == char2nr(a:key)
            " Ctrl-u
            if 0 < len(xs)
                call remove(xs, 0, -1)
                let s:executor_id2query[a:executor_id] = xs
                call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
            endif
            return 1
        elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
            " Ctrl-h or bs
            if 0 < len(xs)
                call remove(xs, -1)
                let s:executor_id2query[a:executor_id] = xs
                call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
            endif
            return 1
        elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
            let s:executor_id2query[a:executor_id] = xs + [a:key]
            call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
            return 1
        elseif 22 == char2nr(a:key)
            " Ctrl-v
            let s:executor_id2query[a:executor_id] = xs + split(@", '\zs')
            call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
            return 1
        elseif (10 == char2nr(a:key)) || (14 == char2nr(a:key))
            " Ctrl-n or Ctrl-j
            if lnum == line('$', a:winid)
                call s:set_cursorline(a:winid, a:executor_id, 1)
            else
                call s:set_cursorline(a:winid, a:executor_id, lnum + 1)
            endif
            return 1
        elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
            " Ctrl-p or Ctrl-k
            if lnum == 1
                call s:set_cursorline(a:winid, a:executor_id, line('$', a:winid))
            else
                call s:set_cursorline(a:winid, a:executor_id, lnum - 1)
            endif
            return 1
        elseif 0x12 == char2nr(a:key)
            " Ctrl-r
            call s:job_runner(a:winid, a:executor_id)
            return 1
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

    function! s:popup_callback(callback, winid, result) abort
        if -1 != a:result
            let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
            call a:callback(line)
        endif
    endfunction

    function! s:job_runner(winid, executor_id) abort
        let s:executor_id2position[a:executor_id] = 1
        call s:kill_job(a:winid)
        call s:kill_timer()
        call s:set_text(a:winid, a:executor_id, [])
        let query_text = substitute(join(s:executor_id2query[a:executor_id], ''), "[\n\r\t]", '', 'g')
        if !empty(query_text)
            let cmd = s:executor_id2prefixcmd[a:executor_id] + (s:executor_id2withquery[a:executor_id] ? [query_text] : []) + s:executor_id2postcmd[a:executor_id]
            let s:curr_timer = timer_start(100, function('s:timer', [a:winid, a:executor_id]), { 'repeat': -1 })
            let s:curr_job = job_start(cmd, {
                \ 'out_io': 'pipe',
                \ 'out_cb': function('s:out_cb', [a:winid, a:executor_id]),
                \ 'exit_cb': function('s:exit_cb', [a:winid, a:executor_id]),
                \ 'err_io': 'out',
                \ })
        else
            call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
        endif
    endfunction

    function! s:timer(winid, executor_id, timer) abort
        if (-1 == index(popup_list(), a:winid)) || (v:null == s:curr_job) || ('dead' == job_status(s:curr_job))
            call s:kill_timer()
        endif
        call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
    endfunction

    function! s:set_text(winid, executor_id, match_items) abort
        call win_execute(a:winid, 'call clearmatches()')
        let query_text = substitute(join(s:executor_id2query[a:executor_id], ''), "[\n\r\t]", '', 'g')
        let query_text = substitute(query_text, "'", "''", 'g')
        if !empty(query_text)
            call win_execute(a:winid, printf('silent call matchadd(''' .. s:hlname2 .. ''', ''%s'')', '\c' .. query_text))
        endif
        redraw
        let s:executor_id2matchitems[a:executor_id] = a:match_items
        call popup_settext(a:winid, s:executor_id2matchitems[a:executor_id])
    endfunction

    function! s:kill_timer() abort
        if v:null != s:curr_timer
            call timer_stop(s:curr_timer)
            let s:curr_timer = v:null
        endif
    endfunction

    function! s:kill_job(winid) abort
        if (v:null != s:curr_job) && ('run' == job_status(s:curr_job))
            call job_stop(s:curr_job, 'kill')
            let s:curr_job = v:null
        endif
    endfunction

    function! s:out_cb(winid, executor_id, ch, msg) abort
        let query_text = substitute(join(s:executor_id2query[a:executor_id], ''), "[\n\r\t]", '', 'g')
        try
            if (-1 == index(popup_list(), a:winid)) || (s:executor_id2maximum[a:executor_id] <= len(s:executor_id2matchitems[a:executor_id]))
                " kill the job if close the popup window
                call s:kill_job(a:winid)
            else
                let iconv_msg = join(map(split(a:msg, ':'), { _, x -> s:iconv_wrapper(x) }), ':')
                " ignore case
                if iconv_msg =~? query_text
                    let ok = v:true
                    for pat in s:executor_id2ignores[a:executor_id]
                        if iconv_msg =~# pat
                            let ok = v:false
                            break
                        endif
                    endfor
                    if ok
                        let s:executor_id2matchitems[a:executor_id] += [iconv_msg]
                        call popup_settext(a:winid, s:executor_id2matchitems[a:executor_id])
                    endif
                endif
                call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
            endif
        catch
            echo v:exception
        endtry
    endfunction

    function! s:exit_cb(winid, executor_id, job, status) abort
        call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
    endfunction

    function! s:set_cursorline(winid, executor_id, lnum) abort
        call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
        let s:executor_id2position[a:executor_id] = a:lnum
    endfunction
endif

if has('vim_starting')
    set packpath=$VIMRC_VIM/develop,$VIMRC_VIM/github
    set runtimepath=$VIMRUNTIME

    if has('win32') && has('gui_running')
        set linespace=0
        if s:exists_font('UDEVGothic-Regular.ttf')
            " https://github.com/yuru7/udev-gothic
            set guifont=UDEV_Gothic:h16:cSHIFTJIS:qDRAFT
        elseif s:exists_font('Cica-Regular.ttf')
            " https://github.com/miiton/Cica
            set guifont=Cica:h16:cSHIFTJIS:qDRAFT
        else
            set guifont=ＭＳ_ゴシック:h18:cSHIFTJIS:qDRAFT
        endif
    endif

    silent! source ~/.vimrc.local

    call s:source_plugin_settings('before')

    filetype plugin indent on
    syntax enable
    packloadall

    call s:source_plugin_settings('after')

    if !isdirectory($VIMRC_PKGSYNC_DIR)
        function! PkgSyncSetup() abort
            let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
            silent! call mkdir(path, 'p')
            call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
                \ 'cwd': path,
                \ })
        endfunction
        autocmd vimrc-plugins VimEnter *
            \ :if !exists(':PkgSync')
            \ |  execute 'command! -nargs=0 PkgSyncSetup :call PkgSyncSetup()'
            \ |endif
    endif
endif

if has('tabsidebar')
    function! TabSideBar() abort
        try
            let tnr = get(g:, 'actual_curtabpage', tabpagenr())
            let lines = []
            let lines += [tnr == tabpagenr() ? '%#TabSideBarCurTab#' : '%#TabSideBar#']
            for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
                let ft = getbufvar(x['bufnr'], '&filetype')
                let bt = getbufvar(x['bufnr'], '&buftype')
                let high_tab = tnr == tabpagenr() ? '%#TabSideBarCurTab#' : '%#TabSideBar#'
                let fname = fnamemodify(bufname(x['bufnr']), ':t')
                let lines += [
                    \    high_tab
                    \ .. ' '
                    \ .. (getbufvar(x['bufnr'], '&readonly') && empty(bt) ? '[R]' : '')
                    \ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
                    \ .. (!empty(bt)
                    \      ? printf('[%s]', bt == 'nofile' ? ft : bt)
                    \      : (empty(bufname(x['bufnr']))
                    \          ? '[No Name]'
                    \          : fname))
                    \ ]
            endfor
            let lines += ['']
            return join(lines, "\n")
        catch
            return v:exception
        endtry
    endfunction
    let g:tabsidebar_vertsplit = 1
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=16
    set tabsidebar=%!TabSideBar()
    for s:name in [
        \ 'TabSideBar',
        \ 'TabSideBarFill',
        \ ]
        if !hlexists(s:name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', s:name)
        endif
    endfor
endif

" Can't use <S-space> at :terminal
" https://github.com/vim/vim/issues/6040
tnoremap <silent><S-space>           <space>

" Smart space on wildmenu
cnoremap <expr><space>             (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

" Emacs key mappings
if has('win32') && (&shell =~# '\<cmd\.exe$')
    tnoremap <silent><C-p>           <up>
    tnoremap <silent><C-n>           <down>
    tnoremap <silent><C-b>           <left>
    tnoremap <silent><C-f>           <right>
    tnoremap <silent><C-e>           <end>
    tnoremap <silent><C-a>           <home>
    tnoremap <silent><C-u>           <esc>
endif

cnoremap         <C-b>        <left>
cnoremap         <C-f>        <right>
cnoremap         <C-e>        <end>
cnoremap         <C-a>        <home>

nnoremap <silent><C-n>    <Cmd>cnext     \| normal zz<cr>
nnoremap <silent><C-p>    <Cmd>cprevious \| normal zz<cr>

nnoremap <silent><space>  <nop>

nnoremap <silent><C-q>    <Cmd>GitDiff -w<cr>
nnoremap <silent><C-s>    <Cmd>call <SID>ripgrep_livegrep()<cr>
nnoremap <silent><C-f>    <Cmd>call <SID>ripgrep_files()<cr>
nnoremap <silent><C-z>    <Cmd>call term_start(g:term_cmd, {
    \   'term_highlight' : 'Terminal',
    \   'term_finish' : 'close',
    \   'term_kill' : 'kill',
    \ })<cr>

map      <silent>y        <Plug>(operator-flashy)
nmap     <silent>Y        <Plug>(operator-flashy)$
nmap     <silent>s        <Plug>(operator-replace)
nmap     <silent>ss       <Plug>(operator-replace)as
nmap     <silent>ds       das
nmap     <silent>ys       yas
nmap     <silent>vs       vas

augroup vimrc-autocmds
    autocmd!
    " Delete unused commands, because it's an obstacle on cmdline-completion.
    autocmd CmdlineEnter *
        \ : for s:cmdname in s:delcmds
        \ |     execute printf('silent! delcommand %s', s:cmdname)
        \ | endfor
        \ | unlet s:cmdname
    autocmd FileType help :setlocal colorcolumn=78
    autocmd CmdlineEnter *
        \ : if getcmdtype() == ':'
        \ |     set ignorecase
        \ | endif
    autocmd CmdlineLeave * :set noignorecase
    autocmd VimEnter *
        \ : if 2 == exists(':VimTweakSetAlpha')
        \ |     VimTweakSetAlpha 245
        \ | endif
    autocmd FileType molder
        \ :nnoremap <buffer> h  <plug>(molder-up)
        \ |nnoremap <buffer> l  <plug>(molder-open)
        \ |nnoremap <buffer> t  <Cmd>call term_start(&shell, { 'cwd': b:molder_dir, })<cr>
    autocmd BufEnter * :call <SID>vb_bufenter()
augroup END

call s:colorscheme()

if executable('git')
    command! -nargs=* -complete=customlist,GitDiffComp  GitDiff      :call s:git_diff(<q-args>)
endif

