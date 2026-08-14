unit UntClassLog;

interface

uses
   System.Classes;

type
   tLogAplicacao = class
   public
      class procedure Registrar(const sMensagem: string); static;
      class procedure RegistrarLote(aMensagens: TStrings); static;
   end;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   UntClassAplicacao;


class procedure tLogAplicacao.RegistrarLote(aMensagens: TStrings);
var
   aBuilder: TStringBuilder;
   iCont: Integer;
   sConteudo: string;
begin
   if not Assigned(aMensagens) or (aMensagens.Count = 0) then begin
      Exit;
   end;

   try
      if not tAplicacao.GarantirDiretorios then begin
         Exit;
      end;

      aBuilder := TStringBuilder.Create;
      try
         for iCont := 0 to aMensagens.Count - 1 do begin
            aBuilder.Append(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now));
            aBuilder.Append(' | ');
            aBuilder.Append(aMensagens[iCont]);
            aBuilder.Append(sLineBreak);
         end;

         sConteudo := aBuilder.ToString;
      finally
         FreeAndNil(aBuilder);
      end;

      if FileExists(tAplicacao.ArquivoLog) then begin
         TFile.AppendAllText(tAplicacao.ArquivoLog, sConteudo, TEncoding.UTF8);
      end else begin
         TFile.WriteAllText(tAplicacao.ArquivoLog, sConteudo, TEncoding.UTF8);
      end;
   except
      // O log nunca deve interromper a operação principal.
   end;
end;

class procedure tLogAplicacao.Registrar(const sMensagem: string);
var
   sLinha: string;
begin
   try
      if not tAplicacao.GarantirDiretorios then begin
         Exit;
      end;

      sLinha := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' | ' +
         sMensagem + sLineBreak;

      if FileExists(tAplicacao.ArquivoLog) then begin
         TFile.AppendAllText(tAplicacao.ArquivoLog, sLinha, TEncoding.UTF8);
      end else begin
         TFile.WriteAllText(tAplicacao.ArquivoLog, sLinha, TEncoding.UTF8);
      end;
   except
      // O log nunca deve interromper a operação principal.
   end;
end;

end.
