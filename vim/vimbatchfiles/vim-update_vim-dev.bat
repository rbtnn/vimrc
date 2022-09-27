setlocal enabledelayedexpansion
@echo on

if "%USERPROFILE%" == "" goto :finished

set PATH=%SystemRoot%
set PATH=%PATH%;%SystemRoot%\System32
set PATH=%PATH%;%SystemRoot%\System32\Wbem
rem for git.exe
set PATH=%PATH%;C:\Program Files\Git\bin
rem for diff.exe
set PATH=%PATH%;C:\Program Files\Git\usr\bin

set VIMDIR=%USERPROFILE%\Desktop\vim

taskkill /F /IM ssh-agent.exe
for /f "tokens=1-2 delims==;" %%a in ('ssh-agent.exe') do (
    if not [%%b] == [] @set %%a=%%b
)
ssh-add.exe



pushd %VIMDIR%
    git fetch vim
    git checkout tabsidebar
    git pull
    git checkout runtime
    git merge vim/master
    if errorlevel 1 goto :merge_conflict
    git push -u origin tabsidebar
    call "%~dp0%vim-build_vim.bat"
    call "%~dp0%vim-build_gvim.bat"
popd



:finished
popd
taskkill /F /IM ssh-agent.exe
pause
exit /b

:merge_conflict
popd
taskkill /F /IM ssh-agent.exe
pause
exit /b
