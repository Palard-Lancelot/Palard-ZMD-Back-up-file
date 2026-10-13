# ============================================================
#  Palard-ZMD 测试总入口
#  用法: powershell -NoProfile -ExecutionPolicy Bypass -File run-tests.ps1
#
#  一次跑完全部测试套件，并汇总结果。
#  只读脚本，不修改项目文件。
# ============================================================

$ErrorActionPreference = 'Continue'

$ROOT = Split-Path -Parent $PSScriptRoot
$PROJDIR = Join-Path $ROOT 'project'
$GODOT = Join-Path $env:LOCALAPPDATA 'Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe'

if (-not (Test-Path $GODOT)) {
    Write-Host "[ERROR] 找不到 Godot: $GODOT"
    Write-Host "        检查 GODOT 版本或修改本脚本顶部的路径。"
    exit 1
}
if (-not (Test-Path (Join-Path $PROJDIR 'project.godot'))) {
    Write-Host "[ERROR] 找不到项目: $PROJDIR"
    exit 1
}

Write-Host ''
Write-Host ('=' * 62)
Write-Host '  Palard-ZMD 测试套件'
Write-Host ('=' * 62)
Write-Host ("  项目: " + $PROJDIR)
Write-Host ("  引擎: " + (Split-Path $GODOT -Leaf))
Write-Host ''

# 部分测试需要以 boot.tscn 为依赖加载，必须跳过 boot 的 headless 自检退出
$env:DSH_SKIP_BOOT_QUIT = '1'

$suites = @(
    @{ name = '键位绑定';   script = 'res://tests/test_input_map.gd' },
    @{ name = '移动物理';   script = 'res://tests/test_movement.gd' },
    @{ name = '攻击系统';   script = 'res://tests/test_attack.gd' },
    @{ name = '冲刺与受击'; script = 'res://tests/test_dash_hurt.gd' },
    @{ name = '相机跟随';   script = 'res://tests/test_camera.gd' },
    @{ name = '敌人攻击';   script = 'res://tests/test_enemy_attack.gd' }
)

$summary = @()
$allPass = $true

foreach ($s in $suites) {
    Write-Host ('-' * 62)
    Write-Host ('  [' + $s.name + '] ' + $s.script)
    Write-Host ('-' * 62)

    Push-Location $PROJDIR
    $out = & $GODOT --headless --path . --script $s.script 2>&1 | Out-String
    $code = $LASTEXITCODE
    Pop-Location

    # 只打印测试自身的输出行
    $lines = $out -split "`r?`n" | Where-Object { $_ -match '^\[TEST\]' }
    foreach ($l in $lines) { Write-Host ('  ' + $l) }

    # 解析结果行
    $result = '未识别'
    foreach ($l in $lines) {
        if ($l -match '结果:\s*(\d+)\s*/\s*(\d+)\s*通过') {
            $result = $Matches[1] + '/' + $Matches[2]
        }
    }
    $failed = ($out -match '✗|FAIL')
    if ($failed -or $code -ne 0) { $allPass = $false }

    $summary += [pscustomobject]@{
        套件   = $s.name
        结果   = $result
        退出码 = $code
    }
    Write-Host ''
}

Write-Host ('=' * 62)
Write-Host '  汇总'
Write-Host ('=' * 62)
$summary | Format-Table -AutoSize | Out-String | Write-Host

if ($allPass) {
    Write-Host '  ★ 全部测试通过'
} else {
    Write-Host '  ✗ 存在失败项 —— 见上方输出'
}
Write-Host ('=' * 62)
Write-Host ''

$env:DSH_SKIP_BOOT_QUIT = $null
exit (0)
