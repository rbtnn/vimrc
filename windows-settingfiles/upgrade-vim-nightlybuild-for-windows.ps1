if (0 -ne (Get-Process -Name gvim -ErrorAction Ignore).Length){
    Write-Error "gvim.exe�v���Z�X���N�����ł��B"
    Exit
}

$url = 'https://github.com/rbtnn/vim-nightlybuild-for-windows/releases/latest'
Write-Host ($url + "���擾���Ă��܂��B")
$res = Invoke-WebRequest $url -UseBasicParsing -Headers @{ "Accept" = "application/json" }
$tag_name = (ConvertFrom-Json $res).tag_name
if (-not $tag_name){
    Write-Error ($url + "����tag_name�̎擾�Ɏ��s���܂����B")
    Exit
}

$zipname = 'vim-nightlybuild-for-windows-' + $tag_name
if (-not (Test-Path ($zipname + '.zip'))){
    $url = 'https://github.com/rbtnn/vim-nightlybuild-for-windows/releases/download/' + $tag_name + '/vim-nightlybuild-for-windows.zip'
    Write-Host ($url + "���擾���Ă��܂��B")
    Invoke-WebRequest $url -UseBasicParsing -OutFile ($zipname + '.zip')
}

Write-Host ($zipname + '.zip' + "���𓀂��Ă��܂��B")
if (Test-Path $zipname){
    Remove-Item -Recurse $zipname
}
Expand-Archive ($zipname + '.zip')

$src = $zipname + '/vim-nightlybuild-for-windows'
$dest = $env:USERPROFILE + '/vim-nightlybuild-for-windows'
Write-Host ($dest + "���X�V���Ă��܂��B")
if (Test-Path $dest){
    Remove-Item -Recurse $dest
}
Move-item -Path $src -Destination $dest
Remove-Item $zipname

Write-Host "Vim�̍X�V���������܂����B"
