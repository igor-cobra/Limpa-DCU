unit UntClassLimpaDcu;

interface

uses
   System.Classes,
   System.SysUtils,
   System.UITypes,
   UntDtmCnx;

type
   TLimpaDcu = class
   private
      Cnx: TdtmCnx;
      procedure FiltrarCds(const sCondicao: string);
      procedure RegistrarLog(const sMensagem: string);
      procedure AtualizarInterface;
      procedure ListarDcus(const sPasta: string; aArquivos: TStrings;
         var iFalhas: Integer);
      function CaminhoSeguroParaLimpeza(const sCaminho: string): Boolean;
   public
      constructor Create(aCnx: TdtmCnx);
      procedure CarregarProjetos;
      procedure Cadastrar;
      procedure Excluir;
      procedure LimparDcu;
      procedure SelecionarRegistro(bTodos: Boolean);
   end;

implementation

uses
   Winapi.Windows,
   Winapi.Messages,
   Data.DB,
   System.IOUtils,
   UntCdsProj0,
   UntMain,
   UntClassDialogos,
   UntClassLog;

procedure TLimpaDcu.AtualizarInterface;
begin
   frmMain.stsRodape.Update;
   frmMain.mmoLog.Update;
end;

procedure TLimpaDcu.Cadastrar;
var
   Proj0: TFrmCdsProj0;
begin
   Proj0 := TFrmCdsProj0.Create(nil);
   try
      if Proj0.ShowModal = mrOk then begin
         Cnx.CadastrarProjeto(Proj0.fldNomeProjeto.Text, Proj0.fldCaminhoProjeto.Text);
         RegistrarLog('Projeto cadastrado: ' + Proj0.fldNomeProjeto.Text + ' | ' +
            Proj0.fldCaminhoProjeto.Text);
         CarregarProjetos;
      end;
   finally
      FreeAndNil(Proj0);
   end;
end;

procedure TLimpaDcu.CarregarProjetos;
begin
   frmMain.cdsListaProj.DisableControls;
   try
      frmMain.cdsListaProj.Close;
      frmMain.cdsListaProj.CreateDataSet;

      Cnx.qryListaProj.Close;
      Cnx.qryListaProj.Open;
      try
         Cnx.qryListaProj.First;

         while not Cnx.qryListaProj.Eof do begin
            frmMain.cdsListaProj.Append;
            frmMain.cdsListaProjSEL.AsBoolean := False;
            frmMain.cdsListaProjIDPROJETO.AsInteger := Cnx.qryListaProjIDPROJETO.AsInteger;
            frmMain.cdsListaProjNOMEPROJ.AsWideString := Cnx.qryListaProjNOMEPROJ.AsWideString;
            frmMain.cdsListaProjCAMINHOPROJ.AsWideString := Cnx.qryListaProjCAMINHOPROJ.AsWideString;
            frmMain.cdsListaProj.Post;
            Cnx.qryListaProj.Next;
         end;
      finally
         Cnx.qryListaProj.Close;
      end;

      frmMain.cdsListaProj.First;
   finally
      frmMain.cdsListaProj.EnableControls;
   end;
end;

function TLimpaDcu.CaminhoSeguroParaLimpeza(const sCaminho: string): Boolean;
var
   iAtributos: DWORD;
   sCaminhoNormalizado: string;
   sRaiz: string;
begin
   Result := False;

   if Trim(sCaminho) = '' then begin
      Exit;
   end;

   try
      sCaminhoNormalizado := IncludeTrailingPathDelimiter(ExpandFileName(Trim(sCaminho)));
      sRaiz := IncludeTrailingPathDelimiter(TPath.GetPathRoot(sCaminhoNormalizado));
   except
      Exit;
   end;

   if SameText(sCaminhoNormalizado, sRaiz) then begin
      Exit;
   end;

   if not DirectoryExists(sCaminhoNormalizado) then begin
      Exit;
   end;

   iAtributos := GetFileAttributes(PChar(ExcludeTrailingPathDelimiter(sCaminhoNormalizado)));

   if iAtributos = INVALID_FILE_ATTRIBUTES then begin
      Exit;
   end;

   if (iAtributos and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then begin
      Exit;
   end;

   Result := (iAtributos and FILE_ATTRIBUTE_DIRECTORY) <> 0;
end;

constructor TLimpaDcu.Create(aCnx: TdtmCnx);
begin
   inherited Create;

   if not Assigned(aCnx) then begin
      raise Exception.Create('A conexão do LimpaDCU não foi inicializada.');
   end;

   Cnx := aCnx;
end;

procedure TLimpaDcu.Excluir;
begin
   FiltrarCds('SEL = True');
   try
      if frmMain.cdsListaProj.RecordCount = 0 then begin
         tDialogos.NenhumProjetoSelecionado('excluir');
         Exit;
      end;

      if not tDialogos.Confirmar(
         'Gostaria de excluir os projetos selecionados?',
         'Excluir projetos',
         bcpNao
         ) then begin
         Exit;
      end;

      frmMain.cdsListaProj.First;
      while not frmMain.cdsListaProj.Eof do begin
         RegistrarLog('Projeto removido do cadastro: ' +
            frmMain.cdsListaProjNOMEPROJ.AsWideString);
         Cnx.ExcluirProjeto(frmMain.cdsListaProjIDPROJETO.AsInteger);
         frmMain.cdsListaProj.Next;
      end;

      tDialogos.Informacao('Os projetos selecionados foram excluídos com sucesso.',
         'Exclusão concluída');
   finally
      FiltrarCds('');
      CarregarProjetos;
   end;
end;

procedure TLimpaDcu.FiltrarCds(const sCondicao: string);
begin
   frmMain.cdsListaProj.Filtered := False;
   frmMain.cdsListaProj.Filter := Trim(sCondicao);

   if Trim(sCondicao) <> '' then begin
      frmMain.cdsListaProj.Filtered := True;
   end;
end;

procedure TLimpaDcu.LimparDcu;
var
   aDcuFiles: TStringList;
   sFileName: string;
   sDcuPath: string;
   iProjetosProcessados: Integer;
   iArquivosExcluidos: Integer;
   iFalhas: Integer;
begin
   aDcuFiles := TStringList.Create;
   try
      iProjetosProcessados := 0;
      iArquivosExcluidos := 0;
      iFalhas := 0;

      FiltrarCds('SEL = True');
      try
         if frmMain.cdsListaProj.RecordCount = 0 then begin
            tDialogos.NenhumProjetoSelecionado('limpar os DCUs');
            Exit;
         end;

         if not tDialogos.Confirmar(
            'Gostaria de excluir os DCUs dos projetos selecionados?',
            'Limpeza de DCUs',
            bcpNao
            ) then begin
            Exit;
         end;

         RegistrarLog('============================================================');
         RegistrarLog('Iniciando limpeza de DCUs.');

         frmMain.cdsListaProj.First;
         while not frmMain.cdsListaProj.Eof do begin
            Inc(iProjetosProcessados);
            sDcuPath := frmMain.cdsListaProjCAMINHOPROJ.AsWideString;

            frmMain.stsRodape.Panels[STS_PRJ].Text := 'Projeto atual: ' +
               frmMain.cdsListaProjNOMEPROJ.AsWideString;
            RegistrarLog('Projeto: ' + frmMain.cdsListaProjNOMEPROJ.AsWideString +
               ' | ' + sDcuPath);
            AtualizarInterface;

            if not CaminhoSeguroParaLimpeza(sDcuPath) then begin
               Inc(iFalhas);
               RegistrarLog('IGNORADO | Caminho inexistente, raiz ou reparse point: ' + sDcuPath);
               frmMain.cdsListaProj.Next;
               Continue;
            end;

            aDcuFiles.Clear;
            ListarDcus(sDcuPath, aDcuFiles, iFalhas);

            for sFileName in aDcuFiles do begin
               try
                  TFile.Delete(sFileName);
                  Inc(iArquivosExcluidos);
                  RegistrarLog('Arquivo excluído: ' + sFileName);
               except
                  on E: Exception do begin
                     Inc(iFalhas);
                     RegistrarLog('ERRO | ' + sFileName + ' | ' + E.Message);
                  end;
               end;
            end;

            AtualizarInterface;
            frmMain.cdsListaProj.Next;
         end;

         RegistrarLog('Limpeza finalizada. Projetos: ' + IntToStr(iProjetosProcessados) +
            ' | Arquivos: ' + IntToStr(iArquivosExcluidos) +
            ' | Falhas: ' + IntToStr(iFalhas));
         tDialogos.ResumoLimpeza(iProjetosProcessados, iArquivosExcluidos, iFalhas);
      finally
         frmMain.stsRodape.Panels[STS_PRJ].Text := 'Projeto atual: ';
         FiltrarCds('');

         if frmMain.cdsListaProj.Active then begin
            frmMain.cdsListaProj.First;
         end;
      end;
   finally
      FreeAndNil(aDcuFiles);
   end;
end;

procedure TLimpaDcu.ListarDcus(const sPasta: string; aArquivos: TStrings;
   var iFalhas: Integer);
var
   aDcusPasta: TArray<string>;
   aSubPastas: TArray<string>;
   iAtributos: DWORD;
   sArquivo: string;
   sSubPasta: string;
begin
   try
      aDcusPasta := TDirectory.GetFiles(sPasta, '*.dcu', TSearchOption.soTopDirectoryOnly);
      for sArquivo in aDcusPasta do begin
         aArquivos.Add(sArquivo);
      end;
   except
      on E: Exception do begin
         Inc(iFalhas);
         RegistrarLog('ERRO | Não foi possível listar DCUs em: ' + sPasta + ' | ' + E.Message);
      end;
   end;

   try
      aSubPastas := TDirectory.GetDirectories(sPasta, '*', TSearchOption.soTopDirectoryOnly);
   except
      on E: Exception do begin
         Inc(iFalhas);
         RegistrarLog('ERRO | Não foi possível listar subpastas em: ' + sPasta +
            ' | ' + E.Message);
         Exit;
      end;
   end;

   for sSubPasta in aSubPastas do begin
      iAtributos := GetFileAttributes(PChar(sSubPasta));

      if iAtributos = INVALID_FILE_ATTRIBUTES then begin
         Inc(iFalhas);
         RegistrarLog('ERRO | Não foi possível consultar os atributos da pasta: ' + sSubPasta);
         Continue;
      end;

      if (iAtributos and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then begin
         RegistrarLog('IGNORADO | Link/junction fora da varredura: ' + sSubPasta);
         Continue;
      end;

      ListarDcus(sSubPasta, aArquivos, iFalhas);
   end;
end;

procedure TLimpaDcu.RegistrarLog(const sMensagem: string);
begin
   frmMain.mmoLog.Lines.Add(sMensagem);
   frmMain.mmoLog.SelStart := Length(frmMain.mmoLog.Text);
   frmMain.mmoLog.Perform(EM_SCROLLCARET, 0, 0);
   tLogAplicacao.Registrar(sMensagem);
end;

procedure TLimpaDcu.SelecionarRegistro(bTodos: Boolean);
var
   bSelecionar: Boolean;
begin
   if not frmMain.cdsListaProj.Active or frmMain.cdsListaProj.IsEmpty then begin
      Exit;
   end;

   if not bTodos then begin
      frmMain.cdsListaProj.Edit;
      frmMain.cdsListaProjSEL.AsBoolean := not frmMain.cdsListaProjSEL.AsBoolean;
      frmMain.cdsListaProj.Post;
      Exit;
   end;

   bSelecionar := False;
   frmMain.cdsListaProj.First;

   while not frmMain.cdsListaProj.Eof do begin
      if not frmMain.cdsListaProjSEL.AsBoolean then begin
         bSelecionar := True;
         Break;
      end;
      frmMain.cdsListaProj.Next;
   end;

   frmMain.cdsListaProj.DisableControls;
   try
      frmMain.cdsListaProj.First;
      while not frmMain.cdsListaProj.Eof do begin
         frmMain.cdsListaProj.Edit;
         frmMain.cdsListaProjSEL.AsBoolean := bSelecionar;
         frmMain.cdsListaProj.Post;
         frmMain.cdsListaProj.Next;
      end;
      frmMain.cdsListaProj.First;
   finally
      frmMain.cdsListaProj.EnableControls;
   end;
end;

end.
