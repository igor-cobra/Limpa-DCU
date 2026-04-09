#define MyAppName "LimpaDCU"
#define MyAppPublisher "SucoDev"
#define MyAppExeName "LimpaDCU.exe"
#define MyAppUserModelID "SucoDev.LimpaDCU"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{D10AEA34-74EB-4C79-986E-E5C81859A3C2}
AppName={#MyAppName}
AppVersion={#GetFileVersion("bin\LimpaDCU.exe")}
AppVerName={#MyAppName} {#GetFileVersion("bin\LimpaDCU.exe")}
AppPublisher={#MyAppPublisher}
DefaultDirName=C:\Precisa\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=no
LicenseFile=LICENSE.txt
InfoBeforeFile=README_instalacao.txt
InfoAfterFile=README_final.txt
OutputDir=instaladores
OutputBaseFilename=Instalador LimpaDCU-{#GetFileVersion("bin\LimpaDCU.exe")}
SetupIconFile=LimpaDCU_Icon.ico
Compression=lzma
SolidCompression=yes
ShowLanguageDialog=yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "bin\LimpaDCU.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\styles\AquaLightSlate.vsf"; DestDir: "{app}\styles"; DestName: "AquaLightSlate.vsf"; Flags: ignoreversion
Source: "bin\styles\Glow.vsf"; DestDir: "{app}\styles"; DestName: "Glow.vsf"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "{#MyAppUserModelID}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; AppUserModelID: "{#MyAppUserModelID}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon; AppUserModelID: "{#MyAppUserModelID}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\*"

[Dirs]
Name: "{app}\styles"
