unit UntTemaAplicacao;

interface

uses
   Winapi.Windows,
   System.SysUtils,
   System.Types,
   System.Win.Registry,
   Vcl.Graphics,
   Vcl.Themes;

type
   tModoTema = (mtSeguirWindows, mtClaro, mtEscuro);

   tTemaAplicacao = class
   private
      class var bTemaEscuro: Boolean;
      class function WindowsUsaTemaClaroApps: Boolean; static;
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
      class procedure DesenharCheckBoxGrid(aCanvas: TCanvas; const aRect: TRect;
         const bMarcado, bHabilitado: Boolean); static;
      class procedure PrepararCanvasGrid(aCanvas: TCanvas;
         const bSelecionado, bLinhaPar: Boolean); static;
   end;

implementation

uses
   UntDtmCnx;

const
   REG_PERSONALIZE = '\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';
   CHAVE_CFG_TEMA = 'TEMA';
   CFG_TEMA_CLARO = '0';
   CFG_TEMA_ESCURO = '1';

class procedure tTemaAplicacao.Aplicar(aModo: tModoTema;
   bSalvarPreferencia: Boolean);
begin
   if aModo = mtSeguirWindows then begin
      if WindowsUsaTemaClaroApps then begin
         aModo := mtClaro;
      end else begin
         aModo := mtEscuro;
      end;
   end;

   bTemaEscuro := aModo = mtEscuro;

   if bSalvarPreferencia then begin
      SalvarModo(aModo);
   end;
end;

class procedure tTemaAplicacao.AplicarTemaInicial;
var
   aModo: tModoTema;
begin
   if not LerModoSalvo(aModo) then begin
      aModo := mtSeguirWindows;
   end;

   Aplicar(aModo, False);
end;

class function tTemaAplicacao.CorEdit: TColor;
begin
   if bTemaEscuro then begin
      Result := RGB(37, 39, 42);
   end else begin
      Result := clWindow;
   end;
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

class function tTemaAplicacao.CorSelecao: TColor;
begin
   Result := StyleServices.GetSystemColor(clHighlight);
end;

class function tTemaAplicacao.CorTexto: TColor;
begin
   if bTemaEscuro then begin
      Result := RGB(235, 235, 235);
   end else begin
      Result := clBlack;
   end;
end;

class function tTemaAplicacao.CorTextoSelecao: TColor;
begin
   Result := StyleServices.GetSystemColor(clHighlightText);
end;

class procedure tTemaAplicacao.DesenharCheckBoxGrid(aCanvas: TCanvas;
   const aRect: TRect; const bMarcado, bHabilitado: Boolean);
var
   aDetalhes: TThemedElementDetails;
   aTamanho: TSize;
   aRectCheck: TRect;
   iEsquerda: Integer;
   iTopo: Integer;
begin
   aDetalhes := ObterDetalhesCheckBox(bMarcado, bHabilitado);

   if not StyleServices.GetElementSize(aCanvas.Handle, aDetalhes, esActual, aTamanho) then begin
      aTamanho.cx := 13;
      aTamanho.cy := 13;
   end;

   iEsquerda := aRect.Left + ((aRect.Width - aTamanho.cx) div 2);
   iTopo := aRect.Top + ((aRect.Height - aTamanho.cy) div 2);
   aRectCheck := Rect(iEsquerda, iTopo, iEsquerda + aTamanho.cx, iTopo + aTamanho.cy);
   StyleServices.DrawElement(aCanvas.Handle, aDetalhes, aRectCheck);
end;

class function tTemaAplicacao.LerModoSalvo(out aModo: tModoTema): Boolean;
var
   sValor: string;
begin
   Result := False;
   aModo := mtSeguirWindows;

   if not Assigned(dtmCnx) then begin
      Exit;
   end;

   sValor := dtmCnx.LerConfiguracao(CHAVE_CFG_TEMA, '');

   if sValor = CFG_TEMA_CLARO then begin
      aModo := mtClaro;
      Result := True;
   end else if sValor = CFG_TEMA_ESCURO then begin
      aModo := mtEscuro;
      Result := True;
   end;
end;

class function tTemaAplicacao.ObterDetalhesCheckBox(const bMarcado,
   bHabilitado: Boolean): TThemedElementDetails;
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

class procedure tTemaAplicacao.PrepararCanvasGrid(aCanvas: TCanvas;
   const bSelecionado, bLinhaPar: Boolean);
begin
   if bSelecionado then begin
      aCanvas.Brush.Color := CorSelecao;
      aCanvas.Font.Color := CorTextoSelecao;
   end else begin
      if bLinhaPar then begin
         aCanvas.Brush.Color := CorFundoAlternado;
      end else begin
         aCanvas.Brush.Color := CorFundo;
      end;
      aCanvas.Font.Color := CorTexto;
   end;
end;

class procedure tTemaAplicacao.SalvarModo(const aModo: tModoTema);
begin
   if not Assigned(dtmCnx) then begin
      Exit;
   end;

   case aModo of
      mtClaro:
         dtmCnx.GravarConfiguracao(CHAVE_CFG_TEMA, CFG_TEMA_CLARO);
      mtEscuro:
         dtmCnx.GravarConfiguracao(CHAVE_CFG_TEMA, CFG_TEMA_ESCURO);
   end;
end;

class function tTemaAplicacao.TemaEscuro: Boolean;
begin
   Result := bTemaEscuro;
end;

class function tTemaAplicacao.WindowsUsaTemaClaroApps: Boolean;
var
   aReg: TRegistry;
begin
   Result := True;
   aReg := TRegistry.Create(KEY_READ);
   try
      aReg.RootKey := HKEY_CURRENT_USER;
      if aReg.OpenKeyReadOnly(REG_PERSONALIZE) and
         aReg.ValueExists('AppsUseLightTheme') then begin
         Result := aReg.ReadInteger('AppsUseLightTheme') <> 0;
      end;
   finally
      FreeAndNil(aReg);
   end;
end;

end.
