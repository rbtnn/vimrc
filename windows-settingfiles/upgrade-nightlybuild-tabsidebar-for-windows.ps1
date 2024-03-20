if (0 -ne (Get-Process -Name gvim -ErrorAction Ignore).Length){
    Write-Error "gvim.exeプロセスが起動中です。"
    Exit
}

$url = 'https://github.com/rbtnn/nightlybuild-tabsidebar-for-windows/releases/latest'
Write-Host ($url + "を取得しています。")
$res = Invoke-WebRequest $url -UseBasicParsing -Headers @{ "Accept" = "application/json" }
$tag_name = (ConvertFrom-Json $res).tag_name
if (-not $tag_name){
    Write-Error ($url + "からtag_nameの取得に失敗しました。")
    Exit
}

$zipname = 'nightlybuild-tabsidebar-for-windows-' + $tag_name
if (-not (Test-Path ($zipname + '.zip'))){
    $url = 'https://github.com/rbtnn/nightlybuild-tabsidebar-for-windows/releases/download/' + $tag_name + '/nightlybuild-tabsidebar-for-windows.zip'
    Write-Host ($url + "を取得しています。")
    Invoke-WebRequest $url -UseBasicParsing -OutFile ($zipname + '.zip')
}

Write-Host ($zipname + '.zip' + "を解凍しています。")
if (Test-Path $zipname){
    Remove-Item -Recurse $zipname
}
Expand-Archive ($zipname + '.zip')

$src = $zipname + '/nightlybuild-tabsidebar-for-windows'
$dest = $env:USERPROFILE + '/nightlybuild-tabsidebar-for-windows'
Write-Host ($dest + "を更新しています。")
if (Test-Path $dest){
    Remove-Item -Recurse $dest
}
Move-item -Path $src -Destination $dest
Remove-Item $zipname

Write-Host "Vimの更新が完了しました。"
