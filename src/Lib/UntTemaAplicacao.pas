unit UntTemaAplicacao;

interface

uses
   Winapi.Windows,
   System.SysUtils,
   System.Types,
   System.Win.Registry,
   Vcl.Graphics,
   Vcl.Themes,
   Vcl.Styles;

type
   tModoTema = (mtSeguirWindows, mtClaro, mtEscuro);

   tTemaAplicacao = class
   private
      class var bTemaEscuro: Boolean;
      class function WindowsUsaTemaClaroApps: Boolean; static;
      class function CarregarStyle(const sNomeArquivo: string; out aHandle: TStyleManager.TStyleServicesHandle): Boolean; static;
      class function AplicarStyleArquivo(const sNomeArquivo: string): Boolean; static;
      class function ObterNomeStyle(const sNomeArquivo: string): string; static;
      class function LerModoSalvo(out aModo: tModoTema): Boolean; static;
      class procedure SalvarModo(const aModo: tModoTema); static;
   public
      class procedure AplicarTemaInicial; static;
      class procedure Aplicar(aModo: tModoTema; bSalvarPreferencia: Boolean = True); static;

      class function TemaEscuro: Boolean; static;

      class function CorFundo: TColor; static;
      class function CorFundoAlternado: TColor; static;
      class function CorTexto: TColor; static;
      class function CorSelecao: TColor; static;
      class function CorTextoSelecao: TColor; static;
      class function CorEdit: TColor; static;

      class function ObterDetalhesCheckBox(const bMarcado, bHabilitado: Boolean): TThemedElementDetails; static;
      class procedure DesenharCheckBoxGrid(aCanvas: TCanvas; const aRect: TRect; const bMarcado, bHabilitado: Boolean); static;
      class procedure PrepararCanvasGrid(aCanvas: TCanvas; const bSelecionado, bLinhaPar: Boolean); static;
   end;

implementation

uses
   UntDtmCnx, UntLib;

const
   REG_PERSONALIZE = '\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';

   ARQ_STYLE_CLARO  = 'AquaLightSlate.vsf';
   ARQ_STYLE_ESCURO = 'Glow.vsf';

   NOME_STYLE_CLARO  = 'Aqua Light Slate';
   NOME_STYLE_ESCURO = 'Glow';

   CHAVE_CFG_TEMA  = 'TEMA';
   CFG_TEMA_CLARO  = '0';
   CFG_TEMA_ESCURO = '1';

{ tTemaAplicacao }

class procedure tTemaAplicacao.AplicarTemaInicial;
var
   aModo: tModoTema;
begin
   if not LerModoSalvo(aModo) then begin
      if WindowsUsaTemaClaroApps then begin
         aModo := mtClaro;
      end else begin
         aModo := mtEscuro;
      end;

      Aplicar(aModo, True);
      Exit;
   end;

   Aplicar(aModo, False);
end;

class procedure tTemaAplicacao.Aplicar(aModo: tModoTema; bSalvarPreferencia: Boolean = True);
begin
   case aModo of
      mtClaro: begin
         bTemaEscuro := False;
         if not AplicarStyleArquivo(ARQ_STYLE_CLARO) then begin
            TStyleManager.TrySetStyle('Windows');
         end;
      end;

      mtEscuro: begin
         bTemaEscuro := True;
         if not AplicarStyleArquivo(ARQ_STYLE_ESCURO) then begin
            TStyleManager.TrySetStyle('Windows');
         end;
      end;

      mtSeguirWindows: begin
         if WindowsUsaTemaClaroApps then begin
            Aplicar(mtClaro, bSalvarPreferencia);
         end else begin
            Aplicar(mtEscuro, bSalvarPreferencia);
         end;
         Exit;
      end;
   end;

   if bSalvarPreferencia and (aModo in [mtClaro, mtEscuro]) then begin
      SalvarModo(aModo);
   end;
end;

class function tTemaAplicacao.ObterNomeStyle(const sNomeArquivo: string): string;
begin
   if SameText(sNomeArquivo, ARQ_STYLE_CLARO) then begin
      Result := NOME_STYLE_CLARO;
   end else if SameText(sNomeArquivo, ARQ_STYLE_ESCURO) then begin
      Result := NOME_STYLE_ESCURO;
   end else begin
      Result := ChangeFileExt(ExtractFileName(sNomeArquivo), '');
   end;
end;

class function tTemaAplicacao.CarregarStyle(const sNomeArquivo: string; out aHandle: TStyleManager.TStyleServicesHandle): Boolean;
var
   sArquivo: string;
begin
   Result := False;
   aHandle := Default(TStyleManager.TStyleServicesHandle);

   sArquivo := PASTA_STYLE + sNomeArquivo;

   if not FileExists(sArquivo) then Exit;
   if not TStyleManager.IsValidStyle(sArquivo) then Exit;

   aHandle := TStyleManager.LoadFromFile(sArquivo);
   Result := aHandle <> nil;
end;

class function tTemaAplicacao.AplicarStyleArquivo(const sNomeArquivo: string): Boolean;
var
   aHandle: TStyleManager.TStyleServicesHandle;
   sNomeStyle: string;
begin
   Result := False;
   sNomeStyle := ObterNomeStyle(sNomeArquivo);

   if (sNomeStyle <> '') and TStyleManager.TrySetStyle(sNomeStyle, False) then begin
      Result := True;
      Exit;
   end;

   try
      if not CarregarStyle(sNomeArquivo, aHandle) then Exit;

      TStyleManager.SetStyle(aHandle);
      Result := True;
   except
      on EDuplicateStyleException do begin
         Result := (sNomeStyle <> '') and TStyleManager.TrySetStyle(sNomeStyle, False);
      end;
      else begin
         Result := False;
      end;
   end;
end;

class function tTemaAplicacao.WindowsUsaTemaClaroApps: Boolean;
var
   aReg: TRegistry;
begin
   Result := True;

   aReg := TRegistry.Create(KEY_READ);
   try
      aReg.RootKey := HKEY_CURRENT_USER;

      if aReg.OpenKeyReadOnly(REG_PERSONALIZE) then begin
         if aReg.ValueExists('AppsUseLightTheme') then begin
            Result := aReg.ReadInteger('AppsUseLightTheme') <> 0;
         end;
      end;
   finally
      FreeAndNil(aReg);
   end;
end;

class function tTemaAplicacao.LerModoSalvo(out aModo: tModoTema): Boolean;
var
   sValor: string;
begin
   Result := False;
   aModo := mtSeguirWindows;

   if not Assigned(dtmCnx) then Exit;

   sValor := dtmCnx.LerConfiguracao(CHAVE_CFG_TEMA, '');

   if sValor = CFG_TEMA_CLARO then begin
      aModo := mtClaro;
      Result := True;
   end else if sValor = CFG_TEMA_ESCURO then begin
      aModo := mtEscuro;
      Result := True;
   end;
end;

class procedure tTemaAplicacao.SalvarModo(const aModo: tModoTema);
begin
   if not Assigned(dtmCnx) then Exit;

   case aModo of
      mtClaro:  dtmCnx.GravarConfiguracao(CHAVE_CFG_TEMA, CFG_TEMA_CLARO);
      mtEscuro: dtmCnx.GravarConfiguracao(CHAVE_CFG_TEMA, CFG_TEMA_ESCURO);
   end;
end;

class function tTemaAplicacao.TemaEscuro: Boolean;
begin
   Result := bTemaEscuro;
end;

class function tTemaAplicacao.CorFundo: TColor;
begin
   if bTemaEscuro then begin
      Result := RGB(32, 34, 37);
   end else begin
      Result := clWhite;
   end;
end;

class function tTemaAplicacao.CorFundoAlternado: TColor;
begin
   if bTemaEscuro then begin
      Result := RGB(43, 45, 49);
   end else begin
      Result := $00EAEAEA;
   end;
end;

class function tTemaAplicacao.CorTexto: TColor;
begin
   if bTemaEscuro then begin
      Result := RGB(235, 235, 235);
   end else begin
      Result := clBlack;
   end;
end;

class function tTemaAplicacao.CorSelecao: TColor;
begin
   Result := StyleServices.GetSystemColor(clHighlight);
end;

class function tTemaAplicacao.CorTextoSelecao: TColor;
begin
   Result := StyleServices.GetSystemColor(clHighlightText);
end;

class function tTemaAplicacao.ObterDetalhesCheckBox(const bMarcado, bHabilitado: Boolean): TThemedElementDetails;
begin
   if bMarcado then begin
      if bHabilitado then begin
         Result := StyleServices.GetElementDetails(tbCheckBoxCheckedNormal);
      end else begin
         Result := StyleServices.GetElementDetails(tbCheckBoxCheckedDisabled);
      end;
   end else begin
      if bHabilitado then begin
         Result := StyleServices.GetElementDetails(tbCheckBoxUncheckedNormal);
      end else begin
         Result := StyleServices.GetElementDetails(tbCheckBoxUncheckedDisabled);
      end;
   end;
end;

class procedure tTemaAplicacao.PrepararCanvasGrid(aCanvas: TCanvas; const bSelecionado, bLinhaPar: Boolean);
begin
   if bSelecionado then begin
      aCanvas.Brush.Color := CorSelecao;
      aCanvas.Font.Color  := CorTextoSelecao;
   end else begin
      if bLinhaPar then begin
         aCanvas.Brush.Color := CorFundoAlternado;
      end else begin
         aCanvas.Brush.Color := CorFundo;
      end;

      aCanvas.Font.Color := CorTexto;
   end;
end;

class procedure tTemaAplicacao.DesenharCheckBoxGrid(aCanvas: TCanvas; const aRect: TRect; const bMarcado, bHabilitado: Boolean);
var
   aDetalhes: TThemedElementDetails;
   aTamanho: TSize;
   aRectCheck: TRect;
   iLargura: Integer;
   iAltura: Integer;
   iEsquerda: Integer;
   iTopo: Integer;
begin
   aDetalhes := ObterDetalhesCheckBox(bMarcado, bHabilitado);

   if not StyleServices.GetElementSize(aCanvas.Handle, aDetalhes, esActual, aTamanho) then begin
      aTamanho.cx := 13;
      aTamanho.cy := 13;
   end;

   iLargura  := aTamanho.cx;
   iAltura   := aTamanho.cy;
   iEsquerda := aRect.Left + ((aRect.Width - iLargura) div 2);
   iTopo     := aRect.Top + ((aRect.Height - iAltura) div 2);

   aRectCheck := Rect(
      iEsquerda,
      iTopo,
      iEsquerda + iLargura,
      iTopo + iAltura
   );

   StyleServices.DrawElement(aCanvas.Handle, aDetalhes, aRectCheck);
end;

class function tTemaAplicacao.CorEdit: TColor;
begin
   if bTemaEscuro then begin
      Result := RGB(37, 39, 42);
   end else begin
      Result := clWindow;
   end;
end;

end.

