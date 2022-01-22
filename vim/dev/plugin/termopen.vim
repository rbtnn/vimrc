
"function! s:term_win_open() abort
"	if (bufname() =~# '\<cmd\.exe\>') && has('win32')
"		" https://en.wikipedia.org/wiki/Windows_10_version_history
"		" https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc725943(v=ws.11)
"		" https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
"		let s:vcvarsall_path = glob('C:\Program Files (x86)\Microsoft Visual Studio\2019\*\VC\Auxiliary\Build\vcvarsall.bat')
"		let s:initcmd_path = get(s:, 'initcmd_path', tempname() .. '.cmd')
"		let s:windows_build_number = get(s:, 'windows_build_number', -1)
"		let s:win10_anniversary_update = get(s:, 'win10_anniversary_update', v:false)
"		if executable('wmic') && (-1 == s:windows_build_number)
"			let s:windows_build_number = str2nr(join(filter(split(system('wmic os get BuildNumber'), '\zs'), { i,x -> (0x30 <= char2nr(x)) && (char2nr(x) <= 0x39) }), ''))
"			let s:win10_anniversary_update = 14393 <= s:windows_build_number
"		endif
"		call writefile(map([
"			\	'@echo off', 'cls',
"			\	(s:win10_anniversary_update ? 'prompt $e[0;32m$$$e[0m' : 'prompt $$'),
"			\	'doskey vc=call "' .. s:vcvarsall_path .. '" $*',
"			\	'doskey ls=dir /b $*',
"			\	'doskey rm=del /q $*',
"			\	'doskey mv=move /y $*',
"			\	'doskey cp=copy /y $*',
"			\	'doskey pwd=cd',
"			\ ], { i,x -> x .. "\r" }), s:initcmd_path)
"		if has('nvim')
"			startinsert
"			call jobsend(b:terminal_job_id, printf("call %s\r", s:initcmd_path))
"		else
"			call term_sendkeys(bufnr(), printf("call %s\r", s:initcmd_path))
"		endif
"	endif
"	if bufname() =~# '\<bash\>'
"		let cmd = join(['export PS1="\[\e[0;32m\]$\[\e[0m\]"', 'clear', ''], "\r")
"		if has('nvim')
"			startinsert
"			call jobsend(b:terminal_job_id, cmd)
"		else
"			call term_sendkeys(bufnr(), cmd)
"		endif
"	endif
"endfunction
"
"if has('nvim')
"	autocmd vimrc TermOpen           * :silent! call s:term_win_open()
"else
"	autocmd vimrc TerminalWinOpen    * :silent! call s:term_win_open()
"endif
"if (bufname() =~# '\<cmd\.exe$') && has('win32')
"	autocmd vimrc VimLeave           * :silent! call delete(s:initcmd_path)
"endif
