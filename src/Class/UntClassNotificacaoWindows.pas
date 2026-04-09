unit UntClassNotificacaoWindows;

interface

uses
   Winapi.Windows,
   System.Classes,
   System.Notification;

type
   tOnCliqueNotificacaoWindows = reference to procedure(const sIdentificador: string);

   tRecebedorNotificacaoWindows = class(TComponent)
   public
      procedure ReceberNotificacaoLocal(Sender: TObject; ANotification: TNotification);
   end;

   tNotificacaoWindows = class
   private
      class var aNotificationCenter: TNotificationCenter;
      class var aRecebedor: tRecebedorNotificacaoWindows;
      class var fOnCliqueNotificacao: tOnCliqueNotificacaoWindows;

      class function GerarIdentificador(const sPrefixo: string): string; static;
      class procedure GarantirInicializado; static;
      class function SistemaSuportaNotificacao: Boolean; static;
      class procedure TratarCliqueNotificacao(const sIdentificador: string); static;
   public
      class procedure Inicializar(aOwner: TComponent = nil); static;
      class procedure Finalizar; static;
      class function Suportado: Boolean; static;
      class function AplicacaoEmFoco: Boolean; static;
      class function Enviar(const sTitulo, sTexto: string; const sIdentificador: string = ''; bSom: Boolean = True): Boolean; static;
      class function EnviarSeAplicacaoNaoEstiverEmFoco(const sTitulo, sTexto: string; const sIdentificador: string = ''; bSom: Boolean = True): Boolean; static;
      class procedure CancelarTodas; static;
      class procedure DefinirAcaoClique(const aAcao: tOnCliqueNotificacaoWindows); static;
   end;

implementation

uses
   System.SysUtils,
   Vcl.Forms;

{ tRecebedorNotificacaoWindows }

procedure tRecebedorNotificacaoWindows.ReceberNotificacaoLocal(Sender: TObject;
   ANotification: TNotification);
begin
   if Assigned(ANotification) then begin
      tNotificacaoWindows.TratarCliqueNotificacao(ANotification.Name);
   end;
end;

{ tNotificacaoWindows }

class function tNotificacaoWindows.AplicacaoEmFoco: Boolean;
var
   hJanelaForeground: HWND;
   iProcessoJanelaForeground: DWORD;
   iProcessoAtual: DWORD;
begin
   Result := False;
   hJanelaForeground := GetForegroundWindow;
   iProcessoJanelaForeground := 0;
   iProcessoAtual := GetCurrentProcessId;

   if hJanelaForeground <> 0 then begin
      GetWindowThreadProcessId(hJanelaForeground, @iProcessoJanelaForeground);
      Result := iProcessoJanelaForeground = iProcessoAtual;
   end else begin
      Result := Application.Active;
   end;
end;

class procedure tNotificacaoWindows.CancelarTodas;
begin
   GarantirInicializado;

   if Assigned(aNotificationCenter) then begin
      try
         aNotificationCenter.CancelAll;
      except
         // ignora falhas do sistema de notificações
      end;
   end;
end;

class procedure tNotificacaoWindows.DefinirAcaoClique(
   const aAcao: tOnCliqueNotificacaoWindows);
begin
   fOnCliqueNotificacao := aAcao;
end;

class function tNotificacaoWindows.Enviar(const sTitulo, sTexto,
   sIdentificador: string; bSom: Boolean): Boolean;
var
   aNotificacao: TNotification;
   sNome: string;
   bResult: Boolean;
begin
   bResult := False;

   if SistemaSuportaNotificacao then begin
      GarantirInicializado;

      if Assigned(aNotificationCenter) then begin
         try
            sNome := Trim(sIdentificador);

            if sNome = '' then begin
               sNome := GerarIdentificador('LIMPA_DCU');
            end;

            aNotificacao := aNotificationCenter.CreateNotification;
            aNotificacao.Name := sNome;
            aNotificacao.Title := sTitulo;
            aNotificacao.AlertBody := sTexto;
            aNotificacao.EnableSound := bSom;

            aNotificationCenter.PresentNotification(aNotificacao);
            bResult := True;
         except
            bResult := False;
         end;
      end;
   end;

   Result := bResult;
end;

class function tNotificacaoWindows.EnviarSeAplicacaoNaoEstiverEmFoco(
   const sTitulo, sTexto, sIdentificador: string; bSom: Boolean): Boolean;
var
   bResult: Boolean;
begin
   bResult := False;

   if not AplicacaoEmFoco then begin
      bResult := Enviar(sTitulo, sTexto, sIdentificador, bSom);
   end;

   Result := bResult;
end;

class procedure tNotificacaoWindows.Finalizar;
begin
   fOnCliqueNotificacao := nil;
   FreeAndNil(aNotificationCenter);
   FreeAndNil(aRecebedor);
end;

class procedure tNotificacaoWindows.GarantirInicializado;
begin
   if not Assigned(aNotificationCenter) then begin
      aNotificationCenter := TNotificationCenter.Create(nil);
   end;

   if not Assigned(aRecebedor) then begin
      aRecebedor := tRecebedorNotificacaoWindows.Create(nil);
      aNotificationCenter.OnReceiveLocalNotification := aRecebedor.ReceberNotificacaoLocal;
   end;
end;

class function tNotificacaoWindows.GerarIdentificador(
   const sPrefixo: string): string;
begin
   Result := sPrefixo + '_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now);
end;

class procedure tNotificacaoWindows.Inicializar(aOwner: TComponent);
begin
   GarantirInicializado;
end;

class function tNotificacaoWindows.SistemaSuportaNotificacao: Boolean;
var
   bResult: Boolean;
begin
   bResult := TOSVersion.Platform = pfWindows;

   if bResult then begin
      bResult := TOSVersion.Check(6, 2);
   end;

   Result := bResult;
end;

class function tNotificacaoWindows.Suportado: Boolean;
begin
   Result := SistemaSuportaNotificacao;
end;

class procedure tNotificacaoWindows.TratarCliqueNotificacao(
   const sIdentificador: string);
begin
   if Assigned(fOnCliqueNotificacao) then begin
      fOnCliqueNotificacao(sIdentificador);
   end;
end;

initialization

finalization
   tNotificacaoWindows.Finalizar;

end.
