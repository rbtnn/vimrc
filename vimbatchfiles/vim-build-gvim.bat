@echo off
setlocal enabledelayedexpansion
call %~dp0vim-setup.bat yes
pushd %VIMDIR%
    pushd .\src
    	copy /y config.mk.dist auto\config.mk
        nmake -f Makefile cmdidxs
        nmake -f Make_mvc.mak %OPT1% %OPT2% %OPT3% FEATURES=HUGE GUI=yes %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
    popd
popd
if exist pause ( pause )
endlocal
