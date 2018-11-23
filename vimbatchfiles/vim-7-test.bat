@echo off
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat yes
pushd %VIMDIR%
    pushd .\src\testdir
        nmake -f Make_dos.mak VIMPROG=..\gvim clean
        nmake -f Make_dos.mak VIMPROG=..\gvim
    popd
popd
pause
endlocal
