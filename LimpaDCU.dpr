program LimpaDCU;

uses
  Vcl.Forms,
  System.SysUtils,
  Vcl.Themes,
  Vcl.Styles,
  Winapi.Windows,
  Winapi.ShlObj,
  UntMain in 'src\Forms\UntMain.pas' {FrmMain},
  UntLib in 'src\lib\UntLib.pas',
  UntTemaAplicacao in 'src\Lib\UntTemaAplicacao.pas',
  UntDtmCnx in 'src\DataModule\UntDtmCnx.pas' {dtmCnx: TDataModule},
  UntClassLimpaDcu in 'src\Class\UntClassLimpaDcu.pas',
  UntCdsProj0 in 'src\Forms\UntCdsProj0.pas' {FrmCdsProj0},
  UntDlgPadrao in 'src\Forms\UntDlgPadrao.pas' {frmDlgPadrao},
  UntClassNotificacaoWindows in 'src\Class\UntClassNotificacaoWindows.pas',
  UntClassDialogos in 'src\Class\UntClassDialogos.pas';

{$R *.res}

begin
   SetCurrentProcessExplicitAppUserModelID('SucoDev.LimpaDCU');
   CAMINHO_APL := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
   VERSAO_APL  := VersaoApl;
   NOME_APL    := ExtractFileName(Application.ExeName);
   CAMINHO_DB  := CAMINHO_APL + 'database.db';
   PASTA_CONF  := CAMINHO_APL + 'conf\';
   PASTA_LOG   := CAMINHO_APL + 'logs\';
   PASTA_STYLE := CAMINHO_APL + 'styles\';

   if CheckAppRunning(NOME_APL) then begin
      SetLibraryPath(CAMINHO_APL + 'lib\');
      if not DirectoryExists(CAMINHO_APL) then CreateDir(CAMINHO_APL);
      Application.Initialize;
      Application.Title             := 'Limpa DCU';
      Application.MainFormOnTaskbar := True;

      Application.CreateForm(TdtmCnx, dtmCnx);
      dtmCnx.GarantirEstruturaDB;

      tTemaAplicacao.AplicarTemaInicial;

      Application.CreateForm(TFrmMain, FrmMain);

      Application.Run;
   end;
end.

