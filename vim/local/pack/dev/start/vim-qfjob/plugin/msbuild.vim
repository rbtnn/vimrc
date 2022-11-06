
let g:loaded_msbuild = 1

if has('win32') && executable('msbuild')
	let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

	command! -complete=customlist,MSBuildRunTaskComp -nargs=* MSBuildRunTask    :call MSBuildRunTask(eval(g:msbuild_projectfile), <q-args>)
	command!                                         -nargs=1 MSBuildNewProject :call MSBuildNewProject(<q-args>)

	function! MSBuildRunTask(projectfile, args) abort
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
		call qfjob#start('msbuild', cmd, function('s:line_parser', [a:projectfile]))
	endfunction

	function s:line_parser(projectfile, line) abort
		let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
		if !empty(m)
			let path = m[1]
			if !filereadable(path) && (path !~# '^[A-Z]:')
				let path = expand(fnamemodify(a:projectfile, ':h') .. '/' .. m[1])
			endif
			return qfjob#match(path, m[2], m[3], m[4])
		else
			return qfjob#do_not_match(a:line)
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

	function! MSBuildNewProject(q_args) abort
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

