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
   'docs\EDITORCONFIG_E_FORMATTER.md',
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
$ProjectRaw = Get-Content -LiteralPath $Project -Raw

$Rules = @(
   '<Config Condition="''$(Config)''==''''">Debug</Config>',
   '<Platform Condition="''$(Platform)''==''''">Win32</Platform>',
   '<DCC_DcuOutput>build\dcu\$(Platform)\$(Config)\</DCC_DcuOutput>',
   '<DCC_ExeOutput>bin\$(Platform)\$(Config)\</DCC_ExeOutput>',
   '<UsePackages>true</UsePackages>',
   '<UsePackages>false</UsePackages>',
   '<None Include="LimpaDCU.res" />',
   '<None Include=".editorconfig" />',
   '<None Include="README.md" />',
   '<None Include="docs\EDITORCONFIG_E_FORMATTER.md" />'
)

foreach ($Rule in $Rules) {
   if (-not $ProjectRaw.Contains($Rule)) {
      throw "Regra ausente no LimpaDCU.dproj: $Rule"
   }
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
