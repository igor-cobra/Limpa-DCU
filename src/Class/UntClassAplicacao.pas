unit UntClassAplicacao;

interface

uses
   Winapi.Windows,
   System.SysUtils;

type
   tAplicacao = class
   private
      class var hMutexAplicacao: THandle;
      class var sPastaDados: string;

      class function ObterPastaDadosPadrao: string; static;
      class function ObterPastaDadosFallback: string; static;
      class function ObterVersaoArquivo(const sArquivo: string): string; static;
      class function CopiarBancoLegado(const sOrigem: string): Boolean; static;
      class procedure ExcluirArquivoLegadoUsuario(const sArquivo: string); static;
      class procedure ExcluirPastaLegadaUsuario(const sPasta: string); static;
   public
      class function Inicializar: Boolean; static;
      class procedure Finalizar; static;
      class function ProcessarModoManutencao: Boolean; static;
      class function GarantirDiretorios: Boolean; static;
      class function MigrarDadosLegados: Boolean; static;
      class procedure LimparLegadoUsuario; static;

      class function Nome: string; static;
      class function AppUserModelID: string; static;
      class function Versao: string; static;
      class function Arquitetura: string; static;
      class function ConfiguracaoBuild: string; static;
      class function CaminhoAplicacao: string; static;
      class function PastaDados: string; static;
      class function PastaBanco: string; static;
      class function CaminhoBanco: string; static;
      class function PastaLogs: string; static;
      class function ArquivoLog: string; static;
   end;

implementation

uses
   System.Classes,
   System.IOUtils;

const
   NOME_APLICACAO = 'LimpaDCU';
   APP_USER_MODEL_ID = 'SucoDev.LimpaDCU';
   MUTEX_APLICACAO = 'Local\SucoDev.LimpaDCU';

{ tAplicacao }

class function tAplicacao.AppUserModelID: string;
begin
   Result := APP_USER_MODEL_ID;
end;

class function tAplicacao.Arquitetura: string;
begin
{$IFDEF WIN64}
   Result := 'Win64';
{$ELSE}
   Result := 'Win32';
{$ENDIF}
end;

class function tAplicacao.ArquivoLog: string;
begin
   Result := IncludeTrailingPathDelimiter(PastaLogs) +
      'LimpaDCU_' + FormatDateTime('yyyymmdd', Date) + '.log';
end;

class function tAplicacao.CaminhoAplicacao: string;
begin
   Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

class function tAplicacao.CaminhoBanco: string;
begin
   Result := IncludeTrailingPathDelimiter(PastaBanco) + 'database.db';
end;

class function tAplicacao.ConfiguracaoBuild: string;
begin
{$IFDEF DEBUG}
   Result := 'Debug';
{$ELSE}
   Result := 'Release';
{$ENDIF}
end;

class function tAplicacao.CopiarBancoLegado(const sOrigem: string): Boolean;
var
   iTamanhoOrigem: Int64;
   iTamanhoDestino: Int64;
   sDestino: string;
   sTemporario: string;
begin
   Result := False;

   if not FileExists(sOrigem) then begin
      Exit;
   end;

   sDestino := CaminhoBanco;

   if SameText(ExpandFileName(sOrigem), ExpandFileName(sDestino)) then begin
      Result := True;
      Exit;
   end;

   if FileExists(sDestino) then begin
      Result := True;
      Exit;
   end;

   sTemporario := sDestino + '.migrando';
   DeleteFile(sTemporario);

   try
      TFile.Copy(sOrigem, sTemporario, True);
      iTamanhoOrigem := TFile.GetSize(sOrigem);
      iTamanhoDestino := TFile.GetSize(sTemporario);

      if (iTamanhoOrigem <= 0) or (iTamanhoOrigem <> iTamanhoDestino) then begin
         DeleteFile(sTemporario);
         Exit;
      end;

      TFile.Move(sTemporario, sDestino);
      Result := FileExists(sDestino);
   except
      DeleteFile(sTemporario);
      Result := False;
   end;
end;

class procedure tAplicacao.ExcluirArquivoLegadoUsuario(const sArquivo: string);
begin
   try
      if FileExists(sArquivo) then begin
         DeleteFile(sArquivo);
      end;
   except
      // Limpeza de legado é executada em melhor esforço.
   end;
end;

class procedure tAplicacao.ExcluirPastaLegadaUsuario(const sPasta: string);
begin
   try
      if DirectoryExists(sPasta) then begin
         TDirectory.Delete(sPasta, True);
      end;
   except
      // Limpeza de legado é executada em melhor esforço.
   end;
end;

class procedure tAplicacao.Finalizar;
begin
   if hMutexAplicacao <> 0 then begin
      CloseHandle(hMutexAplicacao);
      hMutexAplicacao := 0;
   end;
end;

class function tAplicacao.GarantirDiretorios: Boolean;
var
   sFallback: string;
begin
   Result := False;

   if sPastaDados = '' then begin
      sPastaDados := ObterPastaDadosPadrao;
   end;

   try
      ForceDirectories(PastaBanco);
      ForceDirectories(PastaLogs);
      Result := DirectoryExists(PastaBanco) and DirectoryExists(PastaLogs);
   except
      Result := False;
   end;

   if Result then begin
      Exit;
   end;

   sFallback := ObterPastaDadosFallback;
   sPastaDados := sFallback;

   try
      ForceDirectories(PastaBanco);
      ForceDirectories(PastaLogs);
      Result := DirectoryExists(PastaBanco) and DirectoryExists(PastaLogs);
   except
      Result := False;
   end;
end;

class function tAplicacao.Inicializar: Boolean;
begin
   if not GarantirDiretorios then begin
      raise Exception.Create('Não foi possível preparar a pasta de dados do LimpaDCU.');
   end;

   if not MigrarDadosLegados then begin
      raise Exception.Create('Não foi possível migrar o banco de dados de uma versão anterior.');
   end;

   hMutexAplicacao := CreateMutex(nil, True, PChar(MUTEX_APLICACAO));

   if hMutexAplicacao = 0 then begin
      RaiseLastOSError;
   end;

   if GetLastError = ERROR_ALREADY_EXISTS then begin
      CloseHandle(hMutexAplicacao);
      hMutexAplicacao := 0;
      Exit(False);
   end;

   Result := True;
end;

class procedure tAplicacao.LimparLegadoUsuario;
var
   sAppData: string;
   sLocalAppData: string;
begin
   sAppData := GetEnvironmentVariable('APPDATA');
   sLocalAppData := GetEnvironmentVariable('LOCALAPPDATA');

   if sAppData <> '' then begin
      ExcluirPastaLegadaUsuario(IncludeTrailingPathDelimiter(sAppData) + 'Limpa DCU');
      ExcluirPastaLegadaUsuario(IncludeTrailingPathDelimiter(sAppData) + 'LimpaDCU');
      ExcluirArquivoLegadoUsuario(
         IncludeTrailingPathDelimiter(sAppData) +
         'Microsoft\Internet Explorer\Quick Launch\LimpaDCU.lnk'
         );
      ExcluirArquivoLegadoUsuario(
         IncludeTrailingPathDelimiter(sAppData) +
         'Microsoft\Internet Explorer\Quick Launch\Limpa DCU.lnk'
         );
   end;

   if sLocalAppData <> '' then begin
      ExcluirPastaLegadaUsuario(IncludeTrailingPathDelimiter(sLocalAppData) + 'Limpa DCU');
      ExcluirPastaLegadaUsuario(IncludeTrailingPathDelimiter(sLocalAppData) + 'LimpaDCU');
   end;
end;

class function tAplicacao.MigrarDadosLegados: Boolean;
var
   aOrigens: TStringList;
   bEncontrouLegado: Boolean;
   sAppData: string;
   sLocalAppData: string;
   sOrigem: string;
begin
   Result := True;

   if FileExists(CaminhoBanco) then begin
      Exit;
   end;

   bEncontrouLegado := False;
   aOrigens := TStringList.Create;
   try
      aOrigens.Add(CaminhoAplicacao + 'database.db');
      aOrigens.Add('C:\Precisa\LimpaDCU\database.db');
      aOrigens.Add('C:\Precisa\Limpa DCU\database.db');

      sAppData := GetEnvironmentVariable('APPDATA');
      if sAppData <> '' then begin
         aOrigens.Add(IncludeTrailingPathDelimiter(sAppData) + 'Limpa DCU\database.db');
         aOrigens.Add(IncludeTrailingPathDelimiter(sAppData) + 'LimpaDCU\database.db');
      end;

      sLocalAppData := GetEnvironmentVariable('LOCALAPPDATA');
      if sLocalAppData <> '' then begin
         aOrigens.Add(IncludeTrailingPathDelimiter(sLocalAppData) + 'Limpa DCU\database.db');
         aOrigens.Add(IncludeTrailingPathDelimiter(sLocalAppData) + 'LimpaDCU\database.db');
         aOrigens.Add(IncludeTrailingPathDelimiter(sLocalAppData) + 'SucoDev\LimpaDCU\database.db');
      end;

      for sOrigem in aOrigens do begin
         if not FileExists(sOrigem) then begin
            Continue;
         end;

         bEncontrouLegado := True;

         if CopiarBancoLegado(sOrigem) then begin
            Exit(True);
         end;
      end;

      Result := not bEncontrouLegado;
   finally
      FreeAndNil(aOrigens);
   end;
end;

class function tAplicacao.Nome: string;
begin
   Result := NOME_APLICACAO;
end;

class function tAplicacao.ObterPastaDadosFallback: string;
var
   sLocalAppData: string;
begin
   sLocalAppData := GetEnvironmentVariable('LOCALAPPDATA');

   if sLocalAppData = '' then begin
      Result := CaminhoAplicacao + 'runtime';
   end else begin
      Result := IncludeTrailingPathDelimiter(sLocalAppData) + 'SucoDev\LimpaDCU';
   end;

   Result := IncludeTrailingPathDelimiter(Result);
end;

class function tAplicacao.ObterPastaDadosPadrao: string;
var
   sProgramData: string;
begin
   sProgramData := GetEnvironmentVariable('PROGRAMDATA');

   if sProgramData = '' then begin
      Result := ObterPastaDadosFallback;
   end else begin
      Result := IncludeTrailingPathDelimiter(sProgramData) + 'SucoDev\LimpaDCU\';
   end;
end;

class function tAplicacao.ObterVersaoArquivo(const sArquivo: string): string;
var
   aDados: TBytes;
   iHandle: DWORD;
   iTamanho: DWORD;
   iTamanhoBuffer: UINT;
   pBuffer: Pointer;
   pInfo: PVSFixedFileInfo;
begin
   Result := '0.0.0.0';
   iHandle := 0;
   iTamanho := GetFileVersionInfoSize(PChar(sArquivo), iHandle);

   if iTamanho = 0 then begin
      Exit;
   end;

   SetLength(aDados, iTamanho);

   if not GetFileVersionInfo(PChar(sArquivo), 0, iTamanho, @aDados[0]) then begin
      Exit;
   end;

   pBuffer := nil;
   iTamanhoBuffer := 0;

   if not VerQueryValue(@aDados[0], PChar('\'), pBuffer, iTamanhoBuffer) then begin
      Exit;
   end;

   if not Assigned(pBuffer) then begin
      Exit;
   end;

   pInfo := PVSFixedFileInfo(pBuffer);
   Result := Format('%d.%d.%d.%d', [
      HiWord(pInfo.dwFileVersionMS),
      LoWord(pInfo.dwFileVersionMS),
      HiWord(pInfo.dwFileVersionLS),
      LoWord(pInfo.dwFileVersionLS)
      ]);
end;

class function tAplicacao.PastaBanco: string;
begin
   Result := IncludeTrailingPathDelimiter(PastaDados) + 'data\';
end;

class function tAplicacao.PastaDados: string;
begin
   if sPastaDados = '' then begin
      sPastaDados := ObterPastaDadosPadrao;
   end;

   Result := IncludeTrailingPathDelimiter(sPastaDados);
end;

class function tAplicacao.PastaLogs: string;
begin
   Result := IncludeTrailingPathDelimiter(PastaDados) + 'logs\';
end;

class function tAplicacao.ProcessarModoManutencao: Boolean;
var
   sParametro: string;
begin
   Result := False;

   if ParamCount = 0 then begin
      Exit;
   end;

   sParametro := LowerCase(Trim(ParamStr(1)));

   if sParametro = '/migrar-legado' then begin
      Result := True;

      if GarantirDiretorios and MigrarDadosLegados then begin
         Halt(0);
      end else begin
         Halt(1);
      end;
   end;

   if sParametro = '/limpar-legado-usuario' then begin
      Result := True;
      LimparLegadoUsuario;
      Halt(0);
   end;
end;

class function tAplicacao.Versao: string;
begin
   Result := ObterVersaoArquivo(ParamStr(0));
end;

end.
