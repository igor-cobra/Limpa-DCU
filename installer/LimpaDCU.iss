#define MyAppName "Limpa DCU"
#define MyAppExeName "LimpaDCU.exe"
#define MyAppPublisher "SucoDev"
#define MyAppUserModelID "SucoDev.LimpaDCU"
#define ExeWin32 "..\bin\Win32\Release\LimpaDCU.exe"
#define ExeWin64 "..\bin\Win64\Release\LimpaDCU.exe"
#define MyAppVersion GetVersionNumbersString(ExeWin32)

[Setup]
AppId={{D10AEA34-74EB-4C79-986E-E5C81859A3C2}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={code:ObterPastaInstalacao}
DefaultGroupName={#MyAppName}
DisableDirPage=yes
AllowNoIcons=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x86compatible
UsePreviousAppDir=no
CloseApplications=yes
RestartApplications=no
AppMutex=Local\SucoDev.LimpaDCU
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=..\assets\icons\LimpaDCU.ico
LicenseFile=..\LICENSE
InfoBeforeFile=INFO_ANTES.txt
InfoAfterFile=INFO_DEPOIS.txt
OutputDir=output
OutputBaseFilename=LimpaDCU-Setup-{#MyAppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern dynamic
SetupLogging=yes
ShowLanguageDialog=no

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na área de trabalho"; GroupDescription: "Atalhos:"; Flags: unchecked

[Dirs]
Name: "{commonappdata}\SucoDev\LimpaDCU"; Permissions: users-modify
Name: "{commonappdata}\SucoDev\LimpaDCU\data"; Permissions: users-modify
Name: "{commonappdata}\SucoDev\LimpaDCU\logs"; Permissions: users-modify

[Files]
Source: "temp\LimpaDCU-Migrador.exe"; Flags: dontcopy noencryption
Source: "{#ExeWin32}"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Flags: replacesameversion; Check: InstalarWin32
Source: "{#ExeWin64}"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Flags: replacesameversion; Check: InstalarWin64

[InstallDelete]
Type: files; Name: "{app}\database.db"
Type: files; Name: "{app}\*.bpl"
Type: files; Name: "{app}\*.dcu"
Type: files; Name: "{app}\*.map"
Type: files; Name: "{app}\*.rsm"
Type: files; Name: "{app}\*.tds"
Type: filesandordirs; Name: "{app}\conf"
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\styles"
Type: filesandordirs; Name: "{app}\lib"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "{#MyAppUserModelID}"
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; AppUserModelID: "{#MyAppUserModelID}"

[Registry]
Root: HKLM32; Subkey: "Software\SucoDev\LimpaDCU"; ValueType: string; ValueName: "Architecture"; ValueData: "{code:ObterArquiteturaSelecionada}"; Flags: uninsdeletekey
Root: HKLM32; Subkey: "Software\SucoDev\LimpaDCU"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKLM32; Subkey: "Software\SucoDev\LimpaDCU"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Executar {#MyAppName}"; Flags: postinstall nowait skipifsilent runasoriginaluser

[UninstallRun]
Filename: "{app}\{#MyAppExeName}"; Parameters: "/limpar-legado-usuario"; RunOnceId: "LimparLegadoUsuario"; Flags: runascurrentuser waituntilterminated skipifdoesntexist

[UninstallDelete]
Type: filesandordirs; Name: "{commonappdata}\SucoDev\LimpaDCU"
Type: filesandordirs; Name: "C:\Precisa\LimpaDCU"
Type: filesandordirs; Name: "C:\Precisa\Limpa DCU"

[Code]
var
   PaginaArquitetura: TInputOptionWizardPage;
   bInstalar64: Boolean;

function InstalarWin32: Boolean;
begin
   Result := not bInstalar64;
end;

function InstalarWin64: Boolean;
begin
   Result := bInstalar64 and IsWin64;
end;

function ObterArquiteturaSelecionada(Param: string): string;
begin
   if InstalarWin64 then begin
      Result := 'Win64';
   end else begin
      Result := 'Win32';
   end;
end;

function ObterPastaInstalacao(Param: string): string;
begin
   if InstalarWin64 then begin
      Result := ExpandConstant('{commonpf64}\SucoDev\LimpaDCU');
   end else begin
      Result := ExpandConstant('{commonpf32}\SucoDev\LimpaDCU');
   end;
end;

procedure AtualizarPastaInstalacao;
begin
   if WizardForm <> nil then begin
      WizardForm.DirEdit.Text := ObterPastaInstalacao('');
   end;
end;

function PrepararPastaDados: Boolean;
var
   sPastaDados: string;
   sParametros: string;
   iResultado: Integer;
begin
   Result := False;
   sPastaDados := ExpandConstant('{commonappdata}\SucoDev\LimpaDCU');

   if not ForceDirectories(sPastaDados + '\data') then begin
      Exit;
   end;

   ForceDirectories(sPastaDados + '\logs');

   sParametros := '"' + sPastaDados + '" /grant *S-1-5-32-545:(OI)(CI)M /T /C /Q';
   Result := Exec(
      ExpandConstant('{sys}\icacls.exe'),
      sParametros,
      '',
      SW_HIDE,
      ewWaitUntilTerminated,
      iResultado
      ) and (iResultado = 0);
end;

function MigrarDadosLegados: Boolean;
var
   sMigrador: string;
   iResultado: Integer;
begin
   Result := False;

   try
      ExtractTemporaryFile('LimpaDCU-Migrador.exe');
      sMigrador := ExpandConstant('{tmp}\LimpaDCU-Migrador.exe');

      Result := ExecAsOriginalUser(
         sMigrador,
         '/migrar-legado',
         ExpandConstant('{tmp}'),
         SW_HIDE,
         ewWaitUntilTerminated,
         iResultado
         ) and (iResultado = 0);
   except
      Result := False;
   end;
end;

procedure LimparOutraArquitetura;
var
   sPastaOutraArquitetura: string;
begin
   if not IsWin64 then begin
      Exit;
   end;

   if bInstalar64 then begin
      sPastaOutraArquitetura := ExpandConstant('{commonpf32}\SucoDev\LimpaDCU');
   end else begin
      sPastaOutraArquitetura := ExpandConstant('{commonpf64}\SucoDev\LimpaDCU');
   end;

   if CompareText(AddBackslash(sPastaOutraArquitetura),
      AddBackslash(ExpandConstant('{app}'))) <> 0 then begin
      DelTree(sPastaOutraArquitetura, True, True, True);
   end;
end;

procedure LimparResiduosMaquina;
begin
   LimparOutraArquitetura;
   DelTree('C:\Precisa\LimpaDCU', True, True, True);
   DelTree('C:\Precisa\Limpa DCU', True, True, True);
end;

procedure LimparResiduosUsuarioAtual;
var
   iResultado: Integer;
begin
   try
      ExecAsOriginalUser(
         ExpandConstant('{app}\{#MyAppExeName}'),
         '/limpar-legado-usuario',
         ExpandConstant('{app}'),
         SW_HIDE,
         ewWaitUntilTerminated,
         iResultado
         );
   except
      { Melhor esforço. }
   end;
end;

function InitializeSetup: Boolean;
begin
   bInstalar64 := IsWin64;
   Result := True;
end;

procedure InitializeWizard;
var
   sArquiteturaAnterior: string;
begin
   if not IsWin64 then begin
      Exit;
   end;

   sArquiteturaAnterior := LowerCase(GetPreviousData('Architecture', ''));

   if sArquiteturaAnterior = 'win32' then begin
      bInstalar64 := False;
   end else if sArquiteturaAnterior = 'win64' then begin
      bInstalar64 := True;
   end;

   PaginaArquitetura := CreateInputOptionPage(
      wpWelcome,
      'Arquitetura da aplicação',
      'Escolha qual versão do LimpaDCU deseja instalar.',
      'A versão 64-bit é recomendada em Windows 64-bit. A versão 32-bit fica disponível para compatibilidade.',
      True,
      False
      );
   PaginaArquitetura.Add('64-bit (recomendado)');
   PaginaArquitetura.Add('32-bit (compatibilidade)');

   if bInstalar64 then begin
      PaginaArquitetura.SelectedValueIndex := 0;
   end else begin
      PaginaArquitetura.SelectedValueIndex := 1;
   end;

   AtualizarPastaInstalacao;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
   Result := True;

   if (PaginaArquitetura <> nil) and (CurPageID = PaginaArquitetura.ID) then begin
      bInstalar64 := PaginaArquitetura.SelectedValueIndex = 0;
      AtualizarPastaInstalacao;
   end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
begin
   Result := '';

   if not PrepararPastaDados then begin
      Result := 'Não foi possível preparar a pasta de dados compartilhada do LimpaDCU.';
      Exit;
   end;

   if not MigrarDadosLegados then begin
      Result := 'Não foi possível preservar o banco de dados da versão anterior. A instalação foi cancelada antes da limpeza dos arquivos antigos.';
   end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
   if CurStep = ssPostInstall then begin
      LimparResiduosUsuarioAtual;
      LimparResiduosMaquina;
   end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
   SetPreviousData(PreviousDataKey, 'Architecture', ObterArquiteturaSelecionada(''));
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
   if CurUninstallStep = usPostUninstall then begin
      DelTree(ExpandConstant('{commonappdata}\SucoDev\LimpaDCU'), True, True, True);
      DelTree('C:\Precisa\LimpaDCU', True, True, True);
      DelTree('C:\Precisa\Limpa DCU', True, True, True);
   end;
end;
