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
      class procedure Inicializar; static;
      class procedure Finalizar; static;
      class function AplicacaoEmFoco: Boolean; static;
      class function Enviar(const sTitulo, sTexto: string;
         const sIdentificador: string = ''; bSom: Boolean = True): Boolean; static;
      class function EnviarSeAplicacaoNaoEstiverEmFoco(const sTitulo, sTexto: string;
         const sIdentificador: string = ''; bSom: Boolean = True): Boolean; static;
      class procedure Cancelar(const sIdentificador: string); static;
      class procedure CancelarTodas; static;
      class procedure DefinirAcaoClique(const aAcao: tOnCliqueNotificacaoWindows); static;
   end;

implementation

uses
   System.SysUtils,
   Vcl.Forms;

procedure tRecebedorNotificacaoWindows.ReceberNotificacaoLocal(Sender: TObject;
   ANotification: TNotification);
begin
   if Assigned(ANotification) then begin
      tNotificacaoWindows.TratarCliqueNotificacao(ANotification.Name);
   end;
end;

class function tNotificacaoWindows.AplicacaoEmFoco: Boolean;
var
   hJanelaForeground: HWND;
   iProcessoJanelaForeground: DWORD;
   iProcessoAtual: DWORD;
begin
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

class procedure tNotificacaoWindows.Cancelar(const sIdentificador: string);
begin
   if Trim(sIdentificador) = '' then begin
      Exit;
   end;

   GarantirInicializado;

   if Assigned(aNotificationCenter) then begin
      try
         aNotificationCenter.CancelNotification(sIdentificador);
      except
         // A Central de Notificações pode rejeitar cancelamentos fora de contexto.
      end;
   end;
end;

class procedure tNotificacaoWindows.CancelarTodas;
begin
   GarantirInicializado;

   if Assigned(aNotificationCenter) then begin
      try
         aNotificationCenter.CancelAll;
      except
         // Falha de notificação não deve impedir o encerramento da aplicação.
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
begin
   Result := False;

   if not SistemaSuportaNotificacao then begin
      Exit;
   end;

   GarantirInicializado;

   if not Assigned(aNotificationCenter) then begin
      Exit;
   end;

   try
      sNome := Trim(sIdentificador);

      if sNome = '' then begin
         sNome := GerarIdentificador('LIMPA_DCU');
      end;

      aNotificacao := aNotificationCenter.CreateNotification;
      try
         aNotificacao.Name := sNome;
         aNotificacao.Title := sTitulo;
         aNotificacao.AlertBody := sTexto;
         aNotificacao.EnableSound := bSom;
         aNotificationCenter.PresentNotification(aNotificacao);
         Result := True;
      finally
         FreeAndNil(aNotificacao);
      end;
   except
      Result := False;
   end;
end;

class function tNotificacaoWindows.EnviarSeAplicacaoNaoEstiverEmFoco(
   const sTitulo, sTexto, sIdentificador: string; bSom: Boolean): Boolean;
begin
   Result := False;

   if not AplicacaoEmFoco then begin
      Result := Enviar(sTitulo, sTexto, sIdentificador, bSom);
   end;
end;

class procedure tNotificacaoWindows.Finalizar;
begin
   fOnCliqueNotificacao := nil;

   if Assigned(aNotificationCenter) then begin
      try
         aNotificationCenter.CancelAll;
      except
         // Melhor esforço durante a finalização.
      end;
   end;

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
   Result := sPrefixo + '_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now) +
      '_' + IntToHex(GetTickCount, 8);
end;

class procedure tNotificacaoWindows.Inicializar;
begin
   GarantirInicializado;
end;

class function tNotificacaoWindows.SistemaSuportaNotificacao: Boolean;
begin
   Result := (TOSVersion.Platform = pfWindows) and TOSVersion.Check(6, 2);
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
