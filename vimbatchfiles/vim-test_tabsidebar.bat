@echo off
setlocal enabledelayedexpansion
call %~dp0vim-setup.bat yes
pushd %VIMDIR%
    pushd .\src\testdir
        nmake -f Make_dos.mak VIMPROG=..\gvim clean
        nmake -f Make_dos.mak VIMPROG=..\gvim test_tabsidebar.res
    popd
popd
if exist pause ( pause )
endlocal
