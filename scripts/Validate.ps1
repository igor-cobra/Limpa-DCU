[CmdletBinding()]
param(
   [switch]$ReleaseBinaries
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Project = Join-Path $Root 'LimpaDCU.dproj'

function Get-PeMachine([string]$Path) {
   $Stream = [System.IO.File]::OpenRead($Path)
   $Reader = [System.IO.BinaryReader]::new($Stream)

   try {
      if ($Reader.ReadUInt16() -ne 0x5A4D) {
         throw "Arquivo não possui assinatura MZ: $Path"
      }

      $Stream.Position = 0x3C
      $PeOffset = $Reader.ReadInt32()
      $Stream.Position = $PeOffset

      if ($Reader.ReadUInt32() -ne 0x00004550) {
         throw "Arquivo não possui assinatura PE: $Path"
      }

      return $Reader.ReadUInt16()
   }
   finally {
      $Reader.Dispose()
      $Stream.Dispose()
   }
}

$Required = @(
   'LimpaDCU.dpr',
   'LimpaDCU.dproj',
   'LimpaDCU.res',
   '.editorconfig',
   '.gitattributes',
   '.gitignore',
   'README.md',
   'installer\README.md',
   'scripts\README.md',
   'scripts\RadStudio.ps1',
   'docs\EDITORCONFIG_E_FORMATTER.md',
   'docs\IDENTIDADE_VISUAL.md',
   'assets\icons\LimpaDCU.ico',
   'CONTRIBUTING.md',
   'CHANGELOG.md',
   'src\Class\UntClassAplicacao.pas',
   'src\Class\UntClassLog.pas',
   'src\Class\UntClassDialogos.pas',
   'src\Class\UntClassNotificacaoWindows.pas',
   'src\Class\UntClassLimpaDcu.pas',
   'src\Class\UntTemaAplicacao.pas',
   'src\DataModule\UntDtmCnx.pas',
   'src\Forms\UntMain.pas',
   'installer\LimpaDCU.iss'
)

foreach ($Relative in $Required) {
   if (-not (Test-Path -LiteralPath (Join-Path $Root $Relative))) {
      throw "Arquivo obrigatório ausente: $Relative"
   }
}

[xml]$ProjectXml = Get-Content -LiteralPath $Project -Raw

$Namespace = New-Object System.Xml.XmlNamespaceManager($ProjectXml.NameTable)
$Namespace.AddNamespace('msb', 'http://schemas.microsoft.com/developer/msbuild/2003')

function Get-ProjectNodes([string]$XPath) {
   return @($ProjectXml.SelectNodes($XPath, $Namespace))
}

function Assert-ProjectValue {
   param(
      [Parameter(Mandatory)]
      [string]$XPath,

      [Parameter(Mandatory)]
      [string]$Expected,

      [Parameter(Mandatory)]
      [string]$Description
   )

   $Found = Get-ProjectNodes $XPath |
      Where-Object {
         $_.InnerText.Trim() -eq $Expected
      }

   if (-not $Found) {
      throw "Regra ausente no LimpaDCU.dproj: $Description"
   }
}

function Assert-ProjectInclude {
   param(
      [Parameter(Mandatory)]
      [string]$Include
   )

   $Found = Get-ProjectNodes '//msb:None' |
      Where-Object {
         $_.GetAttribute('Include') -eq $Include
      }

   if (-not $Found) {
      throw "Arquivo não está incluído no LimpaDCU.dproj: $Include"
   }
}

Assert-ProjectValue `
   -XPath '//msb:DCC_DcuOutput' `
   -Expected 'build\dcu\$(Platform)\$(Config)\' `
   -Description 'DCC_DcuOutput'

Assert-ProjectValue `
   -XPath '//msb:DCC_ExeOutput' `
   -Expected 'bin\$(Platform)\$(Config)\' `
   -Description 'DCC_ExeOutput'

$UsePackages = Get-ProjectNodes '//msb:UsePackages' |
   ForEach-Object {
      $_.InnerText.Trim().ToLowerInvariant()
   }

if ('true' -notin $UsePackages) {
   throw 'Regra ausente no LimpaDCU.dproj: Debug deve usar Runtime Packages.'
}

if ('false' -notin $UsePackages) {
   throw 'Regra ausente no LimpaDCU.dproj: Release não deve usar Runtime Packages.'
}

foreach ($Include in @(
   'LimpaDCU.res',
   '.editorconfig',
   'README.md',
   'docs\EDITORCONFIG_E_FORMATTER.md',
   'docs\IDENTIDADE_VISUAL.md'
)) {
   Assert-ProjectInclude -Include $Include
}

$CustomStyles = Get-ProjectNodes '//msb:Custom_Styles' |
   ForEach-Object {
      $_.InnerText.Trim()
   }

$ExpectedStyles = '"Aqua Light Slate|VCLSTYLE|$(BDSCOMMONDIR)\Styles\AquaLightSlate.vsf";Glow|VCLSTYLE|$(BDSCOMMONDIR)\Styles\Glow.vsf'

if ($ExpectedStyles -notin $CustomStyles) {
   throw 'Baseline visual ausente no LimpaDCU.dproj: Aqua Light Slate / Glow.'
}

# Evita versões parcialmente alteradas entre FileVersion e ProductVersion.
foreach ($VersionKeysNode in (Get-ProjectNodes '//msb:VerInfo_Keys')) {
   $Keys = $VersionKeysNode.InnerText.Trim()

   $FileVersionMatch = [regex]::Match($Keys, '(?:^|;)FileVersion=([^;]+)')
   $ProductVersionMatch = [regex]::Match($Keys, '(?:^|;)ProductVersion=([^;]+)')

   if ($FileVersionMatch.Success -and
       $ProductVersionMatch.Success -and
       ($FileVersionMatch.Groups[1].Value -ne $ProductVersionMatch.Groups[1].Value)) {
      throw "Version Info inconsistente no LimpaDCU.dproj: FileVersion=$($FileVersionMatch.Groups[1].Value) / ProductVersion=$($ProductVersionMatch.Groups[1].Value)"
   }
}


$ThemeSource = Get-Content -LiteralPath (Join-Path $Root 'src\Class\UntTemaAplicacao.pas') -Raw
$ThemeRules = @(
   'Vcl.Styles',
   'AquaLightSlate.vsf',
   'Glow.vsf',
   'TStyleManager.TrySetStyle'
)

foreach ($ThemeRule in $ThemeRules) {
   if (-not $ThemeSource.Contains($ThemeRule)) {
      throw "Baseline visual ausente em UntTemaAplicacao.pas: $ThemeRule"
   }
}


$IconPath = Join-Path $Root 'assets\icons\LimpaDCU.ico'
$IconHashEsperado = '0B7ECA4214FD5B06B348110093F349A79C433A02D93122853DE4389697795CBF'
$IconHashAtual = (Get-FileHash -LiteralPath $IconPath -Algorithm SHA256).Hash

if ($IconHashAtual -ne $IconHashEsperado) {
   throw "O ícone oficial do LimpaDCU foi alterado. SHA256 atual: $IconHashAtual"
}

$SourceFiles = Get-ChildItem -Path (Join-Path $Root 'src') -Recurse -File -Include *.pas,*.dfm
$Stale = $SourceFiles | Select-String -Pattern 'UntLib|CadsatrarProjeto|DeleteProjeto|Application\.ProcessMessages'

if ($Stale) {
   throw "Referência legada encontrada:`n$($Stale | Out-String)"
}

if ($ReleaseBinaries) {
   $Exe32 = Join-Path $Root 'bin\Win32\Release\LimpaDCU.exe'
   $Exe64 = Join-Path $Root 'bin\Win64\Release\LimpaDCU.exe'

   foreach ($Exe in @($Exe32, $Exe64)) {
      if (-not (Test-Path -LiteralPath $Exe)) {
         throw "Release obrigatória não encontrada: $Exe"
      }
   }

   if ((Get-PeMachine $Exe32) -ne 0x014C) {
      throw 'O executável Win32 não é PE x86.'
   }

   if ((Get-PeMachine $Exe64) -ne 0x8664) {
      throw 'O executável Win64 não é PE x64.'
   }

   $Version32 = (Get-Item -LiteralPath $Exe32).VersionInfo.FileVersion
   $Version64 = (Get-Item -LiteralPath $Exe64).VersionInfo.FileVersion

   if ($Version32 -ne $Version64) {
      throw "Versões divergentes: Win32=$Version32 / Win64=$Version64"
   }

   foreach ($Exe in @($Exe32, $Exe64)) {
      $Bytes = [System.IO.File]::ReadAllBytes($Exe)
      $Ascii = [System.Text.Encoding]::ASCII.GetString($Bytes)

      if ($Ascii -match '(?i)[A-Za-z0-9_.-]+\.bpl') {
         throw "A Release contém referência aparente a BPL: $Exe"
      }
   }
}

Write-Host '[OK] Validação concluída.'
