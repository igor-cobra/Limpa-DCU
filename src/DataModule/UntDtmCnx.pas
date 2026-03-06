unit UntDtmCnx;

interface

uses
  System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.Intf, FireDAC.Phys.SQLiteDef, FireDAC.DApt.Intf;

type
  TdtmCnx = class(TDataModule)
    cnxDatabase: TFDConnection;
    qryListaProj: TFDQuery;
    qryListaProjIDPROJETO: TFDAutoIncField;
    qryListaProjNOMEPROJ: TStringField;
    qryListaProjCAMINHOPROJ: TStringField;
  private
    procedure GeraEstruturaDB;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DeleteProjeto(idProjeto: Integer);
    procedure CadsatrarProjeto(sNome, sCaminho: string);
    procedure GarantirEstruturaDB;
    procedure GarantirTabelaConfiguracao;
    function LerConfiguracao(const sChave: string; const sPadrao: string = ''): string;
    procedure GravarConfiguracao(const sChave, sValor: string);
  end;

var
  dtmCnx: TdtmCnx;

implementation

uses
  UntLib, System.SysUtils;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdtmCnx }

procedure TdtmCnx.CadsatrarProjeto(sNome, sCaminho: string);
var
   aQry: TFDQuery;
begin
   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.AddStrings([
         'INSERT INTO TBLCDSPROJ0 (NOMEPROJ, CAMINHOPROJ)',
         'VALUES (',
         '   :NOMEPROJ,',
         '   :CAMINHOPROJ',
         ')'
         ]);
      aQry.ParamByName('NOMEPROJ').AsString    := sNome;
      aQry.ParamByName('CAMINHOPROJ').AsString := sCaminho;
      aQry.ExecSQL;
   finally
      aQry.Close;
      FreeAndNil(aQry);
   end;
end;

constructor TdtmCnx.Create(AOwner: TComponent);
begin
   inherited;
   cnxDatabase.Params.Values['database'] := CAMINHO_DB;
end;

procedure TdtmCnx.DeleteProjeto(idProjeto: Integer);
var
   aQry: TFDQuery;
begin
   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.AddStrings([
         'DELETE FROM TBLCDSPROJ0',
         'WHERE',
         '   IDPROJETO = :IDPROJETO'
         ]);
      aQry.ParamByName('IDPROJETO').AsInteger := idProjeto;
      aQry.ExecSQL;
   finally
      aQry.Close;
      FreeAndNil(aQry);
   end;
end;

procedure TdtmCnx.GarantirEstruturaDB;
begin
   if not cnxDatabase.Connected then cnxDatabase.Connected := True;

   GeraEstruturaDB;
   GarantirTabelaConfiguracao;
end;

procedure TdtmCnx.GarantirTabelaConfiguracao;
begin
   cnxDatabase.ExecSQL(
      'CREATE TABLE IF NOT EXISTS TBLCFG0 (' +
      '  CHAVE VARCHAR(50) NOT NULL PRIMARY KEY,' +
      '  VALOR VARCHAR(50)' +
      ')'
      );
end;

procedure TdtmCnx.GeraEstruturaDB;
begin
   cnxDatabase.ExecSQL(
      'CREATE TABLE IF NOT EXISTS TBLCDSPROJ0 (' +
      '    IDPROJETO INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '    NOMEPROJ TEXT NOT NULL,' +
      '    CAMINHOPROJ TEXT NOT NULL' +
      ');'
      );
end;

procedure TdtmCnx.GravarConfiguracao(const sChave, sValor: string);
var
   aQry: TFDQuery;
begin
   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.AddStrings([
         'INSERT INTO TBLCFG0 (CHAVE, VALOR)',
         'VALUES (',
         '   :CHAVE,',
         '   :VALOR',
         ')',
         'ON CONFLICT(CHAVE) DO UPDATE SET VALOR = excluded.VALOR'
         ]);
      aQry.ParamByName('CHAVE').AsString := sChave;
      aQry.ParamByName('VALOR').AsString := sValor;
      aQry.ExecSQL;
   finally
      aQry.Close;
      FreeAndNil(aQry);
   end;
end;

function TdtmCnx.LerConfiguracao(const sChave, sPadrao: string): string;
var
   aQry: TFDQuery;
begin
   Result := sPadrao;

   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.AddStrings([
         'SELECT',
         '   VALOR',
         'FROM TBLCFG0',
         'WHERE',
         '   CHAVE = :CHAVE'
         ]);
      aQry.ParamByName('CHAVE').AsString := sChave;
      aQry.Open;

      if not aQry.IsEmpty then Result := aQry.Fields[0].AsString;
   finally
      aQry.Close;
      FreeAndNil(aQry);
   end;
end;

end.
