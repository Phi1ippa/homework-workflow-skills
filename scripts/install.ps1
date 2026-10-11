# Installs the homework workflow skills into ~/.cursor/skills.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/install.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -Uninstall
# Messages are ASCII-only so Windows PowerShell 5.1 parses this file regardless of encoding.

param(
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$names = @('homework-shared', 'hw-plan', 'hw-assign', 'hw-hint', 'hw-progress', 'hw-review', 'hw-archive')
$source = Join-Path (Split-Path -Parent $PSScriptRoot) 'skills'
$target = Join-Path $HOME '.cursor/skills'

if ($Uninstall) {
    foreach ($name in $names) {
        $dst = Join-Path $target $name
        if (Test-Path $dst) {
            Remove-Item -Recurse -Force $dst
            Write-Host "Removed $dst"
        }
    }
    Write-Host 'Uninstall complete.'
    return
}

foreach ($name in $names) {
    $src = Join-Path $source $name
    if (-not (Test-Path $src)) {
        throw "Missing source directory: $src"
    }
}

New-Item -ItemType Directory -Force -Path $target | Out-Null

foreach ($name in $names) {
    $src = Join-Path $source $name
    $dst = Join-Path $target $name
    if (Test-Path $dst) {
        Remove-Item -Recurse -Force $dst
    }
    Copy-Item -Recurse $src $dst
    Write-Host "Installed $name"
}

Write-Host "Done: $($names.Count) directories installed to $target"
