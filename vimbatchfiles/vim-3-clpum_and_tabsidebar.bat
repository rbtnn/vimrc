@echo on
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat
pushd %VIMDIR%
    git co clpum_and_tabsidebar
    git pull
    git merge clpum/clpum
    git merge tabsidebar
popd
pause
endlocal
