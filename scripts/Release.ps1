[CmdletBinding()]
param(
   [string]$RadStudioVersion,

   [string]$RsVarsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$InstallerDir = Join-Path $Root 'installer'
$TempDir = Join-Path $InstallerDir 'temp'
$OutputDir = Join-Path $InstallerDir 'output'

. (Join-Path $PSScriptRoot 'RadStudio.ps1')

function Get-SafePropertyValue {
   param(
      [Parameter(Mandatory)]
      [object]$Object,

      [Parameter(Mandatory)]
      [string]$Name
   )

   $Property = $Object.PSObject.Properties[$Name]

   if ($null -eq $Property) {
      return $null
   }

   return $Property.Value
}

function Convert-ToVersion {
   param(
      [AllowNull()]
      [string]$Value
   )

   if ([string]::IsNullOrWhiteSpace($Value)) {
      return $null
   }

   $Match = [regex]::Match($Value, '\d+(?:\.\d+){0,3}')

   if (-not $Match.Success) {
      return $null
   }

   $Parts = @($Match.Value.Split('.'))

   while ($Parts.Count -lt 4) {
      $Parts += '0'
   }

   if ($Parts.Count -gt 4) {
      $Parts = $Parts[0..3]
   }

   try {
      return [version]($Parts -join '.')
   }
   catch {
      return $null
   }
}

function Get-InnoVersionFromExecutable {
   param(
      [Parameter(Mandatory)]
      [string]$Path
   )

   $VersionInfo = (Get-Item -LiteralPath $Path).VersionInfo

   foreach ($RawVersion in @(
      $VersionInfo.ProductVersion,
      $VersionInfo.FileVersion
   )) {
      $Version = Convert-ToVersion -Value $RawVersion

      if (($null -ne $Version) -and
          ($Version -gt [version]'0.0.0.0')) {
         return $Version
      }
   }

   try {
      $Output = (& $Path '/?' 2>&1 | Out-String)

      $Match = [regex]::Match(
         $Output,
         'Inno Setup(?:\s+version)?\s+(\d+(?:\.\d+){1,3})',
         [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
      )

      if ($Match.Success) {
         $Version = Convert-ToVersion -Value $Match.Groups[1].Value

         if (($null -ne $Version) -and
             ($Version -gt [version]'0.0.0.0')) {
            return $Version
         }
      }
   }
   catch {
      # O registro ainda pode fornecer a versão.
   }

   return $null
}

function Find-InnoSetup {
   $Candidates = @()

   if (-not [string]::IsNullOrWhiteSpace($env:INNO_ISCC)) {
      $Candidates += [PSCustomObject]@{
         Path = $env:INNO_ISCC
         RegistryVersion = $null
         Source = 'INNO_ISCC'
      }
   }

   $Command = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue

   if ($null -ne $Command) {
      $Candidates += [PSCustomObject]@{
         Path = $Command.Source
         RegistryVersion = $null
         Source = 'PATH'
      }
   }

   $UninstallRoots = @(
      'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
      'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
   )

   foreach ($RootKey in $UninstallRoots) {
      foreach ($Entry in (Get-ItemProperty -Path $RootKey -ErrorAction SilentlyContinue)) {
         $DisplayName = Get-SafePropertyValue -Object $Entry -Name 'DisplayName'

         if ([string]::IsNullOrWhiteSpace($DisplayName) -or
             ($DisplayName -notlike 'Inno Setup*')) {
            continue
         }

         $InstallLocation = Get-SafePropertyValue -Object $Entry -Name 'InstallLocation'
         $DisplayVersion = Get-SafePropertyValue -Object $Entry -Name 'DisplayVersion'
         $UninstallString = Get-SafePropertyValue -Object $Entry -Name 'UninstallString'

         $IsccPath = $null

         if (-not [string]::IsNullOrWhiteSpace($InstallLocation)) {
            $IsccPath = Join-Path $InstallLocation 'ISCC.exe'
         }
         elseif (-not [string]::IsNullOrWhiteSpace($UninstallString)) {
            $UninstallMatch = [regex]::Match(
               $UninstallString,
               '^"?([^"\r\n]+?\\)unins\d*\.exe"?',
               [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            )

            if ($UninstallMatch.Success) {
               $IsccPath = Join-Path $UninstallMatch.Groups[1].Value 'ISCC.exe'
            }
         }

         if ([string]::IsNullOrWhiteSpace($IsccPath)) {
            continue
         }

         $Candidates += [PSCustomObject]@{
            Path = $IsccPath
            RegistryVersion = $DisplayVersion
            Source = 'Registro'
         }
      }
   }

   if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
      $Candidates += [PSCustomObject]@{
         Path = Join-Path $env:ProgramFiles 'Inno Setup 7\ISCC.exe'
         RegistryVersion = $null
         Source = 'Program Files'
      }
   }

   if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
      $Candidates += [PSCustomObject]@{
         Path = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 7\ISCC.exe'
         RegistryVersion = $null
         Source = 'Program Files (x86)'
      }
   }

   $Seen = @{}

   foreach ($Candidate in $Candidates) {
      if ($null -eq $Candidate) {
         continue
      }

      if ([string]::IsNullOrWhiteSpace($Candidate.Path)) {
         continue
      }

      $ExpandedPath = [Environment]::ExpandEnvironmentVariables($Candidate.Path)
      $FullPath = [System.IO.Path]::GetFullPath($ExpandedPath)
      $Key = $FullPath.ToLowerInvariant()

      if ($Seen.ContainsKey($Key)) {
         continue
      }

      $Seen[$Key] = $true

      if (-not (Test-Path -LiteralPath $FullPath)) {
         continue
      }

      $Version = Get-InnoVersionFromExecutable -Path $FullPath

      if (($null -eq $Version) -and
          (-not [string]::IsNullOrWhiteSpace($Candidate.RegistryVersion))) {
         $Version = Convert-ToVersion -Value $Candidate.RegistryVersion
      }

      if (($null -eq $Version) -or
          ($Version -eq [version]'0.0.0.0')) {
         continue
      }

      return [PSCustomObject]@{
         Path = $FullPath
         Version = $Version
         Source = $Candidate.Source
      }
   }

   throw @'
Inno Setup 7.1 ou superior não foi localizado com uma versão válida.

Se estiver instalado em um caminho personalizado, defina:

  $env:INNO_ISCC = 'C:\caminho\para\ISCC.exe'

e execute novamente:
  .\Release.ps1
'@
}

# Resolve as ferramentas antes de iniciar limpeza e compilação.
$RadStudio = Select-RadStudioInstallation `
   -RequestedVersion $RadStudioVersion `
   -RsVarsPath $RsVarsPath

$Inno = Find-InnoSetup

Write-Host "[OK] Inno Setup $($Inno.Version) encontrado:"
Write-Host "     $($Inno.Path)"

if ($Inno.Version -lt [version]'7.1.0.0') {
   throw "Inno Setup 7.1 ou superior é necessário. Encontrado: $($Inno.Version)"
}

& (Join-Path $PSScriptRoot 'Clean.ps1')
& (Join-Path $PSScriptRoot 'Validate.ps1')

& (Join-Path $PSScriptRoot 'Build.ps1') `
   -Configuration Release `
   -Platform All `
   -Target Rebuild `
   -RsVarsPath $RadStudio.RsVarsPath

& (Join-Path $PSScriptRoot 'Validate.ps1') -ReleaseBinaries

$Exe32 = Join-Path $Root 'bin\Win32\Release\LimpaDCU.exe'
$Helper = Join-Path $TempDir 'LimpaDCU-Migrador.exe'

Copy-Item -LiteralPath $Exe32 -Destination $Helper -Force

try {
   & $Inno.Path (Join-Path $InstallerDir 'LimpaDCU.iss')

   if ($LASTEXITCODE -ne 0) {
      throw "Falha ao compilar o instalador. ExitCode=$LASTEXITCODE"
   }
}
finally {
   Remove-Item -LiteralPath $Helper -Force -ErrorAction SilentlyContinue
}

$Setup = Get-ChildItem `
   -Path $OutputDir `
   -Filter 'LimpaDCU-Setup-*.exe' |
   Sort-Object LastWriteTime -Descending |
   Select-Object -First 1

if (-not $Setup) {
   throw 'O instalador não foi gerado.'
}

$Hash = Get-FileHash -LiteralPath $Setup.FullName -Algorithm SHA256
$HashFile = Join-Path $OutputDir ($Setup.BaseName + '.sha256')

"$($Hash.Hash)  $($Setup.Name)" |
   Set-Content -LiteralPath $HashFile -Encoding ascii

Write-Host "[OK] Release: $($Setup.FullName)"
Write-Host "[OK] SHA-256: $($Hash.Hash)"
