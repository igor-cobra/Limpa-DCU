program LimpaDCU;

uses
   Winapi.Windows,
   WinApi.ShlObj,
   Vcl.Forms,
   System.SysUtils,
   UntClassAplicacao in 'src\Class\UntClassAplicacao.pas',
   UntClassLog in 'src\Class\UntClassLog.pas',
   UntClassDialogos in 'src\Class\UntClassDialogos.pas',
   UntClassNotificacaoWindows in 'src\Class\UntClassNotificacaoWindows.pas',
   UntClassLimpaDcu in 'src\Class\UntClassLimpaDcu.pas',
   UntTemaAplicacao in 'src\Class\UntTemaAplicacao.pas',
   UntDtmCnx in 'src\DataModule\UntDtmCnx.pas' {dtmCnx: TDataModule},
   UntDlgPadrao in 'src\Forms\UntDlgPadrao.pas' {frmDlgPadrao},
   UntCdsProj0 in 'src\Forms\UntCdsProj0.pas' {FrmCdsProj0},
   UntMain in 'src\Forms\UntMain.pas' {FrmMain};

{$R *.res}

begin
   if tAplicacao.ProcessarModoManutencao then begin
      Exit;
   end;

   SetCurrentProcessExplicitAppUserModelID(PChar(tAplicacao.AppUserModelID));

   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.Title := tAplicacao.Nome;

   try
      if not tAplicacao.Inicializar then begin
         tDialogos.AplicacaoJaEmExecucao;
         Exit;
      end;

      Application.CreateForm(tDtmCnx, dtmCnx);
      dtmCnx.GarantirEstruturaDB;
      tTemaAplicacao.AplicarTemaInicial;
      Application.CreateForm(TFrmMain, FrmMain);
      Application.Run;
   except
      on E: Exception do begin
         tDialogos.Erro(
            'O LimpaDCU encontrou um erro durante a inicialização.',
            'Falha ao iniciar',
            E.ClassName + ': ' + E.Message
            );
      end;
   end;

   tAplicacao.Finalizar;
end.
