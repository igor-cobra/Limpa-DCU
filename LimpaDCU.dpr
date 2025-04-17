program LimpaDCU;

uses
  Vcl.Forms,
  System.SysUtils,
  UntMain in 'src\Forms\UntMain.pas' {FrmMain},
  Vcl.Themes,
  Vcl.Styles,
  UntLib in 'src\lib\UntLib.pas',
  UntDtmCnx in 'src\DataModule\UntDtmCnx.pas' {dtmCnx: TDataModule},
  UntClassLimpaDcu in 'src\Class\UntClassLimpaDcu.pas',
  UntCdsProj0 in 'src\Forms\UntCdsProj0.pas' {FrmCdsProj0};

{$R *.res}

begin
   CAMINHO_APL := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
   VERSAO_APL  := VersaoApl;
   NOME_APL    := ExtractFileName(Application.ExeName);
   PASTA_APL   := IncludeTrailingPathDelimiter(ExpandFileName(GetEnvironmentVariable('APPDATA'))) + IncludeTrailingPathDelimiter(ChangeFileExt(NOME_APL, ''));
   CAMINHO_DB  := PASTA_APL + 'database.db';
   PASTA_CONF  := PASTA_APL + 'conf\';
   PASTA_LOG   := PASTA_APL + 'logs\';

   if CheckAppRunning(NOME_APL) then begin
      SetLibraryPath(PASTA_APL + 'lib\');
      if not DirectoryExists(PASTA_APL) then CreateDir(PASTA_APL);
      Application.Initialize;
      Application.MainFormOnTaskbar := True;
      Application.CreateForm(TdtmCnx, dtmCnx);
      Application.CreateForm(TFrmMain, FrmMain);
      Application.Run;
   end;
end.

