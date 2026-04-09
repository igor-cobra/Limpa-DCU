unit UntClassDialogos;
interface
uses
   System.UITypes, UntDlgPadrao, System.Generics.Collections;
type
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

      class procedure GarantirControleNotificacoes; static;
      class function GerarIdentificadorNotificacao(const sPrefixo: string): string; static;
      class procedure RegistrarDialogoPendente(const sIdentificador: string; const aConfig: tConfigDialogoProjeto); static;
      class procedure RemoverDialogoPendente(const sIdentificador: string); static;
      class procedure ExibirDialogoPendente(const sIdentificador: string); static;
   public
      class procedure Aviso(const sTexto: string; const sCabecalho: string = 'Atenção';
         const sDetalhes: string = ''; const sRodape: string = ''; bNotificarSeSemFoco: Boolean = False); static;
      class procedure Erro(const sTexto: string; const sCabecalho: string = 'Erro';
         const sDetalhes: string = ''; const sRodape: string = ''; bNotificarSeSemFoco: Boolean = False); static;
      class procedure Informacao(const sTexto: string; const sCabecalho: string = 'Informação';
         const sDetalhes: string = ''; const sRodape: string = ''; bNotificarSeSemFoco: Boolean = False); static;
      class function Confirmar(const sTexto: string; const sCabecalho: string = 'Confirmação';
         iBotaoDefault: Integer = 0): Boolean; static;
      class function ExecutarCustomizado(const aConfig: tConfigDialogoProjeto;
         bNotificarSeSemFoco: Boolean = False; const sIdentificadorNotificacao: string = ''): Integer; static;
      class procedure CampoObrigatorio(const sCampo: string); static;
      class procedure CaminhoNaoEncontrado(const sCaminho: string); static;
      class procedure NenhumProjetoSelecionado(const sAcao: string); static;
      class procedure ResumoLimpeza(iProjetos, iArquivos, iFalhas: Integer); static;
      class procedure AplicacaoJaEmExecucao; static;
   end;
implementation
uses
   System.SysUtils, Vcl.Forms, UntClassNotificacaoWindows, Winapi.Windows, System.Classes;
const
   BTN_DEFAULT_SIM = 0;
   BTN_DEFAULT_NAO = 1;
{ tDialogos }
class procedure tDialogos.AplicacaoJaEmExecucao;
begin
   Aviso(
      'A aplicação já está em execução.',
      'Instância já iniciada',
      'Feche a instância atual antes de abrir outra. Caso a aplicação tenha ficado presa em segundo plano, finalize-a pelo Gerenciador de Tarefas e tente novamente.'
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
      'Verifique se a pasta ainda existe e se o caminho salvo está correto:' + sLineBreak + sCaminho,
      'A limpeza deste projeto foi ignorada nesta execução.',
      True
      );
end;
class procedure tDialogos.CampoObrigatorio(const sCampo: string);
begin
   Aviso(
      'Preencha o campo obrigatório para continuar.',
      'Dados incompletos',
      'Campo pendente: ' + sCampo
      );
end;
class function tDialogos.Confirmar(const sTexto, sCabecalho: string;
   iBotaoDefault: Integer): Boolean;
var
   aConfig: tConfigDialogoProjeto;
   iResultado: Integer;
begin
   aConfig.CaptionAplicacao := ObterCaptionAplicacao;
   aConfig.Cabecalho := ObterCabecalho(sCabecalho, 'Confirmação');
   aConfig.Texto := sTexto;
   aConfig.Detalhes := '';
   aConfig.Rodape := '';
   aConfig.Tipo := tdpConfirmacao;
   aConfig.Botoes := [bdpSim, bdpNao];
   if iBotaoDefault = BTN_DEFAULT_NAO then begin
      aConfig.BotaoPadrao := mrNo;
   end else begin
      aConfig.BotaoPadrao := mrYes;
   end;
   iResultado := ExecutarInterno(aConfig, False, '');
   Result := iResultado = mrYes;
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
class function tDialogos.ExecutarCustomizado(
   const aConfig: tConfigDialogoProjeto; bNotificarSeSemFoco: Boolean;
   const sIdentificadorNotificacao: string): Integer;
begin
   Result := ExecutarInterno(aConfig, bNotificarSeSemFoco, sIdentificadorNotificacao);
end;
class procedure tDialogos.ExibirDialogoPendente(const sIdentificador: string);
var
   aDialogoPendente: tDialogoPendente;
   aConfig: tConfigDialogoProjeto;
begin
   GarantirControleNotificacoes;

   aDialogoPendente := nil;

   if aDialogosPendentes.TryGetValue(sIdentificador, aDialogoPendente) then begin
      aConfig := aDialogoPendente.Config;
      aDialogosPendentes.Remove(sIdentificador);

      TThread.Queue(nil,
         procedure
         begin
            if Assigned(Application.MainForm) then begin
               if Application.MainForm.WindowState = wsMinimized then begin
                  Application.MainForm.WindowState := wsNormal;
               end;

               Application.MainForm.Show;
               Application.MainForm.BringToFront;
               SetForegroundWindow(Application.MainForm.Handle);
            end;

            Application.Restore;
            Application.BringToFront;
            tFrmDlgPadrao.Executar(aConfig);
         end
         );
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

   Result := sBase + '_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now);
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
            ExibirDialogoPendente(sIdentificador);
         end
         );

      bControleNotificacaoInicializado := True;
   end;
end;

class procedure tDialogos.RegistrarDialogoPendente(
   const sIdentificador: string; const aConfig: tConfigDialogoProjeto);
var
   aDialogoPendente: tDialogoPendente;
begin
   GarantirControleNotificacoes;
   RemoverDialogoPendente(sIdentificador);

   aDialogoPendente := tDialogoPendente.Create;
   aDialogoPendente.Config := aConfig;

   aDialogosPendentes.Add(sIdentificador, aDialogoPendente);
end;

class procedure tDialogos.RemoverDialogoPendente(
   const sIdentificador: string);
begin
   if Assigned(aDialogosPendentes) then begin
      if aDialogosPendentes.ContainsKey(sIdentificador) then begin
         aDialogosPendentes.Remove(sIdentificador);
      end;
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
   Aviso(
      'Nenhum projeto foi selecionado.',
      'Seleção obrigatória',
      'Selecione ao menos um projeto para ' + sAcao + '.'
      );
end;
class function tDialogos.ObterCabecalho(const sCabecalho,
   sPadrao: string): string;
begin
   if Trim(sCabecalho) = '' then begin
      Result := sPadrao;
   end else begin
      Result := sCabecalho;
   end;
end;
class function tDialogos.ObterCaptionAplicacao: string;
begin
   Result := '';
   if Assigned(Application.MainForm) and (Trim(Application.MainForm.Caption) <> '') then begin
      Result := Application.MainForm.Caption;
   end;
   if Trim(Result) = '' then begin
      Result := Application.Title;
   end;
   if Trim(Result) = '' then begin
      Result := ChangeFileExt(ExtractFileName(Application.ExeName), '');
   end;
end;
class procedure tDialogos.ResumoLimpeza(iProjetos, iArquivos, iFalhas: Integer);
var
   sTexto: string;
   sDetalhes: string;
   sRodape: string;
begin
   sTexto := 'Processo de exclusão dos DCUs concluído.';
   sDetalhes :=
   'Projetos processados: ' + IntToStr(iProjetos) + sLineBreak +
   'Arquivos removidos: ' + IntToStr(iArquivos) + sLineBreak +
   'Falhas encontradas: ' + IntToStr(iFalhas);
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
