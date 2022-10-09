@echo off
setlocal enabledelayedexpansion

call "%~dp0\vim-common.bat" x86
if "%BUILD_ARCH%"=="" goto :FINISH
if "%BUILD_ARCH%"=="x64" set VIM_CPU=AMD64
if "%BUILD_ARCH%"=="x86" set VIM_CPU=i386

rem Add the path of diff.exe.
set PATH=%PATH%;C:\Program Files\Git\usr\bin

@echo on
pushd %TARGET_VIMDIR%\src\testdir
    if exist test.log del /Q test.log
    @echo on
    rem nmake /nologo /f Make_dos.mak VIMPROG=..\vim %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
    rem nmake /nologo /f Make_dos.mak VIMPROG=..\gvim clean newtests
    nmake /nologo /f Make_dos.mak VIMPROG=..\gvim clean test_tabsidebar.res
    if exist test.log type test.log
    @echo off
popd
@echo off

:FINISH
if exist pause ( pause )
