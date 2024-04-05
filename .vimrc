"
" ---------------------------------------------------------------------------------------------------
" How to setup if git is not installed
"   1. $curl https://raw.githubusercontent.com/rbtnn/vimrc/master/.vimrc        -o .vimrc
"   2. $curl https://raw.githubusercontent.com/rbtnn/vimrc/master/pkgsync.json  -o pkgsync.json
"
" How to install plugins
"   1. :PkgSyncSetup
"   2. :PkgSync update
" ---------------------------------------------------------------------------------------------------
"
scriptencoding utf-8
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/.vim')
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
set cmdheight=3
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
set hlsearch
set incsearch
set isfname-==
set keywordprg=:help
set list listchars=tab:-->
set matchpairs+=<:>
set matchtime=1
set nobackup
set noignorecase
set nonumber norelativenumber nocursorline
set noruler rulerformat&
set noshowmode
set noswapfile
set nowrap
set nowrapscan
set nowritebackup
set nrformats&
set pumheight=10
set scrolloff&
set sessionoptions=winpos,resize,tabpages,curdir,help
set shiftround
set showcmd
set showmatch
set showtabline=0 tabline&
set softtabstop=-1
set synmaxcol=300
set tags=./tags;
set termguicolors
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

let g:vimrc = get(g:, 'vimrc', {
    \   'term_cmd': [&shell],
    \   'git_enabled_qficonv': v:false,
    \   'vb_pattern_back': '^\s*\(Public\|Private\|Protected\)\?\s*\(Overridable\|Shared\)\?\s*\(Structure\|Enum\|Sub\|Function\)',
    \   'vb_pattern_forword': '^\s*\(Public\|Private\|Protected\)\?\s*\(Overridable\|Shared\)\?\s*\(Structure\|Enum\|Sub\|Function\)',
    \ })
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

if has('win32') && executable('wmic') && has('gui_running')
    function! s:outcb(ch, mes) abort
        if 14393 < str2nr(trim(a:mes))
            let g:vimrc.term_cmd = ['cmd.exe', '/k', 'doskey pwd=cd && doskey ls=dir /b && set prompt=$E[32m$$$E[0m']
        endif
    endfunction
    call job_start('wmic os get BuildNumber', { 'out_cb': function('s:outcb'), })
endif

if has('statusline')
    function! StatusLine() abort
        try
            let id = synID(line('.'), col('.'), 0)
            let tid = synIDtrans(id)
            let p = id != tid && tid != 0
            let xs = []
            let x = bufname(bufnr())
            if !empty(x)
                let xs += [x]
            endif
            let xs += [
                \   'lnum:' .. line('.') .. '/' .. line('$'),
                \   'col:' .. col('.'),
                \   'ft:' .. &fileformat,
                \   'fe:' .. &fileencoding,
                \ ]
            for x in [
                \   { 'name': 'hi', 'val': synIDattr(id, 'name'), 'expr': '!empty(x.val)', },
                \   { 'name': 'link', 'val': synIDattr(tid, 'name'), 'expr': 'p', },
                \   { 'name': 'fg', 'val': synIDattr(p ? tid : id, 'fg#'), 'expr': '!empty(x.val)', },
                \   { 'name': 'bg', 'val': synIDattr(p ? tid : id, 'bg#'), 'expr': '!empty(x.val)', },
                \ ]
                if eval(x.expr)
                    let xs += [x.name .. ':' .. x.val]
                endif
            endfor
            return join(xs)
        catch
            return v:exception
        endtry
    endfunction
    set laststatus=2
    set statusline=%!StatusLine()
endif

if has('tabsidebar')
    function! TabSideBar() abort
        try
            let tnr = get(g:, 'actual_curtabpage', tabpagenr())
            let lines = []
            let lines += [(tnr == tabpagenr() ? '%#TabSideBarSel' : '%#TabSideBar') .. (tnr % 2 == 0 ? 'Odd' : 'Even') .. '#']
            for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
                let ft = getbufvar(x['bufnr'], '&filetype')
                let bt = getbufvar(x['bufnr'], '&buftype')
                let high_tab = (tnr == tabpagenr() ? '%#TabSideBarSel' : '%#TabSideBar') .. (tnr % 2 == 0 ? 'Odd' : 'Even') .. '#'
                let fname = fnamemodify(bufname(x['bufnr']), ':t')
                let lines += [
                    \    high_tab
                    \ .. (x['bufnr'] == bufnr() ? ' * ' : '   ')
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
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=16
    set tabsidebar=%!TabSideBar()
    for s:name in [
        \ 'TabSideBar',
        \ 'TabSideBarSel',
        \ 'TabSideBarFill',
        \ ]
        if !hlexists(s:name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', s:name)
        endif
    endfor
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

    function! s:pkgsync_setup() abort
        if !isdirectory($VIMRC_PKGSYNC_DIR)
            let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
            silent! call mkdir(path, 'p')
            call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
                \ 'cwd': path,
                \ })
            echo 'please restart Vim!'
        endif
    endfunction

    function! s:exists_font(fname) abort
        return filereadable(expand('$USERPROFILE/AppData/Local/Microsoft/Windows/Fonts/' .. a:fname))
            \ || filereadable(expand('C:/Windows/Fonts/' .. a:fname))
    endfunction

    function! s:git_diff(q_bang) abort
        if isdirectory(s:git_get_rootdir())
            call s:gitdiff_open_numstatwindow(a:q_bang)
        else
            echohl Error
            echo '[git] The directory is not under git control!'
            echohl None
        endif
    endfunction

    function! s:git_grep(q_args) abort
        let rootdir = s:git_get_rootdir()
        if isdirectory(rootdir)
            let lines = s:git_system(['grep', '--line-number', '--column', '--no-color', a:q_args])
            call setqflist([])
            if !empty(lines)
                let xs = []
                for line in lines
                    let m = matchlist(line, '^\(.\+\):\(\d\+\):\(\d\+\):\(.*\)$')
                    if !empty(m)
                        let xs += [{
                            \ 'filename': expand(rootdir .. '/' .. s:iconv_wrapper(m[1])),
                            \ 'lnum': str2nr(m[2]),
                            \ 'col': m[3],
                            \ 'text': s:iconv_wrapper(m[4]), }]
                    else
                        let xs += [{ 'text': line, }]
                    endif
                endfor
                call setqflist(xs)
                copen
            endif
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
            nnoremap <buffer><cr>  <Cmd>call <SID>bufferkeymap_openfile()<cr>
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
                syntax match  DiffAdd     '^\d\+'
                syntax match  DiffDelete  '\t\d\+\t'
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
                if g:vimrc.git_enabled_qficonv
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

    function! s:bufferkeymap_openfile() abort
        if &filetype == 'gitdiff-numstat'
            let path = trim(get(split(getline('.'), "\t") , 2, ''))
            let path = expand(b:gitdiff['rootdir'] .. '/' .. path)
            if filereadable(path)
                call s:open_file(path, -1)
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
        if has('win32') && (&encoding == 'utf-8') && exists('g:loaded_qficonv') && (len(a:text) < &columns)
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

    function! s:vimrc_bufferenter() abort
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

        nnoremap <silent><C-j>    <Cmd>tabnext<cr>
        nnoremap <silent><C-k>    <Cmd>tabprevious<cr>
        tnoremap <silent><C-j>    <Cmd>tabnext<cr>
        tnoremap <silent><C-k>    <Cmd>tabprevious<cr>

        nnoremap <silent><C-p>    <Cmd>cprevious<cr>
        nnoremap <silent><C-n>    <Cmd>cnext<cr>

        nnoremap <silent><space>  <nop>

        nnoremap <silent><C-z>    <Cmd>call term_start(g:vimrc.term_cmd, {
            \   'term_highlight' : 'Terminal',
            \   'term_finish' : 'close',
            \   'term_kill' : 'kill',
            \ })<cr>

        if executable('git')
            command! -nargs=* -complete=customlist,GitDiffComp  GitDiff      :call s:git_diff(<q-args>)
            command! -nargs=1                                   GitGrep      :call s:git_grep(<q-args>)
            nnoremap <silent><C-q>    <Cmd>GitDiff -w<cr>
            nnoremap <silent><C-s>    <Cmd>GitDiff -w upstream<cr>
        endif

        if get(g:, 'loaded_operator_replace', v:false)
            nmap     <silent>s        <Plug>(operator-replace)
            nmap     <silent>ss       <Plug>(operator-replace)as
        endif
        if get(g:, 'loaded_operator_flashy', v:false)
            map      <silent>y        <Plug>(operator-flashy)
            nmap     <silent>Y        <Plug>(operator-flashy)$
        endif
        if get(g:, 'loaded_textobj_string', v:false)
            nmap     <silent>ds       das
            nmap     <silent>ys       yas
            nmap     <silent>vs       vas
        endif
        if get(g:, 'loaded_molder', v:false)
            nnoremap <silent><C-f>    <Cmd>e .<cr>
            if &filetype == 'molder'
                nnoremap <buffer> h  <plug>(molder-up)
                nnoremap <buffer> l  <plug>(molder-open)
                nnoremap <buffer> C  <Cmd>call chdir(b:molder_dir) \| verbose pwd<cr>
                if has('win32')
                    nnoremap <buffer> E  <Cmd>call term_start('explorer .', {
                        \   'cwd': b:molder_dir,
                        \   'hidden': v:true,
                        \ })<cr>
                endif
                nnoremap <buffer> T  <Cmd>call term_start(g:vimrc.term_cmd, {
                    \   'cwd': b:molder_dir,
                    \   'term_highlight' : 'Terminal',
                    \   'term_finish' : 'close',
                    \   'term_kill' : 'kill',
                    \ })<cr>
            endif
        endif
        let ext = fnamemodify(bufname(), ':e')
        if ('frm' == ext) || ('bas' == ext) || ('cls' == ext)
            setfiletype vb
        endif
        if &filetype == 'vb'
            syntax keyword vbKeyword MustOverride MustInherit ReadOnly Protected Imports Module Try Catch Overrides Overridable Throw Partial NotInheritable
            syntax keyword vbKeyword Shared Class Finally Using Continue Of Inherits Default Region Structure AndAlso OrElse
            syntax keyword vbKeyword Namespace Strict My MyBase IsNot Handles And Or Delegate MarshalAs Not In
            nnoremap <buffer><nowait><silent>[[      :<C-u>call search(g:vimrc.vb_pattern_back, 'b')<cr>
            nnoremap <buffer><nowait><silent>]]      :<C-u>call search(g:vimrc.vb_pattern_forword, '')<cr>
        endif
    endfunction

    function! s:vimrc_colorscheme() abort
        highlight! TabSideBarOdd      guifg=#777777 guibg=#252a36 gui=NONE cterm=NONE
        highlight! TabSideBarEven     guifg=#777777 guibg=#2f3440 gui=NONE cterm=NONE
        highlight! TabSideBarSelOdd   guifg=#acfcac guibg=#252a36 gui=BOLD cterm=NONE
        highlight! TabSideBarSelEven  guifg=#acfcac guibg=#2f3440 gui=BOLD cterm=NONE
        highlight! TabSideBarFill     guifg=NONE    guibg=NONE    gui=NONE cterm=NONE
        highlight! VimrcDevPWBG       guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
        highlight! VimrcDevPWSCH      guifg=#ecc48d guibg=NONE    gui=NONE cterm=NONE
        highlight! Cursor             guifg=#000000 guibg=#d7d7d7
        highlight! CursorIM           guifg=NONE    guibg=#d70000
        highlight! SpecialKey         guifg=#444411
        highlight! NonText            guifg=#1f2430
        highlight! link diffAdded     DiffAdd
        highlight! link diffRemoved   DiffDelete
        " itchyny/vim-parenmatch
        if get(g:, 'loaded_parenmatch', v:false)
            let g:parenmatch_highlight = 0
            highlight! link  ParenMatch  MatchParen
        endif
        " itchyny/vim-lightline
        if get(g:, 'loaded_lightline', v:false)
            let g:lightline = { 'colorscheme': 'aylin' }
            call lightline#enable()
        endif
    endfunction
endif

set packpath=$VIMRC_VIM/github
set runtimepath=$VIMRUNTIME

if has('win32') && has('gui_running') && has('vim_starting')
    set linespace=0
    if s:exists_font('Cica-Regular.ttf')
        " https://github.com/miiton/Cica
        set guifont=Cica:h16:cSHIFTJIS:qDRAFT
    elseif s:exists_font('UDEVGothic-Regular.ttf')
        " https://github.com/yuru7/udev-gothic
        set guifont=UDEV_Gothic:h16:cSHIFTJIS:qDRAFT
    else
        set guifont=ＭＳ_ゴシック:h18:cSHIFTJIS:qDRAFT
    endif
endif

silent! source ~/.vimrc.local

filetype plugin indent on
syntax enable
packloadall

augroup vimrc
    autocmd!
    " Delete unused commands, because it's an obstacle on cmdline-completion.
    autocmd CmdlineEnter *
        \ : for s:cmdname in s:delcmds
        \ |     execute printf('silent! delcommand %s', s:cmdname)
        \ | endfor
        \ | unlet s:cmdname
        \ | if getcmdtype() == ':'
        \ |     set ignorecase
        \ | endif
    autocmd VimEnter *
        \ : if !exists(':PkgSync')
        \ |    execute 'command! -nargs=0 PkgSyncSetup :call <SID>pkgsync_setup()'
        \ | endif
    autocmd CmdlineLeave *  : set noignorecase
    autocmd FileType help   : setlocal colorcolumn=78
    autocmd BufEnter *      : call s:vimrc_bufferenter()
    autocmd ColorScheme *   : call s:vimrc_colorscheme()
    autocmd WinEnter *
        \ : if exists(':EmphasisCursor')
        \ |     EmphasisCursor -count=3 -highlight=ModeMsg
        \ | endif
augroup END

call s:vimrc_bufferenter()

try
    colorscheme aylin
catch
    colorscheme default
endtry
