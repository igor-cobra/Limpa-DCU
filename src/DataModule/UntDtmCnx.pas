unit UntDtmCnx;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TdtmCnx = class(TDataModule)
    cnxDatabase: TFDConnection;
    qryTabelaListaProj: TFDQuery;
    qryDeleteProj: TFDQuery;
    qryCadastrarProj: TFDQuery;
    qryListaProj: TFDQuery;
    qryListaProjIDPROJETO: TFDAutoIncField;
    qryListaProjNOMEPROJ: TStringField;
    qryListaProjCAMINHOPROJ: TStringField;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    procedure GeraEstruturaDB;
    procedure DeleteProjeto(idProjeto: Integer);
    procedure CadsatrarProjeto(sNome, sCaminho: string);
  end;

var
  dtmCnx: TdtmCnx;

implementation

uses
  UntLib;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdtmCnx }

procedure TdtmCnx.CadsatrarProjeto(sNome, sCaminho: string);
begin
   qryCadastrarProj.ParamByName('NOMEPROJ').AsString    := sNome;
   qryCadastrarProj.ParamByName('CAMINHOPROJ').AsString := sCaminho;
   qryCadastrarProj.ExecSQL;
end;

constructor TdtmCnx.Create(AOwner: TComponent);
begin
   inherited;
   cnxDatabase.Params.Values['database'] := CAMINHO_DB;
end;

procedure TdtmCnx.DeleteProjeto(idProjeto: Integer);
begin
   qryDeleteProj.ParamByName('IDPROJETO').AsInteger := idProjeto;
   qryDeleteProj.ExecSQL;
end;

procedure TdtmCnx.GeraEstruturaDB;
begin
   qryTabelaListaProj.ExecSQL;
end;

end.
