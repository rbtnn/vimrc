@echo on
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat
pushd %VIMDIR%
    git po tabsidebar
    git po clpum_and_tabsidebar
popd
pause
endlocal
