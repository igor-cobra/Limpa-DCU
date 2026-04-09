unit UntDlgPadrao;

interface

uses
   Winapi.Windows,
   System.Classes,
   System.SysUtils,
   System.Types,
   System.UITypes,
   Vcl.Controls,
   Vcl.ExtCtrls,
   Vcl.Forms,
   Vcl.Graphics,
   Vcl.StdCtrls;

type
   tTipoDialogoProjeto = (tdpInformacao, tdpAviso, tdpErro, tdpConfirmacao);

   tBotaoDialogoProjeto = (bdpOk, bdpSim, bdpNao, bdpCancelar);
   tBotoesDialogoProjeto = set of tBotaoDialogoProjeto;

   tConfigDialogoProjeto = record
      CaptionAplicacao: string;
      Cabecalho: string;
      Texto: string;
      Detalhes: string;
      Rodape: string;
      Tipo: tTipoDialogoProjeto;
      Botoes: tBotoesDialogoProjeto;
      BotaoPadrao: TModalResult;
   end;

   tFrmDlgPadrao = class(TForm)
      pnlFundo: TPanel;
      pnlTopo: TPanel;
      shpIcone: TShape;
      lblIcone: TLabel;
      lblCabecalho: TLabel;
      pnlConteudo: TPanel;
      lblTexto: TLabel;
      pnlDetalhes: TPanel;
      lblDetalhesTitulo: TLabel;
      mmoDetalhes: TMemo;
      pnlRodape: TPanel;
      lblRodape: TLabel;
      pnlBotoes: TPanel;
      bvlTopo: TBevel;
      bvlRodape: TBevel;
      procedure FormCreate(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
      FConfig: tConfigDialogoProjeto;
      procedure AjustarAlturaDialogo;
      procedure AplicarTema;
      procedure ConfigurarBotoes;
      procedure ConfigurarConteudo;
      function CorCard: TColor;
      function CorDestaqueTipo: TColor;
      function CorTextoSecundario: TColor;
      function CriarBotao(const sCaption: string; iModalResult, iLeft: Integer;
         bDefault, bCancel: Boolean): TButton;
      function ObterTextoIcone: string;
      function SomarAlturaTexto(const sTexto: string; aFonte: TFont; iLargura: Integer;
         iAlturaMinima: Integer): Integer;
   public
      class function Executar(const aConfig: tConfigDialogoProjeto): Integer; static;
      procedure Preparar(const aConfig: tConfigDialogoProjeto);
   end;

implementation

uses
   UntTemaAplicacao;

var
   frmDlgPadrao: tFrmDlgPadrao;

{$R *.dfm}

const
   LARGURA_DIALOGO = 520;
   ALTURA_MINIMA_DIALOGO = 220;
   ESPACAMENTO_PADRAO = 16;
   LARGURA_BOTAO = 88;
   ALTURA_BOTAO = 28;
   ESPACAMENTO_BOTAO = 8;

{ tFrmDlgPadrao }

procedure tFrmDlgPadrao.AjustarAlturaDialogo;
var
   iAlturaNecessaria: Integer;
begin
   iAlturaNecessaria := pnlTopo.Height +
                        lblTexto.Top + lblTexto.Height +
                        ESPACAMENTO_PADRAO;

   if pnlDetalhes.Visible then begin
      iAlturaNecessaria := iAlturaNecessaria + pnlDetalhes.Height + ESPACAMENTO_PADRAO;
   end;

   if pnlRodape.Visible then begin
      iAlturaNecessaria := iAlturaNecessaria + pnlRodape.Height;
   end;

   iAlturaNecessaria := iAlturaNecessaria + pnlBotoes.Height + ESPACAMENTO_PADRAO;

   if iAlturaNecessaria < ALTURA_MINIMA_DIALOGO then begin
      iAlturaNecessaria := ALTURA_MINIMA_DIALOGO;
   end;

   ClientHeight := iAlturaNecessaria;
end;

procedure tFrmDlgPadrao.AplicarTema;
var
   cCorFundo: TColor;
   cCorTexto: TColor;
   cCorCard: TColor;
   cCorDestaque: TColor;
begin
   cCorFundo := tTemaAplicacao.CorFundo;
   cCorTexto := tTemaAplicacao.CorTexto;
   cCorCard := CorCard;
   cCorDestaque := CorDestaqueTipo;

   Color := cCorFundo;
   Font.Color := cCorTexto;

   pnlFundo.Color := cCorFundo;
   pnlTopo.Color := cCorCard;
   pnlConteudo.Color := cCorFundo;
   pnlDetalhes.Color := cCorCard;
   pnlRodape.Color := cCorCard;
   pnlBotoes.Color := cCorFundo;

   shpIcone.Brush.Color := cCorDestaque;
   shpIcone.Pen.Color := cCorDestaque;

   lblCabecalho.Font.Color := cCorTexto;
   lblTexto.Font.Color := cCorTexto;
   lblDetalhesTitulo.Font.Color := cCorTexto;
   lblRodape.Font.Color := CorTextoSecundario;
   mmoDetalhes.Color := cCorCard;
   mmoDetalhes.Font.Color := cCorTexto;
   lblIcone.Font.Color := clWhite;

   bvlTopo.Shape := bsTopLine;
   bvlTopo.Style := bsLowered;
   bvlTopo.Height := 2;
   bvlTopo.Align := alBottom;

   bvlRodape.Shape := bsTopLine;
   bvlRodape.Style := bsLowered;
   bvlRodape.Height := 2;
   bvlRodape.Align := alTop;
end;

function tFrmDlgPadrao.CorCard: TColor;
begin
   if tTemaAplicacao.TemaEscuro then begin
      Result := RGB(37, 37, 38);
   end else begin
      Result := clWhite;
   end;
end;

function tFrmDlgPadrao.CorDestaqueTipo: TColor;
begin
   case FConfig.Tipo of
      tdpInformacao  : Result := RGB(0, 120, 215);
      tdpAviso       : Result := RGB(240, 173, 78);
      tdpErro        : Result := RGB(217, 83, 79);
      tdpConfirmacao : Result := RGB(92, 184, 92);
   else
      Result := RGB(0, 120, 215);
   end;
end;

function tFrmDlgPadrao.CorTextoSecundario: TColor;
begin
   if tTemaAplicacao.TemaEscuro then begin
      Result := RGB(190, 190, 190);
   end else begin
      Result := RGB(95, 95, 95);
   end;
end;

function tFrmDlgPadrao.CriarBotao(const sCaption: string; iModalResult,
   iLeft: Integer; bDefault, bCancel: Boolean): TButton;
begin
   Result := TButton.Create(Self);
   Result.Parent := pnlBotoes;
   Result.Width := LARGURA_BOTAO;
   Result.Height := ALTURA_BOTAO;
   Result.Left := iLeft;
   Result.Top := 10;
   Result.Caption := sCaption;
   Result.ModalResult := iModalResult;
   Result.Default := bDefault;
   Result.Cancel := bCancel;
   Result.TabOrder := pnlBotoes.ControlCount;
end;

class function tFrmDlgPadrao.Executar(const aConfig: tConfigDialogoProjeto): Integer;
var
   aDialogo: tFrmDlgPadrao;
begin
   aDialogo := tFrmDlgPadrao.Create(nil);
   try
      aDialogo.Preparar(aConfig);
      Result := aDialogo.ShowModal;
   finally
      FreeAndNil(aDialogo);
   end;
end;

procedure tFrmDlgPadrao.ConfigurarBotoes;
var
   iLeftAtual: Integer;
   iTotalBotoes: Integer;

   procedure AdicionarBotao(const sCaption: string; iModalResult: Integer;
      bDefault, bCancel: Boolean);
   begin
      CriarBotao(sCaption, iModalResult, iLeftAtual, bDefault, bCancel);
      Inc(iLeftAtual, LARGURA_BOTAO + ESPACAMENTO_BOTAO);
   end;

begin
   while pnlBotoes.ControlCount > 0 do begin
      pnlBotoes.Controls[0].Free;
   end;

   iTotalBotoes := 0;

   if bdpOk in FConfig.Botoes then begin
      Inc(iTotalBotoes);
   end;

   if bdpSim in FConfig.Botoes then begin
      Inc(iTotalBotoes);
   end;

   if bdpNao in FConfig.Botoes then begin
      Inc(iTotalBotoes);
   end;

   if bdpCancelar in FConfig.Botoes then begin
      Inc(iTotalBotoes);
   end;

   iLeftAtual := pnlBotoes.Width - ((iTotalBotoes * LARGURA_BOTAO) + ((iTotalBotoes - 1) * ESPACAMENTO_BOTAO)) - ESPACAMENTO_PADRAO;

   if bdpOk in FConfig.Botoes then begin
      AdicionarBotao('&OK', mrOk, FConfig.BotaoPadrao = mrOk, True);
   end;

   if bdpSim in FConfig.Botoes then begin
      AdicionarBotao('&Sim', mrYes, FConfig.BotaoPadrao = mrYes, False);
   end;

   if bdpNao in FConfig.Botoes then begin
      AdicionarBotao('&Não', mrNo, FConfig.BotaoPadrao = mrNo, True);
   end;

   if bdpCancelar in FConfig.Botoes then begin
      AdicionarBotao('&Cancelar', mrCancel, FConfig.BotaoPadrao = mrCancel, True);
   end;
end;

procedure tFrmDlgPadrao.ConfigurarConteudo;
var
   iLarguraTexto: Integer;
   iAlturaTexto: Integer;
   iAlturaDetalhes: Integer;
   iAlturaRodape: Integer;
begin
   Caption := FConfig.CaptionAplicacao;
   lblCabecalho.Caption := FConfig.Cabecalho;
   lblIcone.Caption := ObterTextoIcone;
   lblTexto.Caption := FConfig.Texto;

   iLarguraTexto := pnlConteudo.ClientWidth - (lblTexto.Left * 2);
   iAlturaTexto := SomarAlturaTexto(FConfig.Texto, lblTexto.Font, iLarguraTexto, 40);
   lblTexto.SetBounds(lblTexto.Left, lblTexto.Top, iLarguraTexto, iAlturaTexto);

   pnlDetalhes.Visible := Trim(FConfig.Detalhes) <> '';
   if pnlDetalhes.Visible then begin
      mmoDetalhes.Lines.Text := FConfig.Detalhes;
      iAlturaDetalhes := SomarAlturaTexto(FConfig.Detalhes, mmoDetalhes.Font,
         mmoDetalhes.Width - 8, 68);
      if iAlturaDetalhes > 130 then begin
         iAlturaDetalhes := 130;
      end;
      mmoDetalhes.Height := iAlturaDetalhes;
      pnlDetalhes.Height := mmoDetalhes.Top + mmoDetalhes.Height + 10;
      pnlDetalhes.Top := lblTexto.Top + lblTexto.Height + 12;
   end else begin
      pnlDetalhes.Height := 0;
   end;

   pnlRodape.Visible := Trim(FConfig.Rodape) <> '';
   if pnlRodape.Visible then begin
      lblRodape.Caption := FConfig.Rodape;
      iAlturaRodape := SomarAlturaTexto(FConfig.Rodape, lblRodape.Font,
         lblRodape.Width, 20);
      lblRodape.Height := iAlturaRodape;
      pnlRodape.Height := lblRodape.Top + lblRodape.Height + 10;
   end else begin
      pnlRodape.Height := 0;
   end;
end;

procedure tFrmDlgPadrao.FormCreate(Sender: TObject);
begin
   BorderIcons := [biSystemMenu];
   BorderStyle := bsDialog;
   KeyPreview := True;
   Position := poMainFormCenter;
   ClientWidth := LARGURA_DIALOGO;
   Constraints.MinWidth := LARGURA_DIALOGO;
   Constraints.MinHeight := ALTURA_MINIMA_DIALOGO;

   lblTexto.WordWrap := True;
   lblCabecalho.WordWrap := True;
   lblRodape.WordWrap := True;

   mmoDetalhes.ReadOnly := True;
   mmoDetalhes.BorderStyle := bsNone;
   mmoDetalhes.TabStop := False;
   mmoDetalhes.ScrollBars := ssVertical;
end;

procedure tFrmDlgPadrao.FormShow(Sender: TObject);
var
   iCont: Integer;
begin
   for iCont := 0 to pnlBotoes.ControlCount - 1 do begin
      if (pnlBotoes.Controls[iCont] is TButton) and
         TButton(pnlBotoes.Controls[iCont]).Default and
         (pnlBotoes.Controls[iCont] is TWinControl) then begin
         ActiveControl := TWinControl(pnlBotoes.Controls[iCont]);
         Break;
      end;
   end;
end;

function tFrmDlgPadrao.ObterTextoIcone: string;
begin
   case FConfig.Tipo of
      tdpInformacao  : Result := 'i';
      tdpAviso       : Result := '!';
      tdpErro        : Result := 'x';
      tdpConfirmacao : Result := '?';
   else
      Result := 'i';
   end;
end;

procedure tFrmDlgPadrao.Preparar(const aConfig: tConfigDialogoProjeto);
begin
   FConfig := aConfig;

   ConfigurarConteudo;
   AplicarTema;
   ConfigurarBotoes;
   AjustarAlturaDialogo;
end;

function tFrmDlgPadrao.SomarAlturaTexto(const sTexto: string; aFonte: TFont;
   iLargura, iAlturaMinima: Integer): Integer;
var
   aRect: TRect;
   aCanvas: TCanvas;
begin
   aCanvas := TCanvas.Create;
   try
      aCanvas.Handle := GetDC(0);
      try
         aCanvas.Font.Assign(aFonte);
         aRect := Rect(0, 0, iLargura, 0);
         DrawText(aCanvas.Handle, PChar(sTexto), Length(sTexto), aRect,
            DT_WORDBREAK or DT_CALCRECT or DT_LEFT);
         Result := aRect.Height + 4;
      finally
         ReleaseDC(0, aCanvas.Handle);
         aCanvas.Handle := 0;
      end;
   finally
      FreeAndNil(aCanvas);
   end;

   if Result < iAlturaMinima then begin
      Result := iAlturaMinima;
   end;
end;

end.
