[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot

$Targets = @(
   (Join-Path $Root 'bin'),
   (Join-Path $Root 'build'),
   (Join-Path $Root 'installer\output'),
   (Join-Path $Root 'installer\temp')
)

foreach ($Target in $Targets) {
   if (Test-Path -LiteralPath $Target) {
      Remove-Item -LiteralPath $Target -Recurse -Force
   }

   New-Item -ItemType Directory -Path $Target -Force | Out-Null
}

Write-Host '[OK] Artefatos de build removidos.'
