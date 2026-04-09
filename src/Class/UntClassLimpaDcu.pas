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
   UntLib, UntMain, Data.DB, UntCdsProj0, Vcl.Forms, System.IOUtils,
  UntClassDialogos;

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
   frmMain.cdsListaProj.DisableControls;
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
   frmMain.cdsListaProj.EnableControls;
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
   Cnx.GarantirEstruturaDB;
end;

destructor TLimpaDcu.Destroy;
begin
   FreeAndNil(Cnx);
end;

procedure TLimpaDcu.Excluir;
var
   bTemSelecionado: Boolean;
begin
   FiltraCds('SEL');
   bTemSelecionado := frmMain.cdsListaProj.RecordCount > 0;
   try
      if not bTemSelecionado then begin
         tDialogos.NenhumProjetoSelecionado('excluir');
      end else begin
         if tDialogos.Confirmar('Gostaria de excluir os projetos selecionados?', 'Excluir projetos', WC_MB_MSGNO) then begin
            frmMain.cdsListaProj.First;
            while not frmMain.cdsListaProj.Eof do begin
               Cnx.DeleteProjeto(frmMain.cdsListaProjIDPROJETO.AsInteger);
               frmMain.cdsListaProj.Next;
            end;
            tDialogos.Informacao('Os projetos selecionados foram excluídos com sucesso.', 'Exclusão concluída');
         end;
      end;
   finally
      FiltraCds('');
      CarregaProjetos;
      frmMain.cdsListaProj.First;
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
   iProjetosProcessados: Integer;
   iArquivosExcluidos: Integer;
   iFalhas: Integer;
   bTemSelecionado: Boolean;
begin
   FiltraCds('SEL');
   bTemSelecionado := frmMain.cdsListaProj.RecordCount > 0;
   if not bTemSelecionado then begin
      tDialogos.NenhumProjetoSelecionado('limpar os DCUs');
   end else begin
      if tDialogos.Confirmar('Gostaria de excluir os DCUs dos projetos selecionados?', 'Limpeza de DCUs', WC_MB_MSGNO) then begin
         frmMain.mmoLog.Lines.Add('============================================================');
         frmMain.mmoLog.Lines.Add('Iniciando exclusão dos DCUs...');
         iProjetosProcessados := 0;
         iArquivosExcluidos := 0;
         iFalhas := 0;
         sDcuFiles := TStringList.Create;
         try
            frmMain.cdsListaProj.First;
            while not frmMain.cdsListaProj.Eof do begin
               sDcuPath := frmMain.cdsListaProjCAMINHOPROJ.AsString;
               Inc(iProjetosProcessados);
               frmMain.stsRodape.Panels[STS_PRJ].Text := 'Projeto atual: ' + frmMain.cdsListaProjNOMEPROJ.AsString;
               frmMain.mmoLog.Lines.Add('============================================================');
               frmMain.mmoLog.Lines.Add('Iniciando exclusão do projeto: ' + frmMain.cdsListaProjNOMEPROJ.AsString);
               frmMain.mmoLog.Lines.Add('============================================================');
               Application.ProcessMessages;
               if DirectoryExists(sDcuPath) then begin
                  sDcuFiles.Clear;
                  sDcuFiles.AddStrings(TDirectory.GetFiles(sDcuPath, '*.dcu', TSearchOption.soAllDirectories));
                  for sFileName in sDcuFiles do begin
                     try
                        if DeleteFile(sFileName) then begin
                           Inc(iArquivosExcluidos);
                           frmMain.mmoLog.Lines.Add('Arquivo excluído: ' + sFileName);
                        end else begin
                           Inc(iFalhas);
                           frmMain.mmoLog.Lines.Add('Falha ao excluir arquivo: ' + sFileName);
                        end;
                     except
                        on E: Exception do begin
                           Inc(iFalhas);
                           frmMain.mmoLog.Lines.Add('Erro ao excluir arquivo: ' + sFileName + ' | ' + E.Message);
                        end;
                     end;
                  end;
                  frmMain.mmoLog.Lines.Add('Exclusão concluída para o projeto: ' + frmMain.cdsListaProjNOMEPROJ.AsString);
                  Application.ProcessMessages;
               end else begin
                  Inc(iFalhas);
                  frmMain.mmoLog.Lines.Add('Caminho do projeto não encontrado: ' + sDcuPath);
                  tDialogos.CaminhoNaoEncontrado(sDcuPath);
               end;
               frmMain.cdsListaProj.Next;
            end;
         finally
            FreeAndNil(sDcuFiles);
            frmMain.stsRodape.Panels[STS_PRJ].Text := 'Projeto atual: ';
            frmMain.mmoLog.Lines.Add('============================================================');
            frmMain.mmoLog.Lines.Add('Processo de exclusão dos DCUs concluído.');
            frmMain.mmoLog.Lines.Add('============================================================');
            tDialogos.ResumoLimpeza(iProjetosProcessados, iArquivosExcluidos, iFalhas);
         end;
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

