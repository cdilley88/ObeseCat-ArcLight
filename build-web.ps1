param([string]$Godot)
$ErrorActionPreference = 'Stop'
if (-not $Godot) { $Godot = Join-Path $env:TEMP 'obesecat-godot/Godot_v4.7.2-stable_win64_console.exe' }
$oldAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $PSScriptRoot 'prototype/.godot/portable-data'
    $output = Join-Path $PSScriptRoot 'builds/web'
    New-Item -ItemType Directory -Force (Join-Path $output 'game') | Out-Null
    & $Godot --headless --path (Join-Path $PSScriptRoot 'prototype') --export-release Web (Join-Path $output 'game/index.html')
    if ($LASTEXITCODE -ne 0) { throw 'Web export failed.' }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'web/index.html') -Destination (Join-Path $output 'index.html') -Force
    Write-Output "Browser build: $output"
} finally { $env:APPDATA = $oldAppData }
