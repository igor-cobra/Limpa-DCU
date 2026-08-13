unit UntDtmCnx;

interface

uses
   System.Classes,
   Data.DB,
   FireDAC.Stan.Intf,
   FireDAC.Stan.Option,
   FireDAC.Stan.Error,
   FireDAC.UI.Intf,
   FireDAC.Stan.Def,
   FireDAC.Stan.Pool,
   FireDAC.Stan.Async,
   FireDAC.Phys,
   FireDAC.Phys.SQLite,
   FireDAC.Stan.ExprFuncs,
   FireDAC.Phys.SQLiteWrapper.Stat,
   FireDAC.VCLUI.Wait,
   FireDAC.Comp.Client,
   FireDAC.Stan.Param,
   FireDAC.DatS,
   FireDAC.DApt,
   FireDAC.Comp.DataSet,
   FireDAC.Phys.Intf,
   FireDAC.Phys.SQLiteDef,
   FireDAC.DApt.Intf;

type
   tDtmCnx = class(TDataModule)
      cnxDatabase: TFDConnection;
      qryListaProj: TFDQuery;
      qryListaProjIDPROJETO: TFDAutoIncField;
      qryListaProjNOMEPROJ: TWideStringField;
      qryListaProjCAMINHOPROJ: TWideStringField;
   private
      procedure GarantirTabelaProjetos;
      procedure GarantirTabelaConfiguracao;
   public
      constructor Create(AOwner: TComponent); override;
      procedure GarantirEstruturaDB;
      procedure CadastrarProjeto(const sNome, sCaminho: string);
      procedure ExcluirProjeto(iIdProjeto: Integer);
      function LerConfiguracao(const sChave, sPadrao: string): string;
      procedure GravarConfiguracao(const sChave, sValor: string);
   end;

var
   dtmCnx: tDtmCnx;

implementation

uses
   System.SysUtils,
   UntClassAplicacao;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor tDtmCnx.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   cnxDatabase.Params.Values['Database'] := tAplicacao.CaminhoBanco;
   cnxDatabase.Params.Values['StringFormat'] := 'Unicode';
end;

procedure tDtmCnx.CadastrarProjeto(const sNome, sCaminho: string);
var
   aQry: TFDQuery;
begin
   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.Text :=
         'INSERT INTO TBLCDSPROJ0 (NOMEPROJ, CAMINHOPROJ) ' +
         'VALUES (:NOMEPROJ, :CAMINHOPROJ)';
      aQry.ParamByName('NOMEPROJ').AsWideString := sNome;
      aQry.ParamByName('CAMINHOPROJ').AsWideString := sCaminho;
      aQry.ExecSQL;
   finally
      FreeAndNil(aQry);
   end;
end;

procedure tDtmCnx.ExcluirProjeto(iIdProjeto: Integer);
var
   aQry: TFDQuery;
begin
   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.Text := 'DELETE FROM TBLCDSPROJ0 WHERE IDPROJETO = :IDPROJETO';
      aQry.ParamByName('IDPROJETO').AsInteger := iIdProjeto;
      aQry.ExecSQL;
   finally
      FreeAndNil(aQry);
   end;
end;

procedure tDtmCnx.GarantirEstruturaDB;
begin
   if not cnxDatabase.Connected then begin
      cnxDatabase.Connected := True;
   end;

   GarantirTabelaProjetos;
   GarantirTabelaConfiguracao;
end;

procedure tDtmCnx.GarantirTabelaConfiguracao;
begin
   cnxDatabase.ExecSQL(
      'CREATE TABLE IF NOT EXISTS TBLCFG0 (' +
      'CHAVE TEXT NOT NULL PRIMARY KEY, ' +
      'VALOR TEXT' +
      ')'
      );
end;

procedure tDtmCnx.GarantirTabelaProjetos;
begin
   cnxDatabase.ExecSQL(
      'CREATE TABLE IF NOT EXISTS TBLCDSPROJ0 (' +
      'IDPROJETO INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'NOMEPROJ TEXT NOT NULL, ' +
      'CAMINHOPROJ TEXT NOT NULL' +
      ')'
      );
end;

procedure tDtmCnx.GravarConfiguracao(const sChave, sValor: string);
var
   aQry: TFDQuery;
begin
   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.Text :=
         'INSERT INTO TBLCFG0 (CHAVE, VALOR) VALUES (:CHAVE, :VALOR) ' +
         'ON CONFLICT(CHAVE) DO UPDATE SET VALOR = excluded.VALOR';
      aQry.ParamByName('CHAVE').AsWideString := sChave;
      aQry.ParamByName('VALOR').AsWideString := sValor;
      aQry.ExecSQL;
   finally
      FreeAndNil(aQry);
   end;
end;

function tDtmCnx.LerConfiguracao(const sChave, sPadrao: string): string;
var
   aQry: TFDQuery;
begin
   Result := sPadrao;

   aQry := TFDQuery.Create(nil);
   try
      aQry.Connection := cnxDatabase;
      aQry.SQL.Text := 'SELECT VALOR FROM TBLCFG0 WHERE CHAVE = :CHAVE';
      aQry.ParamByName('CHAVE').AsWideString := sChave;
      aQry.Open;

      if not aQry.IsEmpty then begin
         Result := aQry.Fields[0].AsWideString;
      end;
   finally
      FreeAndNil(aQry);
   end;
end;

end.
