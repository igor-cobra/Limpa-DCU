unit UntClassLimpaDcu;

interface

uses
   System.Classes,
   System.SysUtils,
   System.UITypes,
   UntDtmCnx;

type
   TProjetoLimpeza = record
      Nome: string;
      Caminho: string;
   end;

   TProjetosLimpeza = array of TProjetoLimpeza;

   TLimpaDcu = class
   private
      Cnx: TdtmCnx;
      FEmProcessamento: Boolean;
      procedure AdicionarLogInterface(const sTexto: string);
      procedure AtualizarEstadoProcessamento(bProcessando: Boolean);
      procedure AtualizarProjetoAtual(const sNomeProjeto: string);
      function CapturarProjetosSelecionados: TProjetosLimpeza;
      procedure ExecutarLimpezaAssincrona(const aProjetos: TProjetosLimpeza);
      procedure FiltrarCds(const sCondicao: string);
      procedure LimparPasta(const sPasta: string; aLog: TStrings;
         var iArquivosExcluidos, iFalhas: Integer);
      procedure RegistrarLog(const sMensagem: string);
      function CaminhoSeguroParaLimpeza(const sCaminho: string): Boolean;
   public
      constructor Create(aCnx: TdtmCnx);
      procedure CarregarProjetos;
      procedure Cadastrar;
      procedure Excluir;
      procedure LimparDcu;
      procedure SelecionarRegistro(bTodos: Boolean);
      property EmProcessamento: Boolean read FEmProcessamento;
   end;

implementation

uses
   Winapi.Windows,
   Winapi.Messages,
   Data.DB,
   System.IOUtils,
   Vcl.Controls,
   UntCdsProj0,
   UntMain,
   UntClassDialogos,
   UntClassLog;

procedure TLimpaDcu.AdicionarLogInterface(const sTexto: string);
var
   aLinhas: TStringList;
begin
   if Trim(sTexto) = '' then begin
      Exit;
   end;

   aLinhas := TStringList.Create;
   try
      aLinhas.Text := sTexto;

      frmMain.mmoLog.Lines.BeginUpdate;
      try
         frmMain.mmoLog.Lines.AddStrings(aLinhas);
      finally
         frmMain.mmoLog.Lines.EndUpdate;
      end;

      frmMain.mmoLog.SelStart := Length(frmMain.mmoLog.Text);
      frmMain.mmoLog.Perform(EM_SCROLLCARET, 0, 0);
   finally
      FreeAndNil(aLinhas);
   end;
end;

procedure TLimpaDcu.AtualizarEstadoProcessamento(bProcessando: Boolean);
begin
   FEmProcessamento := bProcessando;

   frmMain.btnLimparDcu.Enabled := not bProcessando;
   frmMain.btnCadastrar.Enabled := not bProcessando;
   frmMain.btnExcluirProjeto.Enabled := not bProcessando;
   frmMain.dbgListaProj.Enabled := not bProcessando;

   if bProcessando then begin
      frmMain.stsRodape.Panels[STS_PRJ].Text := 'Preparando limpeza...';
   end else begin
      frmMain.stsRodape.Panels[STS_PRJ].Text := 'Projeto atual: ';
   end;
end;

procedure TLimpaDcu.AtualizarProjetoAtual(const sNomeProjeto: string);
begin
   frmMain.stsRodape.Panels[STS_PRJ].Text := 'Projeto atual: ' + sNomeProjeto;
end;

procedure TLimpaDcu.Cadastrar;
var
   Proj0: TFrmCdsProj0;
begin
   if FEmProcessamento then begin
      Exit;
   end;

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

function TLimpaDcu.CapturarProjetosSelecionados: TProjetosLimpeza;
var
   iIdAtual: Integer;
   iQuantidade: Integer;
begin
   SetLength(Result, 0);

   if not frmMain.cdsListaProj.Active or frmMain.cdsListaProj.IsEmpty then begin
      Exit;
   end;

   iIdAtual := frmMain.cdsListaProjIDPROJETO.AsInteger;
   iQuantidade := 0;
   SetLength(Result, frmMain.cdsListaProj.RecordCount);

   frmMain.cdsListaProj.DisableControls;
   try
      frmMain.cdsListaProj.First;
      while not frmMain.cdsListaProj.Eof do begin
         if frmMain.cdsListaProjSEL.AsBoolean then begin
            Result[iQuantidade].Nome := frmMain.cdsListaProjNOMEPROJ.AsWideString;
            Result[iQuantidade].Caminho := frmMain.cdsListaProjCAMINHOPROJ.AsWideString;
            Inc(iQuantidade);
         end;

         frmMain.cdsListaProj.Next;
      end;

      SetLength(Result, iQuantidade);

      if iIdAtual > 0 then begin
         frmMain.cdsListaProj.Locate('IDPROJETO', iIdAtual, []);
      end else begin
         frmMain.cdsListaProj.First;
      end;
   finally
      frmMain.cdsListaProj.EnableControls;
   end;
end;

constructor TLimpaDcu.Create(aCnx: TdtmCnx);
begin
   inherited Create;

   if not Assigned(aCnx) then begin
      raise Exception.Create('A conexão do LimpaDCU não foi inicializada.');
   end;

   Cnx := aCnx;
   FEmProcessamento := False;
end;

procedure TLimpaDcu.Excluir;
begin
   if FEmProcessamento then begin
      Exit;
   end;

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

procedure TLimpaDcu.ExecutarLimpezaAssincrona(const aProjetos: TProjetosLimpeza);
var
   aProjetosWorker: TProjetosLimpeza;
   aThread: TThread;
begin
   aProjetosWorker := aProjetos;

   aThread := TThread.CreateAnonymousThread(
      procedure
      var
         aLogProjeto: TStringList;
         iArquivosExcluidos: Integer;
         iFalhas: Integer;
         iIndice: Integer;
         iProjetosProcessados: Integer;
         sErroFatal: string;
         sLogProjeto: string;
      begin
         iProjetosProcessados := 0;
         iArquivosExcluidos := 0;
         iFalhas := 0;
         sErroFatal := '';

         try
            for iIndice := Low(aProjetosWorker) to High(aProjetosWorker) do begin
               if TThread.CheckTerminated then begin
                  Break;
               end;

               Inc(iProjetosProcessados);

               TThread.Synchronize(nil,
                  procedure
                  begin
                     AtualizarProjetoAtual(aProjetosWorker[iIndice].Nome);
                  end
                  );

               aLogProjeto := TStringList.Create;
               try
                  aLogProjeto.Add('Projeto: ' + aProjetosWorker[iIndice].Nome + ' | ' +
                     aProjetosWorker[iIndice].Caminho);

                  if not CaminhoSeguroParaLimpeza(aProjetosWorker[iIndice].Caminho) then begin
                     Inc(iFalhas);
                     aLogProjeto.Add('IGNORADO | Caminho inexistente, raiz ou reparse point: ' +
                        aProjetosWorker[iIndice].Caminho);
                  end else begin
                     LimparPasta(
                        aProjetosWorker[iIndice].Caminho,
                        aLogProjeto,
                        iArquivosExcluidos,
                        iFalhas
                        );
                  end;

                  tLogAplicacao.RegistrarLote(aLogProjeto);
                  sLogProjeto := aLogProjeto.Text;
               finally
                  FreeAndNil(aLogProjeto);
               end;

               TThread.Synchronize(nil,
                  procedure
                  begin
                     AdicionarLogInterface(sLogProjeto);
                  end
                  );
            end;
         except
            on E: Exception do begin
               Inc(iFalhas);
               sErroFatal := E.ClassName + ': ' + E.Message;
            end;
         end;

         TThread.Synchronize(nil,
            procedure
            begin
               if sErroFatal <> '' then begin
                  RegistrarLog('ERRO | Falha inesperada durante a limpeza | ' + sErroFatal);
               end;

               RegistrarLog('Limpeza finalizada. Projetos: ' + IntToStr(iProjetosProcessados) +
                  ' | Arquivos: ' + IntToStr(iArquivosExcluidos) +
                  ' | Falhas: ' + IntToStr(iFalhas));

               AtualizarEstadoProcessamento(False);
               tDialogos.ResumoLimpeza(iProjetosProcessados, iArquivosExcluidos, iFalhas);
            end
            );
      end
      );

   aThread.FreeOnTerminate := True;
   aThread.Start;
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
   aProjetos: TProjetosLimpeza;
begin
   if FEmProcessamento then begin
      Exit;
   end;

   aProjetos := CapturarProjetosSelecionados;

   if Length(aProjetos) = 0 then begin
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
   AtualizarEstadoProcessamento(True);

   try
      ExecutarLimpezaAssincrona(aProjetos);
   except
      on E: Exception do begin
         AtualizarEstadoProcessamento(False);
         RegistrarLog('ERRO | Não foi possível iniciar a limpeza | ' + E.Message);
         tDialogos.Erro(
            'Não foi possível iniciar a limpeza dos DCUs.',
            'Falha ao iniciar limpeza',
            E.ClassName + ': ' + E.Message
            );
      end;
   end;
end;

procedure TLimpaDcu.LimparPasta(const sPasta: string; aLog: TStrings;
   var iArquivosExcluidos, iFalhas: Integer);
var
   aBusca: TSearchRec;
   iAtributos: DWORD;
   iResultadoBusca: Integer;
   iUltimoErro: DWORD;
   sCaminho: string;
begin
   if TThread.CheckTerminated then begin
      Exit;
   end;

   iResultadoBusca := FindFirst(
      IncludeTrailingPathDelimiter(sPasta) + '*',
      faAnyFile,
      aBusca
      );

   if iResultadoBusca <> 0 then begin
      Inc(iFalhas);
      aLog.Add('ERRO | Não foi possível listar a pasta: ' + sPasta + ' | ' +
         SysErrorMessage(iResultadoBusca));
      Exit;
   end;

   try
      repeat
         if TThread.CheckTerminated then begin
            Exit;
         end;

         if (aBusca.Name <> '.') and (aBusca.Name <> '..') then begin
            sCaminho := IncludeTrailingPathDelimiter(sPasta) + aBusca.Name;

            if (aBusca.Attr and faDirectory) <> 0 then begin
               iAtributos := GetFileAttributes(PChar(sCaminho));

               if iAtributos = INVALID_FILE_ATTRIBUTES then begin
                  Inc(iFalhas);
                  aLog.Add('ERRO | Não foi possível consultar os atributos da pasta: ' +
                     sCaminho);
               end else if (iAtributos and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then begin
                  aLog.Add('IGNORADO | Link/junction fora da varredura: ' + sCaminho);
               end else begin
                  LimparPasta(sCaminho, aLog, iArquivosExcluidos, iFalhas);
               end;
            end else if SameText(ExtractFileExt(aBusca.Name), '.dcu') then begin
               if Winapi.Windows.DeleteFile(PChar(sCaminho)) then begin
                  Inc(iArquivosExcluidos);
                  aLog.Add('Arquivo excluído: ' + sCaminho);
               end else begin
                  Inc(iFalhas);
                  iUltimoErro := GetLastError;
                  aLog.Add('ERRO | ' + sCaminho + ' | ' + SysErrorMessage(iUltimoErro));
               end;
            end;
         end;

         iResultadoBusca := FindNext(aBusca);
      until iResultadoBusca <> 0;

      if (iResultadoBusca <> ERROR_NO_MORE_FILES) and
         (iResultadoBusca <> ERROR_SUCCESS) then begin
         Inc(iFalhas);
         aLog.Add('ERRO | A enumeração da pasta foi interrompida: ' + sPasta + ' | ' +
            SysErrorMessage(iResultadoBusca));
      end;
   finally
      System.SysUtils.FindClose(aBusca);
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
   if FEmProcessamento then begin
      Exit;
   end;

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
