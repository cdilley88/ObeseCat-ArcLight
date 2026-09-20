param([string]$Godot, [string]$Template = 'G:\ObeseCat Meltdown\.godot\portable-data\Godot\export_templates\4.7.2.stable\windows_release_x86_32.exe')
$ErrorActionPreference = 'Stop'
if (-not $Godot) { $Godot = Join-Path $env:TEMP 'obesecat-godot\Godot_v4.7.2-stable_win64_console.exe' }
if (-not (Test-Path -LiteralPath $Godot)) { throw 'Pass -Godot with your installed Godot 4 executable.' }
$output = Join-Path $PSScriptRoot 'builds\windows'
New-Item -ItemType Directory -Force $output | Out-Null
$oldAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $PSScriptRoot 'prototype\.godot\portable-data'
    $templateDir = Join-Path $env:APPDATA 'Godot\export_templates\4.7.2.stable'
    $localTemplate = Join-Path $templateDir 'windows_release_x86_32.exe'
    if (-not (Test-Path -LiteralPath $localTemplate)) {
        if (-not (Test-Path -LiteralPath $Template)) { throw 'Pass -Template with the Godot 4.7.2 Windows x86_32 release export template.' }
        New-Item -ItemType Directory -Force $templateDir | Out-Null
        Copy-Item -LiteralPath $Template -Destination $localTemplate
    }
    & $Godot --headless --path (Join-Path $PSScriptRoot 'prototype') --export-release 'Windows Desktop' (Join-Path $output 'ObeseCat-ArcLight-0.14.exe')
    if ($LASTEXITCODE -ne 0) { throw 'Windows export failed.' }
    Write-Output "Playable build: $output\ObeseCat-ArcLight-0.14.exe"
} finally { $env:APPDATA = $oldAppData }
