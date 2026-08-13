[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$InstallerDir = Join-Path $Root 'installer'
$TempDir = Join-Path $InstallerDir 'temp'
$OutputDir = Join-Path $InstallerDir 'output'

& (Join-Path $PSScriptRoot 'Clean.ps1')
& (Join-Path $PSScriptRoot 'Validate.ps1')
& (Join-Path $PSScriptRoot 'Build.ps1') -Configuration Release -Platform All -Target Rebuild
& (Join-Path $PSScriptRoot 'Validate.ps1') -ReleaseBinaries

$Exe32 = Join-Path $Root 'bin\Win32\Release\LimpaDCU.exe'
$Helper = Join-Path $TempDir 'LimpaDCU-Migrador.exe'
Copy-Item -LiteralPath $Exe32 -Destination $Helper -Force

$Candidates = @()

if ($env:ProgramFiles) {
   $Candidates += (Join-Path $env:ProgramFiles 'Inno Setup 7\ISCC.exe')
}

if (${env:ProgramFiles(x86)}) {
   $Candidates += (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 7\ISCC.exe')
}

$Iscc = $Candidates |
   Where-Object { Test-Path -LiteralPath $_ } |
   Select-Object -First 1

if (-not $Iscc) {
   throw 'Inno Setup 7.1 ou superior não encontrado.'
}

$InnoVersion = [version](Get-Item -LiteralPath $Iscc).VersionInfo.FileVersion
if ($InnoVersion -lt [version]'7.1.0.0') {
   throw "Inno Setup 7.1 ou superior é necessário. Encontrado: $InnoVersion"
}

try {
   & $Iscc (Join-Path $InstallerDir 'LimpaDCU.iss')

   if ($LASTEXITCODE -ne 0) {
      throw "Falha ao compilar o instalador. ExitCode=$LASTEXITCODE"
   }
}
finally {
   Remove-Item -LiteralPath $Helper -Force -ErrorAction SilentlyContinue
}

$Setup = Get-ChildItem -Path $OutputDir -Filter 'LimpaDCU-Setup-*.exe' |
   Sort-Object LastWriteTime -Descending |
   Select-Object -First 1

if (-not $Setup) {
   throw 'O instalador não foi gerado.'
}

$Hash = Get-FileHash -LiteralPath $Setup.FullName -Algorithm SHA256
$HashFile = Join-Path $OutputDir ($Setup.BaseName + '.sha256')
"$($Hash.Hash)  $($Setup.Name)" | Set-Content -LiteralPath $HashFile -Encoding ascii

Write-Host "[OK] Release: $($Setup.FullName)"
Write-Host "[OK] SHA-256: $($Hash.Hash)"
