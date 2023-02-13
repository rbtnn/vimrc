
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
set list listchars=tab:\ \ \|,trail:-
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

if has('win32')
    let g:vimrc_vcvarsall_batpath = get(g:, 'vimrc_vcvarsall_batpath', 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat')
    function! s:TerminalWithVcvarsall(q_args) abort
        call term_start(['cmd.exe', '/nologo', '/k', g:vimrc_vcvarsall_batpath, empty(a:q_args) ? 'x86' : a:q_args], {
            \ })
    endfunction
    if filereadable(g:vimrc_vcvarsall_batpath)
        command! -nargs=?     TerminalWithVcvarsall           :call s:TerminalWithVcvarsall(<q-args>)
    endif
endif

if s:is_installed('rbtnn/vim-textobj-string')
    nmap <silent>ds das
    nmap <silent>ys yas
    nmap <silent>vs vas
endif

if s:is_installed('kana/vim-operator-replace')
    nmap <silent>s   <Plug>(operator-replace)
    nmap <silent>ss  <Plug>(operator-replace)as
endif

if s:is_installed('haya14busa/vim-operator-flashy')
    map  <silent>y   <Plug>(operator-flashy)
    nmap <silent>Y   <Plug>(operator-flashy)$
endif

if s:is_installed('rbtnn/vim-lsfiles')
    nnoremap <silent><space>  <Cmd>LsFiles<cr>
endif

if s:is_installed('rbtnn/vim-gitdiff')
    nnoremap <silent><C-s>    <Cmd>execute 'GitDiffNumStat' get(g:, 'gitdiff_args', '-w')<cr>
endif

if s:is_installed('rbtnn/vim-qfjob')
    command! -nargs=*                                           GitGrep           :call s:gitgrep(<q-args>)
    command! -nargs=*                                           RipGrep           :call s:ripgrep(<q-args>)

    if has('win32') && executable('msbuild')
        command! -complete=customlist,MSBuildRunTaskComp -nargs=* MSBuildRunTask      :call s:msbuild_runtask(eval(g:msbuild_projectfile), <q-args>)
        command!                                         -nargs=1 MSBuildNewProjectCS :call s:msbuild_newproject('cs', <q-args>)
        command!                                         -nargs=1 MSBuildNewProjectVB :call s:msbuild_newproject('vb', <q-args>)
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
        if has('win32') && exists('g:loaded_qficonv') && (len(a:text) < 500)
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

    function! s:msbuild_newproject(ext, q_args) abort
        const projectname = trim(a:q_args)
        if isdirectory(projectname)
            echohl Error
            echo   'The directory already exists: ' .. string(projectname)
            echohl None
        elseif projectname =~# '^[a-zA-Z0-9_-]\+$'
            call mkdir(expand(projectname .. '/src'), 'p')
            if 'cs' == a:ext
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
            else
                call writefile([
                    \   "Imports System",
                    \   "Imports System.IO",
                    \   "Imports System.Text",
                    \   "Imports System.Text.RegularExpressions",
                    \   "Imports System.Collections.Generic",
                    \   "Imports System.Linq",
                    \   "",
                    \   "Module Prog",
                    \   "\tSub Main()",
                    \   "\t\tCall Console.WriteLine(\"Hello\")",
                    \   "\tEnd Sub",
                    \   "End Module",
                    \ ], expand(projectname .. '/src/Main.vb'))
            endif
            call writefile([
                \   "<Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">",
                \   "\t<PropertyGroup>",
                \   "\t\t<AssemblyName>Main.exe</AssemblyName>",
                \   "\t\t<OutputPath>bin\\</OutputPath>",
                \   "\t\t<OutputType>exe</OutputType>",
                \   "\t\t<References></References>",
                \   "\t</PropertyGroup>",
                \   "\t<ItemGroup>",
                \   "\t\t<Compile Include=\"src\\*." .. a:ext .. "\" />",
                \   "\t</ItemGroup>",
                \   "\t<Target Name=\"Build\">",
                \   "\t\t<MakeDir Directories=\"$(OutputPath)\" Condition=\"!Exists('$(OutputPath)')\" />",
                \   "\t\t<" .. (a:ext == 'cs' ? 'Csc' : 'Vbc'),
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
            \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
            \ | highlight!       TabSideBarLabel          guifg=#66d9ff guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
            \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
            \ | highlight!       LsFilesPopupBorder       guifg=#66d9ff guibg=NONE
            \ | highlight!       SpecialKey               guifg=#223344 guibg=NONE
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
            let rest = 0
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
            let high1 = (current ? '%#TabSideBarSel#' : '%#TabSideBar#')
            let high2 = '%#TabSideBarModified#'
            let fname = fnamemodify(bufname(x['bufnr']), ':t')
            let lines += [
                \    high1
                \ .. ' '
                \ .. (!empty(bt)
                \      ? printf('[%s]', bt == 'nofile' ? ft : bt)
                \      : (empty(bufname(x['bufnr']))
                \          ? '[No Name]'
                \          : fname))
                \ .. high2
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
