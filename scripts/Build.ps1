[CmdletBinding()]
param(
   [ValidateSet('Debug', 'Release')]
   [string]$Configuration = 'Debug',

   [ValidateSet('Win32', 'Win64', 'All')]
   [string]$Platform = 'Win32',

   [ValidateSet('Build', 'Rebuild')]
   [string]$Target = 'Build'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Project = Join-Path $Root 'LimpaDCU.dproj'

function Find-RsVars {
   $Candidates = @()

   if ($env:BDS) {
      $Candidates += (Join-Path $env:BDS 'bin\rsvars.bat')
   }

   if (${env:ProgramFiles(x86)}) {
      $Candidates += (Join-Path ${env:ProgramFiles(x86)} 'Embarcadero\Studio\37.0\bin\rsvars.bat')
   }

   if ($env:ProgramFiles) {
      $Candidates += (Join-Path $env:ProgramFiles 'Embarcadero\Studio\37.0\bin\rsvars.bat')
   }

   foreach ($Candidate in ($Candidates | Select-Object -Unique)) {
      if (Test-Path -LiteralPath $Candidate) {
         return $Candidate
      }
   }

   throw 'Delphi 13 (BDS 37.0) não foi localizado.'
}

function Invoke-DelphiBuild([string]$BuildPlatform) {
   $RsVars = Find-RsVars

   New-Item -ItemType Directory -Path (Join-Path $Root "bin\$BuildPlatform\$Configuration") -Force | Out-Null
   New-Item -ItemType Directory -Path (Join-Path $Root "build\dcu\$BuildPlatform\$Configuration") -Force | Out-Null

   $Command = 'call "{0}" && msbuild "{1}" /t:{2} /p:Config={3} /p:Platform={4} /m /nologo /v:minimal' -f `
      $RsVars, $Project, $Target, $Configuration, $BuildPlatform

   Write-Host "==> $Configuration / $BuildPlatform"
   & cmd.exe /d /s /c $Command

   if ($LASTEXITCODE -ne 0) {
      throw "Falha na compilação $Configuration / $BuildPlatform. ExitCode=$LASTEXITCODE"
   }
}

$Platforms = if ($Platform -eq 'All') { @('Win32', 'Win64') } else { @($Platform) }

foreach ($CurrentPlatform in $Platforms) {
   Invoke-DelphiBuild $CurrentPlatform
}
