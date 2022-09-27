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



set VIMWINDIR=%USERPROFILE%\vim-on-windows
pushd %VIMWINDIR%
    git pull
    copy /Y     "%VIMDIR%\src\gvim.exe" "%VIMWINDIR%"
    copy /Y     "%VIMDIR%\src\vim.exe"  "%VIMWINDIR%"
    rmdir /S /Q                         "%VIMWINDIR%\runtime"
    mkdir                               "%VIMWINDIR%\runtime"
    xcopy /S    "%VIMDIR%\runtime"      "%VIMWINDIR%\runtime"
    git add .
    git commit -m "update vim"
    git push -u origin master
popd



:finished
popd
taskkill /F /IM ssh-agent.exe
pause
exit /b
