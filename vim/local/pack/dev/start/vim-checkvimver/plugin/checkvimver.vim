
let g:loaded_checkvimver = 1

command! -nargs=0 CheckVimVer :call s:main()

function! s:get_ver(url) abort
	let f = v:false
	for line in split(system('curl ' .. a:url), "\n")
		if line =~# 'static int included_patches'
			let f = v:true
		elseif f 
			let m = matchlist(line, '^\s*\(\d\+\),$')
			if !empty(m)
				return str2nr(m[1])
			endif
		endif
	endfor
	return 0
endfunction

function! s:sub(str, ver1, ver2) abort
	echon a:str
	if a:ver1 > a:ver2
		echohl Directory
	else
		echohl None
	endif
	echon printf('%d.%d.%d', v:version / 100, v:version % 100, a:ver2)
	echohl None
endfunction

function! s:main() abort
	let ver1 = s:get_ver('https://raw.githubusercontent.com/vim/vim/master/src/version.c')
	let ver2 = s:get_ver('https://raw.githubusercontent.com/rbtnn/vim/tabsidebar/src/version.c')
	let curr = v:versionlong % 10000
	call s:sub('vim/vim(master): ', ver1, ver1)
	call s:sub(', rbtnn/vim(tabsidebar): ', ver1, ver2)
	call s:sub(', current: ', ver1, curr)
endfunction

