[CmdletBinding()]
param(
   [ValidateSet('Debug', 'Release')]
   [string]$Configuration = 'Debug',

   [ValidateSet('Win32', 'Win64', 'All')]
   [string]$Platform = 'All',

   [ValidateSet('Build', 'Rebuild')]
   [string]$Target = 'Build',

   [string]$RadStudioVersion,

   [string]$RsVarsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Project = Join-Path $Root 'LimpaDCU.dproj'

. (Join-Path $PSScriptRoot 'RadStudio.ps1')

$RadStudio = Select-RadStudioInstallation `
   -RequestedVersion $RadStudioVersion `
   -RsVarsPath $RsVarsPath

function Invoke-DelphiBuild {
   param(
      [Parameter(Mandatory)]
      [string]$BuildPlatform
   )

   New-Item `
      -ItemType Directory `
      -Path (Join-Path $Root "bin\$BuildPlatform\$Configuration") `
      -Force |
      Out-Null

   New-Item `
      -ItemType Directory `
      -Path (Join-Path $Root "build\dcu\$BuildPlatform\$Configuration") `
      -Force |
      Out-Null

   $Command = 'call "{0}" && msbuild "{1}" /t:{2} /p:Config={3} /p:Platform={4} /m /nologo /v:minimal' -f `
      $RadStudio.RsVarsPath,
      $Project,
      $Target,
      $Configuration,
      $BuildPlatform

   Write-Host "==> $Configuration / $BuildPlatform"

   & cmd.exe /d /s /c $Command

   if ($LASTEXITCODE -ne 0) {
      throw "Falha na compilação $Configuration / $BuildPlatform. ExitCode=$LASTEXITCODE"
   }
}

$Platforms = if ($Platform -eq 'All') {
   @('Win32', 'Win64')
}
else {
   @($Platform)
}

foreach ($CurrentPlatform in $Platforms) {
   Invoke-DelphiBuild -BuildPlatform $CurrentPlatform
}
