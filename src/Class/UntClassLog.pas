unit UntClassLog;

interface

type
   tLogAplicacao = class
   public
      class procedure Registrar(const sMensagem: string); static;
   end;

implementation

uses
   System.Classes,
   System.SysUtils,
   System.IOUtils,
   UntClassAplicacao;

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
