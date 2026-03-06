unit UntMain;

interface

uses
  Winapi.Windows, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, UntClassLimpaDcu,
  Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.WinXCtrls;

type
  TAuxDBGrid = class(TDBGrid);

  TFrmMain = class(TForm)
    stsRodape: TStatusBar;
    dsListaProj: TDataSource;
    pnlTop: TPanel;
    btnLimparDcu: TButton;
    btnCadastrar: TButton;
    btnExcluirProjeto: TButton;
    mmoLog: TMemo;
    cdsListaProj: TFDMemTable;
    cdsListaProjSEL: TBooleanField;
    cdsListaProjIDPROJETO: TIntegerField;
    cdsListaProjNOMEPROJ: TStringField;
    cdsListaProjCAMINHOPROJ: TStringField;
    dbgListaProj: TDBGrid;
    pnlBottom: TPanel;
    lblLogRegistros: TLabel;
    tlgModoEscuro: TToggleSwitch;
    lblModoEscuro: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCadastrarClick(Sender: TObject);
    procedure btnExcluirProjetoClick(Sender: TObject);
    procedure btnLimparDcuClick(Sender: TObject);
    procedure dbgListaProjDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgListaProjCellClick(Column: TColumn);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dbgListaProjTitleClick(Column: TColumn);
    procedure tlgModoEscuroClick(Sender: TObject);
  private
    LimpaDcu: TLimpaDcu;
    procedure AtualizarEstadoControleTema;
    procedure AplicarTemaTela;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

const
   STS_VERAPL = 0;
   STS_PRJ    = 1;

implementation

uses
  UntLib, UntTemaAplicacao;

{$R *.dfm}

procedure TFrmMain.AplicarTemaTela;
begin
   Color := tTemaAplicacao.CorFundo;
   Font.Color := tTemaAplicacao.CorTexto;

   pnlTop.ParentBackground := False;
   pnlTop.Color := tTemaAplicacao.CorFundo;

   mmoLog.Color := tTemaAplicacao.CorEdit;
   mmoLog.Font.Color := tTemaAplicacao.CorTexto;

   if Assigned(lblModoEscuro) then begin
      lblModoEscuro.Font.Color := tTemaAplicacao.CorTexto;
   end;

   dbgListaProj.Invalidate;
   mmoLog.Invalidate;
   pnlTop.Invalidate;
   Invalidate;
end;

procedure TFrmMain.AtualizarEstadoControleTema;
begin
   if tTemaAplicacao.TemaEscuro then begin
      tlgModoEscuro.State := tssOn;
   end else begin
      tlgModoEscuro.State := tssOff;
   end;
end;

procedure TFrmMain.btnCadastrarClick(Sender: TObject);
begin
   LimpaDcu.Cadastrar;
end;

procedure TFrmMain.btnExcluirProjetoClick(Sender: TObject);
begin
   LimpaDcu.Excluir;
end;

procedure TFrmMain.btnLimparDcuClick(Sender: TObject);
begin
   LimpaDcu.LimparDcu;
end;

procedure TFrmMain.dbgListaProjCellClick(Column: TColumn);
begin
   LimpaDcu.SelecionarRegistro(False);
end;

procedure TFrmMain.dbgListaProjDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
   aGrid: TDBGrid;
   bLinhaSelecionada: Boolean;
   bNroLinhaPar: Boolean;
   bHabilitado: Boolean;
begin
   aGrid := TDBGrid(Sender);
   bLinhaSelecionada := (TAuxDBGrid(aGrid).DataLink.ActiveRecord + 1 = TAuxDBGrid(aGrid).Row)
                        or (gdSelected in State);
   bNroLinhaPar     := aGrid.DataSource.DataSet.RecNo mod 2 = 0;

   tTemaAplicacao.PrepararCanvasGrid(aGrid.Canvas, bLinhaSelecionada, bNroLinhaPar);
   aGrid.Canvas.FillRect(Rect);

   if Column.Field.DataType = ftBoolean then begin
      bHabilitado := aGrid.Enabled and Column.Field.CanModify;
      tTemaAplicacao.DesenharCheckBoxGrid(aGrid.Canvas, Rect, Column.Field.AsBoolean, bHabilitado);
   end else begin
      aGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
   end;
end;

procedure TFrmMain.dbgListaProjTitleClick(Column: TColumn);
begin
   LimpaDcu.SelecionarRegistro(True);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   stsRodape.Panels[STS_VERAPL].Text := 'Versão APL: ' + VERSAO_APL;
   stsRodape.Panels[STS_PRJ].Text    := 'Projeto atual: ';
   mmoLog.Lines.Clear;

   LimpaDcu := TLimpaDcu.Create;

   AtualizarEstadoControleTema;
   AplicarTemaTela;
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case Key of
      VK_SPACE: begin
         if (Self.ActiveControl is TDBGrid) and (TDBGrid(Self.ActiveControl) = dbgListaProj) then begin
            LimpaDcu.SelecionarRegistro(False);
         end;
      end;
   end;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
   LimpaDcu.CarregaProjetos;
end;

procedure TFrmMain.tlgModoEscuroClick(Sender: TObject);
begin
   if tlgModoEscuro.State = tssOn then begin
      tTemaAplicacao.Aplicar(mtEscuro, True);
   end else begin
      tTemaAplicacao.Aplicar(mtClaro, True);
   end;

   AplicarTemaTela;
   AtualizarEstadoControleTema;
end;

end.
