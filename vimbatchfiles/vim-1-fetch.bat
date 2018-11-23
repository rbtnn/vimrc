@echo on
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat
pushd %VIMDIR%
    git remote add vim https://github.com/vim/vim.git
    git fetch vim
    git remote add clpum https://github.com/h-east/vim.git
    git fetch clpum
popd
pause
endlocal
