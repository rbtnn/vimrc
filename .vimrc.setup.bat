@echo off
set CUR_DIR=%~dp0
set PLUGIN_DIR=%CUR_DIR%\.vim\pack\my\start

if not exist "%PLUGIN_DIR%" (
   	mkdir "%PLUGIN_DIR%"
)

call :PLUG kana    vim-operator-replace
call :PLUG kana    vim-operator-user
call :PLUG rbtnn   vim-diffy
call :PLUG rbtnn   vim-gloaded
call :PLUG rbtnn   vim-near
call :PLUG rbtnn   vim-vimscript_indentexpr
call :PLUG rbtnn   vim-vimscript_lasterror
call :PLUG rbtnn   vim-vimscript_tagfunc
call :PLUG sjl     badwolf
call :PLUG thinca  vim-qfreplace
call :PLUG tyru    restart.vim

exit /b

:PLUG
set USER=%1
set NAME=%2
@echo --- %USER%\%NAME% ---
if exist "%PLUGIN_DIR%\%NAME%" (
	pushd "%PLUGIN_DIR%\%NAME%"
		git pull
	popd
) else (
	pushd "%PLUGIN_DIR%"
		git clone --depth 1 https://github.com/%USER%/%NAME%.git
	popd
)
@echo;
exit /b

