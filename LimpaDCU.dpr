program LimpaDCU;

uses
  Vcl.Forms,
  System.SysUtils,
  UntMain in 'src\Forms\UntMain.pas' {FrmMain},
  Vcl.Themes,
  Vcl.Styles,
  UntLib in 'src\lib\UntLib.pas',
  UntTemaAplicacao in 'src\Lib\UntTemaAplicacao.pas',
  UntDtmCnx in 'src\DataModule\UntDtmCnx.pas' {dtmCnx: TDataModule},
  UntClassLimpaDcu in 'src\Class\UntClassLimpaDcu.pas',
  UntCdsProj0 in 'src\Forms\UntCdsProj0.pas' {FrmCdsProj0};

{$R *.res}

begin
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
      Application.MainFormOnTaskbar := True;

      Application.CreateForm(TdtmCnx, dtmCnx);
      dtmCnx.GarantirEstruturaDB;

      tTemaAplicacao.AplicarTemaInicial;

      Application.CreateForm(TFrmMain, FrmMain);

      Application.Run;
   end;
end.

