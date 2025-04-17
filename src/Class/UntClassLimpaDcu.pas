unit UntClassLimpaDcu;

interface

uses
   System.Classes, System.SysUtils, UntDtmCnx, Vcl.StdCtrls;

type
   TLimpaDcu = class
   private
      Cnx: TdtmCnx;
      mmoLog: TMemo;
      function CheckDatabaseExists: Boolean;
      procedure FiltraCds(sCondicao: string);
   protected
   public
      procedure CarregaProjetos;
      procedure Cadastrar;
      procedure Excluir;
      procedure LimparDcu;
      procedure SelecionarRegistro(bTodos: Boolean);
      constructor Create;
      destructor Destroy; override;
   end;

implementation

uses
   UntLib, UntMain, Data.DB, UntCdsProj0, Vcl.Forms, System.IOUtils;

{ TLimpaDcu }

procedure TLimpaDcu.Cadastrar;
var
   Proj0: TFrmCdsProj0;
begin
   Proj0 := TFrmCdsProj0.Create(nil);
   try
      Proj0.ShowModal;
      if Proj0.Salvar then begin
         Cnx.CadsatrarProjeto(Proj0.fldNomeProjeto.Text, Proj0.fldCaminhoProjeto.Text);
         CarregaProjetos;
      end;
   finally
      FreeAndNil(Proj0);
   end;
end;

procedure TLimpaDcu.CarregaProjetos;
begin
   frmMain.cdsListaProj.Close;
   frmMain.cdsListaProj.CreateDataSet;
   Cnx.qryListaProj.Open;
   Cnx.qryListaProj.First;
   while not Cnx.qryListaProj.Eof do begin
      frmMain.cdsListaProj.Append;
      frmMain.cdsListaProjSEL.AsBoolean        := False;
      frmMain.cdsListaProjIDPROJETO.AsInteger  := Cnx.qryListaProjIDPROJETO.AsInteger;
      frmMain.cdsListaProjNOMEPROJ.AsString    := Cnx.qryListaProjNOMEPROJ.AsString;
      frmMain.cdsListaProjCAMINHOPROJ.AsString := Cnx.qryListaProjCAMINHOPROJ.AsString;
      frmMain.cdsListaProj.Post;

      Cnx.qryListaProj.Next;
   end;
   frmMain.cdsListaProj.First;
   Cnx.qryListaProj.Close;
end;

function TLimpaDcu.CheckDatabaseExists: Boolean;
begin
	Result := FileExists(CAMINHO_DB);
end;

constructor TLimpaDcu.Create;
begin
   mmoLog := frmMain.mmoLog;
   Cnx    := TdtmCnx.Create(nil);
   if not CheckDatabaseExists then Cnx.GeraEstruturaDB;
end;

destructor TLimpaDcu.Destroy;
begin
   FreeAndNil(Cnx);
end;

procedure TLimpaDcu.Excluir;
var
   iCont: Integer;
   BookMark: TBookmark;
begin
   FiltraCds('SEL');

   if (frmMain.cdsListaProj.RecordCount > 0) and (MsgYesNo('Gostaria de excluir os projetos selecionados?')) then begin
      frmMain.cdsListaProj.First;
      while not frmMain.cdsListaProj.Eof do begin
         Cnx.DeleteProjeto(frmMain.cdsListaProjIDPROJETO.AsInteger);

         frmMain.cdsListaProj.Next;
      end;

      FiltraCds('');
      CarregaProjetos;
   end else begin
      FiltraCds('SEL');
   end;
end;

procedure TLimpaDcu.FiltraCds(sCondicao: string);
begin
   frmMain.cdsListaProj.Filtered := False;
   frmMain.cdsListaProj.Filter   := sCondicao;
   frmMain.cdsListaProj.Filtered := True;
end;

procedure TLimpaDcu.LimparDcu;
var
   sDcuFiles: TStringList;
   sFileName: string;
   sDcuPath: string;
begin
   FiltraCds('SEL');

   if (frmMain.cdsListaProj.RecordCount > 0) and (MsgYesNo('Gostaria de excluir os DCUs dos projetos selecionados?')) then begin
      frmMain.mmoLog.Lines.Add('============================================================');
      frmMain.mmoLog.Lines.Add('Iniciando exclusão dos DCUs...');
      sDcuFiles := TStringList.Create;
      try
         frmMain.cdsListaProj.First;
         while not frmMain.cdsListaProj.Eof do begin
            sDcuPath := frmMain.cdsListaProjCAMINHOPROJ.AsString;
            frmMain.mmoLog.Lines.Add('============================================================');
            frmMain.mmoLog.Lines.Add('Iniciando exclusão do projeto: ' + frmMain.cdsListaProjNOMEPROJ.AsString);
            frmMain.mmoLog.Lines.Add('============================================================');

            if DirectoryExists(sDcuPath) then begin
               // Localizar todos os arquivos .dcu na pasta
               sDcuFiles.Clear;
               sDcuFiles.AddStrings(TDirectory.GetFiles(sDcuPath, '*.dcu', TSearchOption.soAllDirectories));

               // Excluir cada arquivo e registrar no memo
               for sFileName in sDcuFiles do begin
                  DeleteFile(sFileName);
                  frmMain.mmoLog.Lines.Add('Arquivo excluído: ' + sFileName);
               end;

               frmMain.mmoLog.Lines.Add('Exclusão concluída para o projeto: ' + frmMain.cdsListaProjNOMEPROJ.AsString);
               Application.ProcessMessages;
            end else begin
               frmMain.mmoLog.Lines.Add('Caminho do projeto não encontrado: ' + sDcuPath);
            end;
            frmMain.cdsListaProj.Next;
         end;
      finally
         sDcuFiles.Free;
         frmMain.mmoLog.Lines.Add('============================================================');
         frmMain.mmoLog.Lines.Add('Processo de exclusão dos DCUs concluído.');
         frmMain.mmoLog.Lines.Add('============================================================');
      end;
   end;

   FiltraCds('');
   frmMain.cdsListaProj.First;
end;

procedure TLimpaDcu.SelecionarRegistro(bTodos: Boolean);
begin
	if bTodos then begin
      frmMain.cdsListaProj.First;
      frmMain.cdsListaProj.DisableControls;
      while not frmMain.cdsListaProj.Eof do begin
         frmMain.cdsListaProj.Edit;
         frmMain.cdsListaProjSEL.AsBoolean := not frmMain.cdsListaProjSel.AsBoolean;
         frmMain.cdsListaProj.Post;

         frmMain.cdsListaProj.Next;
      end;
      frmMain.cdsListaProj.First;
      frmMain.cdsListaProj.EnableControls;
	end else begin
      frmMain.cdsListaProj.Edit;
      frmMain.cdsListaProjSEL.AsBoolean := not frmMain.cdsListaProjSEL.AsBoolean;
      frmMain.cdsListaProj.Post;
   end;
end;

end.

