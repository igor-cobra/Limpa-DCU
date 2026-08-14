Set-StrictMode -Version Latest

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

function Get-RadStudioInstallationInfo {
   param(
      [Parameter(Mandatory)]
      [string]$RsVarsPath,

      [AllowNull()]
      [string]$BdsVersion,

      [AllowNull()]
      [string]$ProductName,

      [string]$Source = 'Descoberta'
   )

   if (-not (Test-Path -LiteralPath $RsVarsPath)) {
      return $null
   }

   $FullPath = [System.IO.Path]::GetFullPath($RsVarsPath)

   if ([string]::IsNullOrWhiteSpace($BdsVersion)) {
      $BinDir = Split-Path -Parent $FullPath
      $VersionDir = Split-Path -Parent $BinDir
      $BdsVersion = Split-Path -Leaf $VersionDir
   }

   if ([string]::IsNullOrWhiteSpace($ProductName)) {
      $ProductName = "RAD Studio (BDS $BdsVersion)"
   }

   return [PSCustomObject]@{
      BdsVersion = $BdsVersion
      ProductName = $ProductName
      RsVarsPath = $FullPath
      RootDir = Split-Path -Parent (Split-Path -Parent $FullPath)
      Source = $Source
   }
}

function Get-RadStudioInstallations {
   $Candidates = @()

   if (-not [string]::IsNullOrWhiteSpace($env:BDS)) {
      $Candidates += Get-RadStudioInstallationInfo `
         -RsVarsPath (Join-Path $env:BDS 'bin\rsvars.bat') `
         -BdsVersion $env:BDSVersion `
         -ProductName $null `
         -Source 'Ambiente BDS'
   }

   $RegistryRoots = @(
      'HKCU:\Software\Embarcadero\BDS',
      'HKLM:\SOFTWARE\Embarcadero\BDS',
      'HKLM:\SOFTWARE\WOW6432Node\Embarcadero\BDS'
   )

   foreach ($RegistryRoot in $RegistryRoots) {
      if (-not (Test-Path -LiteralPath $RegistryRoot)) {
         continue
      }

      foreach ($Key in (Get-ChildItem -LiteralPath $RegistryRoot -ErrorAction SilentlyContinue)) {
         $Properties = Get-ItemProperty -LiteralPath $Key.PSPath -ErrorAction SilentlyContinue

         if ($null -eq $Properties) {
            continue
         }

         $RootDir = Get-SafePropertyValue -Object $Properties -Name 'RootDir'

         if ([string]::IsNullOrWhiteSpace($RootDir)) {
            continue
         }

         $ProductName = Get-SafePropertyValue -Object $Properties -Name 'ProductName'

         if ([string]::IsNullOrWhiteSpace($ProductName)) {
            $ProductName = Get-SafePropertyValue -Object $Properties -Name 'App'
         }

         $Candidates += Get-RadStudioInstallationInfo `
            -RsVarsPath (Join-Path $RootDir 'bin\rsvars.bat') `
            -BdsVersion $Key.PSChildName `
            -ProductName $ProductName `
            -Source "Registro: $RegistryRoot"
      }
   }

   $StudioRoots = @()

   if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
      $StudioRoots += Join-Path ${env:ProgramFiles(x86)} 'Embarcadero\Studio'
   }

   if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
      $StudioRoots += Join-Path $env:ProgramFiles 'Embarcadero\Studio'
   }

   foreach ($StudioRoot in ($StudioRoots | Select-Object -Unique)) {
      if (-not (Test-Path -LiteralPath $StudioRoot)) {
         continue
      }

      foreach ($VersionDir in (Get-ChildItem -LiteralPath $StudioRoot -Directory -ErrorAction SilentlyContinue)) {
         $Candidates += Get-RadStudioInstallationInfo `
            -RsVarsPath (Join-Path $VersionDir.FullName 'bin\rsvars.bat') `
            -BdsVersion $VersionDir.Name `
            -ProductName $null `
            -Source "Diretório: $StudioRoot"
      }
   }

   $Seen = @{}
   $Result = @()

   foreach ($Candidate in $Candidates) {
      if ($null -eq $Candidate) {
         continue
      }

      $Key = $Candidate.RsVarsPath.ToLowerInvariant()

      if ($Seen.ContainsKey($Key)) {
         continue
      }

      $Seen[$Key] = $true
      $Result += $Candidate
   }

   return @(
      $Result |
         Sort-Object @{
            Expression = {
               try {
                  [version]$_.BdsVersion
               }
               catch {
                  [version]'0.0'
               }
            }
            Descending = $true
         }
   )
}

function Select-RadStudioInstallation {
   param(
      [AllowNull()]
      [string]$RequestedVersion,

      [AllowNull()]
      [string]$RsVarsPath
   )

   if (-not [string]::IsNullOrWhiteSpace($RsVarsPath)) {
      $Installation = Get-RadStudioInstallationInfo `
         -RsVarsPath $RsVarsPath `
         -BdsVersion $null `
         -ProductName $null `
         -Source 'Parâmetro -RsVarsPath'

      if ($null -eq $Installation) {
         throw "rsvars.bat não encontrado: $RsVarsPath"
      }

      Write-Host "[OK] RAD Studio selecionado: $($Installation.ProductName)"
      Write-Host "     $($Installation.RsVarsPath)"
      return $Installation
   }

   $Installations = @(Get-RadStudioInstallations)

   if ($Installations.Count -eq 0) {
      throw @'
Nenhuma instalação do RAD Studio/Delphi foi localizada.

Foram verificados:
  - variável de ambiente BDS;
  - registro do Embarcadero BDS;
  - Program Files\Embarcadero\Studio;
  - Program Files (x86)\Embarcadero\Studio.
'@
   }

   if (-not [string]::IsNullOrWhiteSpace($RequestedVersion)) {
      $Matches = @(
         $Installations |
            Where-Object {
               ($_.BdsVersion -eq $RequestedVersion) -or
               ($_.ProductName -like "*$RequestedVersion*")
            }
      )

      if ($Matches.Count -eq 0) {
         $Available = ($Installations | ForEach-Object {
            "  - BDS $($_.BdsVersion): $($_.ProductName)"
         }) -join [Environment]::NewLine

         throw "RAD Studio '$RequestedVersion' não encontrado.`nVersões disponíveis:`n$Available"
      }

      if ($Matches.Count -gt 1) {
         throw "Mais de uma instalação corresponde a '$RequestedVersion'. Informe -RsVarsPath explicitamente."
      }

      $Selected = $Matches[0]

      Write-Host "[OK] RAD Studio selecionado: $($Selected.ProductName) / BDS $($Selected.BdsVersion)"
      Write-Host "     $($Selected.RsVarsPath)"
      return $Selected
   }

   if ($Installations.Count -eq 1) {
      $Selected = $Installations[0]

      Write-Host "[OK] RAD Studio encontrado: $($Selected.ProductName) / BDS $($Selected.BdsVersion)"
      Write-Host "     $($Selected.RsVarsPath)"
      return $Selected
   }

   Write-Host ''
   Write-Host 'Foram encontradas várias instalações do RAD Studio:'
   Write-Host ''

   for ($Index = 0; $Index -lt $Installations.Count; $Index++) {
      $Item = $Installations[$Index]

      Write-Host ("  [{0}] {1} / BDS {2}" -f ($Index + 1), $Item.ProductName, $Item.BdsVersion)
      Write-Host ("      {0}" -f $Item.RootDir)
   }

   Write-Host ''

   while ($true) {
      $Answer = Read-Host "Selecione a versão do RAD Studio [1-$($Installations.Count)]"
      $Choice = 0

      if ([int]::TryParse($Answer, [ref]$Choice) -and
          ($Choice -ge 1) -and
          ($Choice -le $Installations.Count)) {
         $Selected = $Installations[$Choice - 1]
         break
      }

      Write-Warning 'Seleção inválida.'
   }

   Write-Host "[OK] RAD Studio selecionado: $($Selected.ProductName) / BDS $($Selected.BdsVersion)"
   Write-Host "     $($Selected.RsVarsPath)"

   return $Selected
}
