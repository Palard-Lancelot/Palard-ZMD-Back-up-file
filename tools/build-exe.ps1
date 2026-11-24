# ============================================================
#  Palard-ZMD 一键打包 Windows exe
#  用法: powershell -NoProfile -ExecutionPolicy Bypass -File build-exe.ps1
#
#  前置条件：
#    已安装 4.7.2 导出模板
#    → %APPDATA%\Godot\export_templates\4.7.2.stable\
#    （安装记录见 Documents/reference/GODOT_INSTALL_NOTES.md）
#
#  产物：
#    project\build\windows\Palard.zmd.exe
#    单文件，PCK 已内嵌，拷走即可运行
#
#  build\ 与 export_presets.cfg 都在 .gitignore 里，不会污染仓库。
# ============================================================

$ErrorActionPreference = 'Continue'

$ROOT    = Split-Path -Parent $PSScriptRoot
$PROJDIR = Join-Path $ROOT 'project'
$GODOT   = Join-Path $env:LOCALAPPDATA 'Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe'

$TPL_VER = '4.7.2.stable'
$TPL_DIR  = Join-Path $env:APPDATA ('Godot\export_templates\' + $TPL_VER)
$PRESET  = Join-Path $PROJDIR 'export_presets.cfg'
$OUTDIR  = Join-Path $PROJDIR 'build\windows'
$OUTEXE  = Join-Path $OUTDIR 'Palard.zmd.exe'

function Fail([string]$msg) {
    Write-Host ''
    Write-Host ('[ERROR] ' + $msg) -ForegroundColor Red
    Write-Host ''
    exit 1
}

# ---- 前置检查 ----
if (-not (Test-Path $GODOT)) {
    Fail ('找不到 Godot: ' + $GODOT + '  （改本脚本顶部的 $GODOT，或看 GODOT_INSTALL_NOTES.md）')
}
if (-not (Test-Path (Join-Path $PROJDIR 'project.godot'))) {
    Fail ('找不到项目: ' + $PROJDIR)
}
if (-not (Test-Path (Join-Path $TPL_DIR 'version.txt'))) {
    Fail ('导出模板未安装，期望目录: ' + $TPL_DIR + '  安装方法见 Documents/reference/GODOT_INSTALL_NOTES.md')
}
if (-not (Test-Path $PRESET)) {
    Fail ('缺少导出预设: ' + $PRESET + '   （在 Godot 编辑器里 项目→导出→添加 Windows Desktop 即可生成）')
}

$tplVersion = (Get-Content (Join-Path $TPL_DIR 'version.txt') -Raw).Trim()
if ($tplVersion -ne $TPL_VER) {
    Fail ('导出模板版本不匹配: 目录里是 ' + $tplVersion + '，期望 ' + $TPL_VER)
}

Write-Host ''
Write-Host ('=' * 62)
Write-Host '  Palard-ZMD 打包 Windows exe'
Write-Host ('=' * 62)
Write-Host ('  项目  : ' + $PROJDIR)
Write-Host ('  引擎  : ' + (Split-Path $GODOT -Leaf))
Write-Host ('  模板  : ' + $TPL_VER)
Write-Host ''

# ---- 导出 ----
if (-not (Test-Path $OUTDIR)) {
    New-Item -ItemType Directory -Force -Path $OUTDIR | Out-Null
}
# 先删旧产物：导出失败时不会留下旧 exe 冒充新包
if (Test-Path $OUTEXE) { Remove-Item $OUTEXE -Force }

Write-Host '  正在导出（release）...'
Push-Location $PROJDIR
$out = & $GODOT --headless --path . --export-release 'Windows Desktop' $OUTEXE 2>&1 | Out-String
Pop-Location

# 只显示错误行，正常导出日志太长
$errLines = $out -split "`r?`n" | Where-Object { $_ -match 'ERROR|error:|失败' }
if ($errLines) {
    Write-Host '  导出日志中的异常行:'
    foreach ($l in $errLines) { Write-Host ('    ' + $l) }
}

if (-not (Test-Path $OUTEXE)) {
    Fail '导出失败 —— 没有生成 exe。上面若有 ERROR 行，先看第一条。'
}

$f = Get-Item $OUTEXE
Write-Host ''
Write-Host ('  [OK] ' + $f.FullName)
Write-Host ('       大小 ' + [math]::Round($f.Length / 1MB, 1) + ' MB   修改时间 ' + $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))
Write-Host ''
Write-Host '  发给试玩者：只需拷贝这一个 exe，无需安装 Godot。'
Write-Host ''
