param([string]$Godot, [switch]$Test, [switch]$Editor)
$ErrorActionPreference = 'Stop'
$projectRoot = Join-Path $PSScriptRoot 'prototype'
if (-not $Godot) {
    $Godot = Join-Path $env:TEMP 'obesecat-godot\Godot_v4.7.2-stable_win64_console.exe'
    if (-not (Test-Path -LiteralPath $Godot)) {
        $available = Get-Command godot -ErrorAction SilentlyContinue
        if ($available) { $Godot = $available.Source }
    }
}
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) { throw 'Pass -Godot with the path to an installed Godot 4 executable.' }
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
try {
$env:APPDATA = Join-Path $projectRoot '.godot\portable-data'
$env:LOCALAPPDATA = Join-Path $projectRoot '.godot\portable-cache'
if ($Test) {
    & $Godot --headless --path $projectRoot --editor --import --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
    & $Godot --headless --path $projectRoot --script res://tests/test_demo.gd
    if ($LASTEXITCODE -ne 0) { throw "Core rule checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_hub.gd
    if ($LASTEXITCODE -ne 0) { throw "Hub checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_tower.gd
    if ($LASTEXITCODE -ne 0) { throw "Tower checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_supplies.gd
    if ($LASTEXITCODE -ne 0) { throw "Supply checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_rewards.gd
    if ($LASTEXITCODE -ne 0) { throw "Reward checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_arena.gd
    if ($LASTEXITCODE -ne 0) { throw "Arena checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_salvage_expansion.gd
    if ($LASTEXITCODE -ne 0) { throw "Expanded salvage checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_world_seed.gd
    if ($LASTEXITCODE -ne 0) { throw "World seed checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_arclight.gd
    if ($LASTEXITCODE -ne 0) { throw "ArcLight checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_draconic.gd
    if ($LASTEXITCODE -ne 0) { throw "Draconic checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_save.gd
    if ($LASTEXITCODE -ne 0) { throw "Save system checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_title.gd
    if ($LASTEXITCODE -ne 0) { throw "Title and opening checks failed." }
    & $Godot --headless --path $projectRoot --script res://tests/test_skills.gd
    if ($LASTEXITCODE -ne 0) { throw "Skills and controls checks failed." }
} elseif ($Editor) {
    & $Godot --path $projectRoot --editor
} else {
    & $Godot --path $projectRoot
}
if ($LASTEXITCODE -ne 0) { throw "Godot exited with code $LASTEXITCODE" }
} finally {
    $env:APPDATA = $oldAppData
    $env:LOCALAPPDATA = $oldLocalAppData
}
