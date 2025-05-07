unit UntMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, UntClassLimpaDcu,
  Data.DB, Vcl.Grids, Vcl.DBGrids, UntDtmCnx, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TAuxDBGrid = class(TDBGrid);

  TFrmMain = class(TForm)
    stsRodape: TStatusBar;
    dbgListaProj: TDBGrid;
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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCadastrarClick(Sender: TObject);
    procedure btnExcluirProjetoClick(Sender: TObject);
    procedure btnLimparDcuClick(Sender: TObject);
    procedure dbgListaProjDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgListaProjCellClick(Column: TColumn);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgListaProjTitleClick(Column: TColumn);
  private
    LimpaDcu: TLimpaDcu;
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
  UntLib;

{$R *.dfm}

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
const
   CtrlState : array [Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
	DBGrid: TDBGrid;
   bLinhaSelecionada: Boolean;
   cbkRect : TRect;
begin
   DBGrid            := TDBGrid(Sender);
   bLinhaSelecionada := (TAuxDBGrid(DBGrid).DataLink.ActiveRecord + 1 = TAuxDBGrid(DBGrid).Row) or (gdSelected in State);

   if bLinhaSelecionada then begin
      DBGrid.Canvas.Brush.Color := clSkyBlue;
      DBGrid.Canvas.Font.Color:= clBlack;
   end else begin
      // Aplica listrado: cor alternada nas linhas
    	if DBGrid.DataSource.DataSet.RecNo mod 2 = 0 then begin
      	DBGrid.Canvas.Brush.Color := $00E0E0E0;  // cor mais clara
    	end else begin
      	DBGrid.Canvas.Brush.Color := clWhite;   // cor normal
      end;
   end;

   DBGrid.DefaultDrawDataCell(Rect, DBGrid.columns[datacol].field, State);

   if Column.Field.DataType = ftBoolean then begin
      DBGrid.Canvas.FillRect(Rect);
      cbkRect.Left := Rect.Left + 2;
      cbkRect.Right := Rect.Right - 2;
      cbkRect.Top := Rect.Top + 2;
      cbkRect.Bottom := Rect.Bottom - 2;
      DrawFrameControl(DBGrid.Canvas.Handle, cbkRect, DFC_BUTTON, CtrlState[Column.Field.AsBoolean]);
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

end.
