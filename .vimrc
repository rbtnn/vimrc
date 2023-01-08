
if &compatible
    set nocompatible
endif

set makeencoding=char
scriptencoding utf-8

let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')

function! PkgSyncSetup() abort
    let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
    silent! call mkdir(path, 'p')
    call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
        \ 'cwd': path,
        \ })
endfunction

augroup vimrc
    autocmd!
    " Delete unused commands, because it's an obstacle on cmdline-completion.
    autocmd CmdlineEnter     *
        \ : for s:cmdname in ['MANPAGER', 'Man', 'Tutor', 'VimFoldh', 'TextobjStringDefaultKeyMappings']
        \ |     execute printf('silent! delcommand %s', s:cmdname)
        \ | endfor
        \ | unlet s:cmdname
    autocmd FileType help :setlocal colorcolumn=78
    autocmd VimEnter        *
        \ :if !exists(':PkgSync')
        \ |  execute 'command! -nargs=0 PkgSyncSetup :call PkgSyncSetup()'
        \ |endif
augroup END

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
set fileformats=unix,dos
set foldlevelstart=999
set foldmethod=indent
set grepformat&
set grepprg=internal
set ignorecase
set incsearch
set isfname-==
set keywordprg=:help
set list listchars=tab:\ \|,trail:-
set matchpairs+=<:>
set matchtime=1
set nobackup
set nocursorline
set nonumber
set norelativenumber
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

function! s:is_installed(user_and_name) abort
    let xs = split(a:user_and_name, '/')
    return !empty(globpath($VIMRC_VIM, 'github/pack/' .. xs[0] .. '/*/' .. xs[1]))
endfunction

if s:is_installed('tyru/restart.vim')
    let g:restart_sessionoptions = &sessionoptions
endif

if has('vim_starting')
    set hlsearch
    set laststatus=2
    set statusline&
    set showtabline=0
    set tabline&

    set packpath=$VIMRC_VIM/local,$VIMRC_VIM/github
    set runtimepath=$VIMRUNTIME

    silent! source ~/.vimrc.local
    filetype plugin indent on
    syntax enable
    packloadall
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

nnoremap <silent><C-n>    <Cmd>cnext \| normal zz<cr>
nnoremap <silent><C-p>    <Cmd>cprevious \| normal zz<cr>

if s:is_installed('rbtnn/vim-textobj-string')
    nmap <silent>ds das
    nmap <silent>ys yas
    nmap <silent>vs vas
    if s:is_installed('kana/vim-operator-replace')
        nmap <silent>s   <Plug>(operator-replace)
        nmap <silent>ss  <Plug>(operator-replace)as
    endif
endif

if s:is_installed('rbtnn/vim-gitdiff')
    nnoremap <silent><C-s>    <Cmd>execute 'GitDiffNumStat' get(g:, 'gitdiff_args', '-w')<cr>
endif

if s:is_installed('rbtnn/vim-qfjob')
    command! -nargs=*                                           GitGrep           :call s:gitgrep(<q-args>)
    command! -nargs=*                                           RipGrep           :call s:ripgrep(<q-args>)

    if has('win32') && executable('msbuild')
        command! -complete=customlist,MSBuildRunTaskComp -nargs=* MSBuildRunTask    :call s:msbuild_runtask(eval(g:msbuild_projectfile), <q-args>)
        command!                                         -nargs=1 MSBuildNewProject :call s:msbuild_newproject(<q-args>)
    endif
    let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

    function! s:gitgrep(q_args) abort
        let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n', '--column'] + split(a:q_args, '\s\+')
        call qfjob#start(cmd, {
            \ 'title': 'git grep',
            \ 'line_parser': function('s:gitgrep_line_parser'),
            \ })
    endfunction

    function s:gitgrep_line_parser(line) abort
        let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(path, ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': s:iconv(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction

    function s:iconv(text) abort
        if exists('g:loaded_qficonv') && (len(a:text) < 500)
            return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
        else
            return a:text
        endif
    endfunction

    function! s:ripgrep(q_args) abort
        let cmd = ['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
        call qfjob#start(cmd, {
            \ 'title': 'ripgrep',
            \ 'line_parser': function('s:ripgrep_line_parser'),
            \ })
    endfunction

    function s:ripgrep_line_parser(line) abort
        let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': s:iconv(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction

    function! s:msbuild_runtask(projectfile, args) abort
        if type([]) == type(a:args)
            let cmd = ['msbuild']
            if filereadable(a:projectfile)
                let cmd += ['/nologo', a:projectfile] + a:args
            else
                let cmd += ['/nologo'] + a:args
            endif
        else
            let cmd = printf('msbuild /nologo %s %s', a:args, a:projectfile)
        endif
        call qfjob#start(cmd, {
            \ 'title': 'msbuild',
            \ 'line_parser': function('s:msbuild_runtask_line_parser', [a:projectfile]),
            \ })
    endfunction

    function s:msbuild_runtask_line_parser(projectfile, line) abort
        let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(a:projectfile, ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': s:iconv(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': s:iconv(m[4]),
                \ }
        else
            return { 'text': s:iconv(a:line), }
        endif
    endfunction

    function! MSBuildRunTaskComp(A, L, P) abort
        let xs = []
        let path = eval(g:msbuild_projectfile)
        if filereadable(path)
            for line in readfile(path)
                let m = matchlist(line, '<Target\s\+Name="\([^"]\+\)"')
                if !empty(m)
                    let xs += ['/t:' .. m[1]]
                endif
            endfor
        endif
        return xs
    endfunction

    function! s:msbuild_newproject(q_args) abort
        const projectname = trim(a:q_args)
        if isdirectory(projectname)
            echohl Error
            echo   'The directory already exists: ' .. string(projectname)
            echohl None
        elseif projectname =~# '^[a-zA-Z0-9_-]\+$'
            call mkdir(expand(projectname .. '/src'), 'p')
            call writefile([
                \   "using System;",
                \   "using System.IO;",
                \   "using System.Text;",
                \   "using System.Text.RegularExpressions;",
                \   "using System.Collections.Generic;",
                \   "using System.Linq;",
                \   "",
                \   "class Prog {",
                \   "\tstatic void Main(string[] args) {",
                \   "\t\tConsole.WriteLine(\"Hello\");",
                \   "\t}",
                \   "}",
                \ ], expand(projectname .. '/src/Main.cs'))
            call writefile([
                \   "<Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">",
                \   "\t<PropertyGroup>",
                \   "\t\t<AssemblyName>Main.exe</AssemblyName>",
                \   "\t\t<OutputPath>bin\\</OutputPath>",
                \   "\t\t<OutputType>exe</OutputType>",
                \   "\t\t<References></References>",
                \   "\t</PropertyGroup>",
                \   "\t<ItemGroup>",
                \   "\t\t<Compile Include=\"src\\*.cs\" />",
                \   "\t</ItemGroup>",
                \   "\t<Target Name=\"Build\">",
                \   "\t\t<MakeDir Directories=\"$(OutputPath)\" Condition=\"!Exists('$(OutputPath)')\" />",
                \   "\t\t<Csc",
                \   "\t\t\tSources=\"@(Compile)\"",
                \   "\t\t\tTargetType=\"$(OutputType)\"",
                \   "\t\t\tReferences=\"$(References)\"",
                \   "\t\t\tOutputAssembly=\"$(OutputPath)$(AssemblyName)\" />",
                \   "\t</Target>",
                \   "\t<Target Name=\"Run\" >",
                \   "\t\t<Exec Command=\"$(OutputPath)$(AssemblyName)\" />",
                \   "\t</Target>",
                \   "\t<Target Name=\"Clean\" >",
                \   "\t\t<Delete Files=\"$(OutputPath)$(AssemblyName)\" />",
                \   "\t</Target>",
                \   "</Project>",
                \ ], expand(projectname .. '/msbuild.xml'))
            echo 'Made new proect: ' .. string(projectname)
        else
            echohl Error
            echo   'Invalid the project name: ' .. string(projectname)
            echohl None
        endif
    endfunction
endif

if has('vim_starting')
    set termguicolors
    if s:is_installed('tomasr/molokai')
        if s:is_installed('itchyny/lightline.vim')
            let g:lightline = { 'colorscheme': 'molokai' }
        endif
        autocmd vimrc ColorScheme      *
            \ : highlight!       TabSideBar        guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarFill    guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarSel     guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarLabel   guifg=#66d9ff guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       CursorIM          guifg=NONE    guibg=#d70000
            \ | highlight!       PopupBorder       guifg=#66d9ff guibg=NONE
            \ | highlight!       SpecialKey        guifg=#223344 guibg=NONE
            \ | highlight! link  diffAdded         Identifier
            \ | highlight! link  diffRemoved       Special
            \ | highlight!       DiffText                                      gui=NONE
            \ | highlight!       Macro                                         gui=NONE
            \ | highlight!       SpecialKey                                    gui=NONE
            \ | highlight!       Special                                       gui=NONE
            \ | highlight!       StorageClass                                  gui=NONE
            \ | highlight!       Tag                                           gui=NONE
        colorscheme molokai
    endif
endif

if has('tabsidebar')
    function! s:TabSideBarLabel(text) abort
        let rest = &tabsidebarcolumns - len(a:text)
        if rest < 0
            rest = 0
        endif
        return '%#TabSideBarLabel#' .. repeat(' ', rest / 2) .. a:text .. repeat(' ', rest / 2 + (rest % 2)) .. '%#TabSideBar#'
    endfunction

    function! TabSideBar() abort
        let tnr = get(g:, 'actual_curtabpage', tabpagenr())
        let lines = []
        let lines += ['', s:TabSideBarLabel(printf(' TABPAGE %d ', tnr)), '']
        for x in filter(getwininfo(), { i,x -> tnr == x['tabnr'] && ('popup' != win_gettype(x['winid']))})
            let ft = getbufvar(x['bufnr'], '&filetype')
            let bt = getbufvar(x['bufnr'], '&buftype')
            let current = (tnr == tabpagenr()) && (x['winnr'] == winnr())
            let high = (current ? '%#TabSideBarSel#' : '%#TabSideBar#')
            let fname = fnamemodify(bufname(x['bufnr']), ':t')
            let lines += [
                \    high
                \ .. ' '
                \ .. (!empty(bt)
                \      ? printf('[%s]', bt == 'nofile' ? ft : bt)
                \      : (empty(bufname(x['bufnr']))
                \          ? '[No Name]'
                \          : fname))
                \ .. (getbufvar(x['bufnr'], '&modified') && empty(bt) ? '[+]' : '')
                \ ]
        endfor
        return join(lines, "\n")
    endfunction
    let g:tabsidebar_vertsplit = 0
    set notabsidebaralign
    set notabsidebarwrap
    set showtabsidebar=2
    set tabsidebarcolumns=16
    set tabsidebar=%!TabSideBar()
    for name in ['TabSideBar', 'TabSideBarFill', 'TabSideBarSel']
        if !hlexists(name)
            execute printf('highlight! %s guibg=NONE gui=NONE cterm=NONE', name)
        endif
    endfor
endif

if has('popupwin')
    nnoremap <silent><space>  <Cmd>call <SID>ff()<cr>

    let s:ff_mrw_path = get(s:, 'ff_mrw_path', expand('~/.ffmrw'))
    let s:subwinid = get(s:, 'subwinid', -1)

    augroup ff-mrw
        autocmd!
        autocmd BufWritePost         * :call <SID>mrw_bufwritepost()
    augroup END

    function! s:ff() abort
        let winid = popup_menu([], s:get_popupwin_options_main())
        let s:subwinid = popup_create('', s:get_popupwin_options_sub(winid))
        if -1 != winid
            call popup_setoptions(winid, {
                \ 'filter': function('s:popup_filter'),
                \ 'callback': function('s:popup_callback'),
                \ })
            call s:create_context(winid, v:false)
            call s:update_lines(winid)
        endif
    endfunction

    function! s:fix_path(path) abort
        return fnamemodify(resolve(a:path), ':p:gs?\\?/?')
    endfunction

    function! s:mrw_bufwritepost() abort
        let path = s:fix_path(s:ff_mrw_path)
        let lines = s:read_mrwfile()
        let fullpath = s:fix_path(expand('<afile>'))
        if fullpath != path
            let p = v:false
            if filereadable(path)
                if filereadable(fullpath)
                    if 0 < len(get(lines, 0, ''))
                        if fullpath != s:fix_path(get(lines, 0, ''))
                            let p = v:true
                        endif
                    else
                        let p = v:true
                    endif
                endif
            else
                let p = v:true
            endif
            if p
                call writefile([fullpath] + filter(lines, { i,x -> x != fullpath }), path)
            endif
        endif
    endfunction

    function! s:popup_filter(winid, key) abort
        let lnum = line('.', a:winid)
        let xs = split(s:ctx['query'], '\zs')
        if 21 == char2nr(a:key)
            " Ctrl-u
            if 0 < len(xs)
                call remove(xs, 0, -1)
                let s:ctx['query'] = join(xs, '')
                call s:update_lines(a:winid)
            endif
            return 1
        elseif 33 == char2nr(a:key)
            " !
            call s:create_context(a:winid, v:true)
            call s:update_lines(a:winid)
            return 1
        elseif (10 == char2nr(a:key)) || (14 == char2nr(a:key))
            " Ctrl-n or Ctrl-j
            if lnum == line('$', a:winid)
                call s:set_cursorline(a:winid, 1)
            else
                call s:set_cursorline(a:winid, lnum + 1)
            endif
            return 1
        elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
            " Ctrl-p or Ctrl-k
            if lnum == 1
                call s:set_cursorline(a:winid, line('$', a:winid))
            else
                call s:set_cursorline(a:winid, lnum - 1)
            endif
            return 1
        elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
            " Ctrl-h or bs
            if 0 < len(xs)
                call remove(xs, -1)
                let s:ctx['query'] = join(xs, '')
                call s:update_lines(a:winid)
            endif
            return 1
        elseif 0x20 == char2nr(a:key)
            return popup_filter_menu(a:winid, "\<cr>")
        elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
            let xs += [a:key]
            let s:ctx['query'] = join(xs, '')
            call s:update_lines(a:winid)
            return 1
        elseif 0x0d == char2nr(a:key)
            return popup_filter_menu(a:winid, "\<cr>")
        endif
        if char2nr(a:key) < 0x20
            return popup_filter_menu(a:winid, "\<esc>")
        else
            return popup_filter_menu(a:winid, a:key)
        endif
    endfunction

    function! s:update_title(winid) abort
        let n = line('$', a:winid)
        if empty(get(getbufline(winbufnr(a:winid), 1), 0, ''))
            let n = 0
        endif
        if empty(s:ctx['query'])
            call popup_hide(s:subwinid)
        else
            call popup_show(s:subwinid)
            call popup_settext(s:subwinid, ' ' .. s:ctx['query'] .. ' ')
        endif
    endfunction

    function! s:update_lines(winid) abort
        let bnr = winbufnr(a:winid)
        let lnum = 0
        let xs = []
        let maxlen = 0
        let lines = []
        try
            silent! call deletebufline(bnr, 1, '$')
            for path in s:ctx['lines'] + get(s:ctx['lsfiles_caches'], s:ctx['rootdir'], [])
                if -1 == index(lines, path)
                    let lines += [path]
                    let fname = fnamemodify(path, ':t')
                    let dir = fnamemodify(path, ':h')
                    if empty(s:ctx['query']) || (fname =~ s:ctx['query'])
                        let xs += [[fname, dir]]
                        if maxlen < len(fname)
                            let maxlen = len(fname)
                        endif
                    endif
                endif
            endfor

            for x in xs
                let lnum += 1
                let d = strdisplaywidth(x[0]) - len(split(x[0], '\zs'))
                call setbufline(bnr, lnum, printf('%-' .. (maxlen + d) .. 's [%s]', x[0], x[1]))
            endfor
        catch
            echohl Error
            echo v:exception
            echohl None
        endtry

        call win_execute(a:winid, 'call clearmatches()')
        if !empty(s:ctx['query'])
            try
                call win_execute(a:winid, 'call matchadd(' .. string('IncSearch') .. ', "\\c" .. ' .. string(s:ctx['query']) .. ' .. "\\ze.*\\[.*\\]$")')
            catch
            endtry
        endif

        call s:update_title(a:winid)
        call s:set_cursorline(a:winid, 1)
    endfunction

    function! s:set_cursorline(winid, lnum) abort
        call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
        call win_execute(a:winid, 'redraw')
    endfunction

    function! s:job_callback(winid, lines, ch, msg) abort
        call s:extend_line(a:lines, s:ctx['rootdir'] .. '/' .. a:msg)
    endfunction

    function! s:job_exit_cb(winid, ch, msg) abort
        call s:update_lines(a:winid)
        call s:update_title(a:winid)
    endfunction

    function! s:get_popupwin_options_main() abort
        let width = 120
        let height = 20
        let subwindow_height = 3
        let d = 0
        if has('tabsidebar')
            if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
                let d = &tabsidebarcolumns
            endif
        endif
        if &columns - d < width
            let width = &columns - d
        endif
        if &lines - &cmdheight - subwindow_height < height
            let height = &lines - &cmdheight - subwindow_height
        endif
        let width -= 2
        let height -= 4
        if width < 4
            let width = 4
        endif
        if height < 4
            let height = 4
        endif
        let opts = {
            \ 'wrap': 0,
            \ 'scrollbar': 0,
            \ 'minwidth': width, 'maxwidth': width,
            \ 'minheight': height, 'maxheight': height,
            \ 'pos': 'center',
            \ }
        return s:apply_popupwin_border(opts)
    endfunction

    function! s:get_popupwin_options_sub(main_winid) abort
        let pos = popup_getpos(a:main_winid)
        let opts = {
            \ 'line': pos['line'] - 3,
            \ 'col': pos['col'],
            \ 'width': pos['width'] - 2,
            \ 'minwidth': pos['width'] - 2,
            \ 'title': ' SEARCH TEXT ',
            \ }
        return s:apply_popupwin_border(opts)
    endfunction

    function! s:apply_popupwin_border(opts) abort
        if has('gui_running') || (!has('win32') && !has('gui_running'))
            " ┌──┐
            " │  │
            " └──┘
            const borderchars_typeA = [
                \ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
                \ nr2char(0x250c), nr2char(0x2510), nr2char(0x2518), nr2char(0x2514)]
            " ╭──╮
            " │  │
            " ╰──╯
            const borderchars_typeB = [
                \ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
                \ nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)]
            call extend(a:opts, {
                \ 'highlight': 'Normal',
                \ 'border': [],
                \ 'padding': [0, 0, 0, 0],
                \ 'borderhighlight': repeat(['PopupBorder'], 4),
                \ 'borderchars': borderchars_typeA,
                \ }, 'force')
        endif
        return a:opts
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

    function! s:open_file(path, lnum) abort
        if s:can_open_in_current()
            echo printf('edit %s', fnameescape(a:path))
            execute printf('edit %s', fnameescape(a:path))
        else
            execute printf('new %s', fnameescape(a:path))
        endif
        if 0 < a:lnum
            call cursor([a:lnum, 1])
        endif
    endfunction

    function! s:popup_callback(winid, result) abort
        if -1 != a:result
            let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
            let m = matchlist(line, '^\(.\+\)\[\(.\+\)\]$')
            if !empty(m)
                let path = expand(m[2] .. '/' .. trim(m[1]))
                if filereadable(path)
                    call s:open_file(path, -1)
                endif
            endif
        endif
        if -1 != s:subwinid
            call popup_close(s:subwinid)
            let s:subwinid = -1
        endif
    endfunction

    function! s:read_mrwfile() abort
        let path = s:fix_path(s:ff_mrw_path)
        if filereadable(path)
            return readfile(path)
        else
            return []
        endif
    endfunction

    function! s:create_context(winid, force) abort
        let s:ctx = get(s:, 'ctx', {
            \ 'lines': [],
            \ 'lsfiles_caches': {},
            \ 'rootdir': '',
            \ 'query': '',
            \ })

        let s:ctx['lines'] = []
        let s:ctx['rootdir'] = gitdiff#get_rootdir()

        for path in s:read_mrwfile()
            call s:extend_line(s:ctx['lines'], path)
        endfor

        for path in map(getbufinfo(), { i,x -> x['name'] })
            call s:extend_line(s:ctx['lines'], path)
        endfor

        if exists('*getscriptinfo')
            for path in map(getscriptinfo(), { i,x -> x['name'] })
                call s:extend_line(s:ctx['lines'], path)
            endfor
        endif

        if a:force || isdirectory(s:ctx['rootdir']) && executable('git')
            if !has_key(s:ctx['lsfiles_caches'], s:ctx['rootdir'])
                if get(s:, 'gitls_job', v:null) != v:null
                    call job_stop(s:gitls_job)
                    let s:gitls_job = v:null
                endif
                let s:ctx['lsfiles_caches'][s:ctx['rootdir']] = []
                let s:gitls_job = job_start(['git', '--no-pager', 'ls-files'], {
                    \ 'callback': function('s:job_callback', [a:winid, s:ctx['lsfiles_caches'][s:ctx['rootdir']]]),
                    \ 'exit_cb': function('s:job_exit_cb', [a:winid]),
                    \ 'cwd': s:ctx['rootdir'],
                    \ })
            endif
        endif
    endfunction

    function! s:extend_line(lines, path) abort
        let path = s:fix_path(a:path)
        if -1 == index(a:lines, path)
            if filereadable(path)
                call extend(a:lines, [path])
            endif
        endif
    endfunction
endif
