# ============================================================
#  Palard-ZMD 项目巡检（READ-ONLY）
#  用法: powershell -NoProfile -ExecutionPolicy Bypass -File check-progress.ps1
#  本脚本只读，不修改任何项目文件。
#  本文件保存为 UTF-8 with BOM。原因是 Windows PowerShell 5.1 会把无 BOM 的 UTF-8 当成 GBK 解析，导致中文注释/字符串乱码甚至语法错误。
# ============================================================

$ErrorActionPreference = 'Continue'

# ---- 路径配置（换机器只需改这一段）----
$ROOT   = Split-Path -Parent $PSScriptRoot        # 项目根 = tools 的上一级
$PROJDIR   = Join-Path $ROOT 'project'
$DOCS   = Join-Path $ROOT 'Documents'
$DESIGN = Join-Path $DOCS 'design\DESIGN.md'
$LEDGER = Join-Path $DOCS 'design\PROGRESS.md'

$ENC = New-Object System.Text.UTF8Encoding($false)

function Line([string]$s) { Write-Host $s }
function Head([string]$s) {
    Write-Host ''
    Write-Host ('=' * 64)
    Write-Host ('  ' + $s)
    Write-Host ('=' * 64)
}

$today = Get-Date
Line ('Inspection time : ' + $today.ToString('yyyy-MM-dd HH:mm'))
Line ('Project root    : ' + $ROOT)
Line ('Godot project   : ' + $PROJDIR)

# ---------- 1. key documents ----------
Head '1. AUTHORITATIVE DOCUMENTS'

$docs = @(
    @{ p = $DESIGN;                                          need = $true;  desc = 'design source of truth' },
    @{ p = $LEDGER;                                          need = $true;  desc = 'progress ledger' },
    @{ p = (Join-Path $DOCS 'reference\feel-spec-deadcells.md');         need = $false; desc = 'feel spec baseline' },
    @{ p = (Join-Path $DOCS 'reference\plan-20weeks-solo.md');           need = $false; desc = 'early schedule (ref)' },
    @{ p = (Join-Path $DOCS 'reference\game-design-pillar-template.md'); need = $false; desc = 'blank template' }
)
foreach ($d in $docs) {
    $name = Split-Path $d.p -Leaf
    if (Test-Path $d.p) {
        $i   = Get-Item $d.p
        $age = [int]($today - $i.LastWriteTime).TotalDays
        Line ('  [OK]   {0,-32} {1,6} KB  {2,4} d ago  ({3})' -f $name, [math]::Round($i.Length/1KB,1), $age, $d.desc)
    } else {
        $flag = '[MISS]'
        if (-not $d.need) { $flag = '[ -- ]' }
        Line ('  {0} {1,-32} MISSING     ({2})' -f $flag, $name, $d.desc)
    }
}

# ---------- 2. Godot project output ----------
Head '2. GODOT PROJECT OUTPUT'

$hasProj = Test-Path $PROJDIR
if (-not $hasProj) {
    Line '  [!] project dir does not exist: ' + $PROJDIR
    Line '      -> Phase 0 has not started'
} else {
    $all = Get-ChildItem $PROJDIR -Recurse -File -ErrorAction SilentlyContinue |
           Where-Object { $_.FullName -notlike '*\.godot\*' }
    $src = $all | Where-Object { $_.Extension -in '.gd', '.tscn', '.tres', '.godot' }

    Line ('  total files (excl. .godot cache) : ' + $all.Count)
    Line ('  source/scene/resource files       : ' + $src.Count)

    if ($all.Count -gt 0) {
        $newest = $all | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $idle   = [int]($today - $newest.LastWriteTime).TotalDays
        Line ('  last modified                     : ' + $newest.Name + '  (' + $idle + ' d ago)')
        if ($idle -ge 14)     { Line ('  [!!]  ' + $idle + ' days idle -> STALL WARNING') }
        elseif ($idle -ge 7)  { Line ('  [!]   ' + $idle + ' days idle -> needs explanation') }
        else                  { Line '  [OK]  recent activity' }
    }

    Line ''
    Line '  by extension:'
    $all | Group-Object Extension | Sort-Object Count -Descending | ForEach-Object {
        $ext = $_.Name
        if ($ext -eq '') { $ext = '(none)' }
        Line ('    {0,-14} {1,5}' -f $ext, $_.Count)
    }

    Line ''
    Line '  .gd line counts:'
    $gd = Get-ChildItem $PROJDIR -Recurse -File -Filter *.gd -ErrorAction SilentlyContinue |
          Where-Object { $_.FullName -notlike '*\.godot\*' }
    if ($gd) {
        $total = 0
        foreach ($f in $gd) {
            $n = ([System.IO.File]::ReadAllLines($f.FullName, $ENC)).Count
            $total += $n
            Line ('    {0,-44} {1,6}' -f $f.Name, $n)
        }
        Line ('    {0,-44} {1,6}' -f '=== TOTAL ===', $total)
    } else {
        Line '    (no .gd files)'
    }

    Line ''
    Line '  Phase 0 key files:'
    $keys = @(
        @{ f = 'project.godot';            d = '0.1 project skeleton' },
        @{ f = 'feel_config.gd';           d = '0.3 FeelConfig' },
        @{ f = 'debug_panel.tscn';         d = '0.4 tuning panel' },
        @{ f = 'player.gd';                d = '0.5 player movement' },
        @{ f = 'state_machine.gd';         d = '0.6 state machine' },
        @{ f = 'hitbox.gd';                d = '0.7 attack hitbox' },
        @{ f = 'game_time.gd';             d = '0.8 hitstop/shake' },
        @{ f = 'dummy.gd';                 d = '0.7-0.8 dummy enemy' }
    )
    foreach ($k in $keys) {
        $hit = Get-ChildItem $PROJDIR -Recurse -File -Filter $k.f -ErrorAction SilentlyContinue |
               Where-Object { $_.FullName -notlike '*\.godot\*' } | Select-Object -First 1
        if ($hit) {
            Line ('    [OK]   ' + $k.d.PadRight(22) + ' ' + $hit.Name)
        } else {
            Line ('    [ -- ] ' + $k.d.PadRight(22) + ' not created')
        }
    }
}

# ---------- 3. git activity ----------
Head '3. GIT ACTIVITY'

$gitDir = Join-Path $PROJDIR '.git'
if (-not (Test-Path $gitDir)) {
    Line '  [!] project not git-initialised (cannot track output cadence)'
} else {
    Push-Location $PROJDIR
    $log = & git log --date=short --pretty=format:'%ad|%s' -n 15 2>&1
    if ($LASTEXITCODE -eq 0 -and $log) {
        $commits = @($log)
        Line ('  last ' + $commits.Count + ' commits:')
        foreach ($c in $commits) {
            $parts = $c -split '\|', 2
            Line ('    ' + $parts[0] + '  ' + $parts[1])
        }
        $lastDateStr = ($commits[0] -split '\|', 2)[0]
        try {
            $lastDate = [datetime]::ParseExact($lastDateStr, 'yyyy-MM-dd', $null)
            $idle = [int]($today - $lastDate).TotalDays
            Line ''
            Line ('  days since last commit: ' + $idle)
            if ($idle -ge 21)     { Line '  [!!!] 3+ weeks no commit -> SEVERE WARNING' }
            elseif ($idle -ge 7)  { Line '  [!]   over a week no commit' }
            else                  { Line '  [OK]  commit cadence healthy' }
        } catch { }
    } else {
        Line '  repo exists but has no commits'
    }

    Line ''
    Line '  uncommitted changes:'
    $st = & git status --porcelain 2>&1
    if ($st) {
        $sc = @($st).Count
        Line ('    ' + $sc + ' item(s) not committed')
        @($st) | Select-Object -First 8 | ForEach-Object { Line ('      ' + $_) }
        if ($sc -gt 8) { Line ('      ... and ' + ($sc - 8) + ' more') }
    } else {
        Line '    working tree clean'
    }
    Pop-Location
}

# ---------- 4. ledger ----------
Head '4. PROGRESS LEDGER'

$pf = $LEDGER
if (Test-Path $pf) {
    $age = [int]($today - (Get-Item $pf).LastWriteTime).TotalDays
    Line ('  ledger last updated: ' + $age + ' d ago')
    if ($age -ge 7) { Line '  [!] ledger not updated for over a week' }

    $pl = [System.IO.File]::ReadAllLines($pf, $ENC)
    $filled  = 0
    foreach ($l in $pl) {
        if ($l -match '^\|') {
            if ($l -match '^\|[\s\-:|]+\|$') { continue }
            $cells = @($l -split '\|')
            if ($cells.Count -ge 6) { $filled++ }
        }
    }
    Line ('  table rows detected: ' + $filled)
} else {
    Line '  [MISS] PROGRESS.md not found'
}

# ---------- 5. verdict ----------
Head '5. VERDICT'

$issues = @()
if (-not (Test-Path $DESIGN))                        { $issues += 'DESIGN.md missing' }
if (-not (Test-Path $pf))                           { $issues += 'PROGRESS.md missing' }
if (-not $hasProj) {
    $issues += 'Godot project not created (Phase 0 not started)'
} else {
    $all = Get-ChildItem $PROJDIR -Recurse -File -ErrorAction SilentlyContinue |
           Where-Object { $_.FullName -notlike '*\.godot\*' }
    if ($all.Count -le 3)  { $issues += 'project is still the smoke-test stub; Phase 0 not really started' }
    if (-not (Test-Path $gitDir)) { $issues += 'project not git-initialised' }
}

if ($issues.Count -eq 0) {
    Line '  [OK] no issues'
} else {
    Line '  action items:'
    foreach ($i in $issues) { Line ('    - ' + $i) }
}

Line ''
Line '  NOTE: this script is READ-ONLY. Run it once per weekly review.'
Line ''
