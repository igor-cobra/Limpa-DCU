unit UntClassDialogos;

interface

uses
   System.Generics.Collections,
   System.UITypes,
   UntDlgPadrao;

type
   tBotaoConfirmacaoPadrao = (bcpSim, bcpNao);

   tDialogoPendente = class
   public
      Config: tConfigDialogoProjeto;
   end;

   tDialogos = class
   private
      class var aDialogosPendentes: TObjectDictionary<string, tDialogoPendente>;
      class var bControleNotificacaoInicializado: Boolean;

      class function ObterCabecalho(const sCabecalho, sPadrao: string): string; static;
      class function ObterCaptionAplicacao: string; static;
      class function ExecutarInterno(const aConfig: tConfigDialogoProjeto;
         bNotificarSeSemFoco: Boolean; const sIdentificadorNotificacao: string): Integer; static;
      class function GerarIdentificadorNotificacao(const sPrefixo: string): string; static;
      class procedure GarantirControleNotificacoes; static;
      class procedure RegistrarDialogoPendente(const sIdentificador: string;
         const aConfig: tConfigDialogoProjeto); static;
      class procedure RemoverDialogoPendente(const sIdentificador: string); static;
      class procedure AgendarExibicaoDialogo(const aConfig: tConfigDialogoProjeto;
         bForcarFoco: Boolean = False); static;
      class procedure ExibirDialogoPendente(const sIdentificador: string;
         bForcarFoco: Boolean = False); static;
      class procedure ForcarFocoAplicacao; static;
   public
      class procedure Aviso(const sTexto: string; const sCabecalho: string = 'Atenção';
         const sDetalhes: string = ''; const sRodape: string = '';
         bNotificarSeSemFoco: Boolean = False); static;
      class procedure Erro(const sTexto: string; const sCabecalho: string = 'Erro';
         const sDetalhes: string = ''; const sRodape: string = '';
         bNotificarSeSemFoco: Boolean = False); static;
      class procedure Informacao(const sTexto: string;
         const sCabecalho: string = 'Informação'; const sDetalhes: string = '';
         const sRodape: string = ''; bNotificarSeSemFoco: Boolean = False); static;
      class function Confirmar(const sTexto: string;
         const sCabecalho: string = 'Confirmação';
         aBotaoPadrao: tBotaoConfirmacaoPadrao = bcpSim): Boolean; static;
      class procedure CampoObrigatorio(const sCampo: string); static;
      class procedure CaminhoNaoEncontrado(const sCaminho: string); static;
      class procedure NenhumProjetoSelecionado(const sAcao: string); static;
      class procedure ResumoLimpeza(iProjetos, iArquivos, iFalhas: Integer); static;
      class procedure AplicacaoJaEmExecucao; static;
      class procedure ProcessarDialogosPendentes; static;
   end;

implementation

uses
   Winapi.Windows,
   System.Classes,
   System.SysUtils,
   Vcl.Forms,
   UntClassNotificacaoWindows;

class procedure tDialogos.AgendarExibicaoDialogo(
   const aConfig: tConfigDialogoProjeto; bForcarFoco: Boolean);
begin
   TThread.ForceQueue(nil,
      procedure
      begin
         if Assigned(Application.MainForm) then begin
            Application.Restore;

            if Application.MainForm.WindowState = wsMinimized then begin
               Application.MainForm.WindowState := wsNormal;
            end;

            Application.MainForm.Show;

            if bForcarFoco then begin
               ForcarFocoAplicacao;
            end;
         end;

         tFrmDlgPadrao.Executar(aConfig);
      end
      );
end;

class procedure tDialogos.AplicacaoJaEmExecucao;
begin
   Aviso(
      'A aplicação já está em execução.',
      'Instância já iniciada',
      'Feche a instância atual antes de abrir outra.'
      );
end;

class procedure tDialogos.Aviso(const sTexto, sCabecalho, sDetalhes,
   sRodape: string; bNotificarSeSemFoco: Boolean);
var
   aConfig: tConfigDialogoProjeto;
begin
   aConfig.CaptionAplicacao := ObterCaptionAplicacao;
   aConfig.Cabecalho := ObterCabecalho(sCabecalho, 'Atenção');
   aConfig.Texto := sTexto;
   aConfig.Detalhes := sDetalhes;
   aConfig.Rodape := sRodape;
   aConfig.Tipo := tdpAviso;
   aConfig.Botoes := [bdpOk];
   aConfig.BotaoPadrao := mrOk;
   ExecutarInterno(aConfig, bNotificarSeSemFoco, 'AVISO');
end;

class procedure tDialogos.CaminhoNaoEncontrado(const sCaminho: string);
begin
   Aviso(
      'O caminho informado para o projeto não foi encontrado.',
      'Caminho inválido',
      'Verifique se a pasta ainda existe e se o caminho salvo está correto:' +
      sLineBreak + sCaminho,
      'A limpeza deste projeto foi ignorada nesta execução.',
      True
      );
end;

class procedure tDialogos.CampoObrigatorio(const sCampo: string);
begin
   Aviso('Preencha o campo obrigatório para continuar.', 'Dados incompletos',
      'Campo pendente: ' + sCampo);
end;

class function tDialogos.Confirmar(const sTexto, sCabecalho: string;
   aBotaoPadrao: tBotaoConfirmacaoPadrao): Boolean;
var
   aConfig: tConfigDialogoProjeto;
begin
   aConfig.CaptionAplicacao := ObterCaptionAplicacao;
   aConfig.Cabecalho := ObterCabecalho(sCabecalho, 'Confirmação');
   aConfig.Texto := sTexto;
   aConfig.Detalhes := '';
   aConfig.Rodape := '';
   aConfig.Tipo := tdpConfirmacao;
   aConfig.Botoes := [bdpSim, bdpNao];

   if aBotaoPadrao = bcpNao then begin
      aConfig.BotaoPadrao := mrNo;
   end else begin
      aConfig.BotaoPadrao := mrYes;
   end;

   Result := ExecutarInterno(aConfig, False, '') = mrYes;
end;

class procedure tDialogos.Erro(const sTexto, sCabecalho, sDetalhes,
   sRodape: string; bNotificarSeSemFoco: Boolean);
var
   aConfig: tConfigDialogoProjeto;
begin
   aConfig.CaptionAplicacao := ObterCaptionAplicacao;
   aConfig.Cabecalho := ObterCabecalho(sCabecalho, 'Erro');
   aConfig.Texto := sTexto;
   aConfig.Detalhes := sDetalhes;
   aConfig.Rodape := sRodape;
   aConfig.Tipo := tdpErro;
   aConfig.Botoes := [bdpOk];
   aConfig.BotaoPadrao := mrOk;
   ExecutarInterno(aConfig, bNotificarSeSemFoco, 'ERRO');
end;

class procedure tDialogos.ExibirDialogoPendente(const sIdentificador: string;
   bForcarFoco: Boolean);
var
   aDialogoPendente: tDialogoPendente;
   aConfig: tConfigDialogoProjeto;
begin
   GarantirControleNotificacoes;

   if Trim(sIdentificador) = '' then begin
      ProcessarDialogosPendentes;
      Exit;
   end;

   aDialogoPendente := nil;

   if aDialogosPendentes.TryGetValue(sIdentificador, aDialogoPendente) then begin
      aConfig := aDialogoPendente.Config;
      aDialogosPendentes.Remove(sIdentificador);
      tNotificacaoWindows.Cancelar(sIdentificador);
      AgendarExibicaoDialogo(aConfig, bForcarFoco);
   end else if aDialogosPendentes.Count > 0 then begin
      ProcessarDialogosPendentes;
   end;
end;

class function tDialogos.ExecutarInterno(const aConfig: tConfigDialogoProjeto;
   bNotificarSeSemFoco: Boolean; const sIdentificadorNotificacao: string): Integer;
var
   bUsouNotificacao: Boolean;
   sIdentificadorGerado: string;
begin
   bUsouNotificacao := False;
   sIdentificadorGerado := '';

   if bNotificarSeSemFoco then begin
      sIdentificadorGerado := GerarIdentificadorNotificacao(sIdentificadorNotificacao);
      RegistrarDialogoPendente(sIdentificadorGerado, aConfig);
      bUsouNotificacao := tNotificacaoWindows.EnviarSeAplicacaoNaoEstiverEmFoco(
         aConfig.Cabecalho,
         aConfig.Texto,
         sIdentificadorGerado
         );

      if not bUsouNotificacao then begin
         RemoverDialogoPendente(sIdentificadorGerado);
      end;
   end;

   if bUsouNotificacao then begin
      Result := mrOk;
   end else begin
      Result := tFrmDlgPadrao.Executar(aConfig);
   end;
end;

class procedure tDialogos.ForcarFocoAplicacao;
var
   hJanela: HWND;
   hJanelaForeground: HWND;
   iThreadAtual: DWORD;
   iThreadForeground: DWORD;
   bThreadsAnexadas: Boolean;
begin
   if not Assigned(Application.MainForm) then begin
      Exit;
   end;

   hJanela := Application.MainForm.Handle;
   if hJanela = 0 then begin
      Exit;
   end;

   if IsIconic(hJanela) then begin
      ShowWindow(hJanela, SW_RESTORE);
   end else begin
      ShowWindow(hJanela, SW_SHOW);
   end;

   hJanelaForeground := GetForegroundWindow;
   iThreadAtual := GetCurrentThreadId;
   iThreadForeground := 0;
   bThreadsAnexadas := False;

   if (hJanelaForeground <> 0) and (hJanelaForeground <> hJanela) then begin
      iThreadForeground := GetWindowThreadProcessId(hJanelaForeground, nil);

      if (iThreadForeground <> 0) and (iThreadForeground <> iThreadAtual) then begin
         bThreadsAnexadas := AttachThreadInput(iThreadAtual, iThreadForeground, True);
      end;
   end;

   try
      SetWindowPos(hJanela, HWND_TOP, 0, 0, 0, 0,
         SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
      BringWindowToTop(hJanela);
      SetForegroundWindow(hJanela);
      SetActiveWindow(hJanela);
      Application.MainForm.BringToFront;
      Application.BringToFront;
   finally
      if bThreadsAnexadas then begin
         AttachThreadInput(iThreadAtual, iThreadForeground, False);
      end;
   end;
end;

class function tDialogos.GerarIdentificadorNotificacao(
   const sPrefixo: string): string;
var
   sBase: string;
begin
   sBase := Trim(UpperCase(sPrefixo));
   if sBase = '' then begin
      sBase := 'DIALOGO';
   end;

   Result := sBase + '_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now) +
      '_' + IntToHex(GetTickCount, 8);
end;

class procedure tDialogos.GarantirControleNotificacoes;
begin
   if not Assigned(aDialogosPendentes) then begin
      aDialogosPendentes := TObjectDictionary<string, tDialogoPendente>.Create([doOwnsValues]);
   end;

   if not bControleNotificacaoInicializado then begin
      tNotificacaoWindows.DefinirAcaoClique(
         procedure(const sIdentificador: string)
         begin
            ExibirDialogoPendente(sIdentificador, True);
         end
         );
      bControleNotificacaoInicializado := True;
   end;
end;

class procedure tDialogos.Informacao(const sTexto, sCabecalho, sDetalhes,
   sRodape: string; bNotificarSeSemFoco: Boolean);
var
   aConfig: tConfigDialogoProjeto;
begin
   aConfig.CaptionAplicacao := ObterCaptionAplicacao;
   aConfig.Cabecalho := ObterCabecalho(sCabecalho, 'Informação');
   aConfig.Texto := sTexto;
   aConfig.Detalhes := sDetalhes;
   aConfig.Rodape := sRodape;
   aConfig.Tipo := tdpInformacao;
   aConfig.Botoes := [bdpOk];
   aConfig.BotaoPadrao := mrOk;
   ExecutarInterno(aConfig, bNotificarSeSemFoco, 'INFO');
end;

class procedure tDialogos.NenhumProjetoSelecionado(const sAcao: string);
begin
   Aviso('Nenhum projeto foi selecionado para ' + sAcao + '.', 'Nenhum projeto selecionado');
end;

class function tDialogos.ObterCabecalho(const sCabecalho,
   sPadrao: string): string;
begin
   Result := Trim(sCabecalho);
   if Result = '' then begin
      Result := sPadrao;
   end;
end;

class function tDialogos.ObterCaptionAplicacao: string;
begin
   Result := Trim(Application.Title);
   if Result = '' then begin
      Result := 'LimpaDCU';
   end;
end;

class procedure tDialogos.ProcessarDialogosPendentes;
var
   aIdentificadores: TArray<string>;
   sIdentificador: string;
begin
   GarantirControleNotificacoes;

   if not Assigned(aDialogosPendentes) or (aDialogosPendentes.Count = 0) then begin
      Exit;
   end;

   aIdentificadores := aDialogosPendentes.Keys.ToArray;
   for sIdentificador in aIdentificadores do begin
      ExibirDialogoPendente(sIdentificador);
   end;
end;

class procedure tDialogos.RegistrarDialogoPendente(const sIdentificador: string;
   const aConfig: tConfigDialogoProjeto);
var
   aDialogoPendente: tDialogoPendente;
begin
   GarantirControleNotificacoes;
   RemoverDialogoPendente(sIdentificador);
   aDialogoPendente := tDialogoPendente.Create;
   aDialogoPendente.Config := aConfig;
   aDialogosPendentes.Add(sIdentificador, aDialogoPendente);
end;

class procedure tDialogos.RemoverDialogoPendente(const sIdentificador: string);
begin
   if Assigned(aDialogosPendentes) and
      aDialogosPendentes.ContainsKey(sIdentificador) then begin
      aDialogosPendentes.Remove(sIdentificador);
   end;
end;

class procedure tDialogos.ResumoLimpeza(iProjetos, iArquivos,
   iFalhas: Integer);
var
   sDetalhes: string;
   sRodape: string;
   sTexto: string;
begin
   sTexto := 'Processo de exclusão dos DCUs concluído.';
   sDetalhes := Format(
      'Projetos processados: %d%sArquivos removidos: %d%sFalhas encontradas: %d', [
      iProjetos,
      sLineBreak,
      iArquivos,
      sLineBreak,
      iFalhas
      ]
      );

   if iFalhas > 0 then begin
      sRodape := 'Confira o log para localizar os arquivos que não puderam ser removidos.';
   end else begin
      sRodape := 'Nenhuma falha foi identificada nesta execução.';
   end;

   Informacao(sTexto, 'Limpeza finalizada', sDetalhes, sRodape, True);
end;

initialization

finalization
   tNotificacaoWindows.DefinirAcaoClique(nil);
   FreeAndNil(tDialogos.aDialogosPendentes);

end.
