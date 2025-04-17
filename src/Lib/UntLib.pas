unit UntLib;

interface

uses
   Winapi.Windows, Vcl.Forms, System.SysUtils, Winapi.Messages, System.Classes;

var
   VERSAO_APL       : string;
   CAMINHO_APL      : string;
   PASTA_CONF       : string;
   PASTA_LOG        : string;
   NOME_APL         : string;
   CAMINHO_DB       : string;
   PASTA_APL         : string;

const
   InputBoxMsg     = WM_USER + 123;
   WC_MB_MSGYES    = 1;
   WC_MB_MSGNO     = 2;

type
   TPasswordBoxHelper = class
   private
      // Este método irá lidar com o evento OnKeyDown
      class procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
   public
      // Método que cria o formulário e configura o evento OnKeyDown
      class function ShowPasswordBox(sCabecalho, sTexto: string): string;
   end;

function VersaoApl: string;
procedure MsgWarning(sTexto: string; sCabecalho: string = 'Atenção');
procedure MsgErro(sTexto: string; sCabecalho: string = 'Erro');
procedure MsgInfo(sTexto: string; sCabecalho: string = 'Informação');
function MsgYesNo(sTexto: string; sCabecalho: string = 'Pergunta'; iBotaoDefault: Integer = WC_MB_MSGYES): boolean;
function PasswordBox(sCabecalho, sTexto: string): string;
procedure ClearMemory;
function IsSelectQuery(const sSql: string): Boolean;
function GetKeywordPosition(const sString, Keyword: string): Integer;
function ObterProximoNumeroArquivo(const sCaminho, sExtencao: string; const sPrefixos: array of string): Integer;
procedure SetLibraryPath(sCaminhoApl: string);
function CheckAppRunning(sAplName: string): Boolean;
function iif(condicao : boolean; verdadeiro, falso : variant):variant;

implementation

uses
   System.Math, Vcl.StdCtrls, Vcl.Controls, System.IOUtils, System.StrUtils;

function VersaoApl: string;
type
   PFFI = ^vs_FixedFileInfo;
var
   F: PFFI;
   Handle: Dword;
   Len: Longint;
   Data: Pchar;
   Buffer: Pointer;
   Tamanho: Dword;
   Parquivo: Pchar;
   Arquivo: string;
begin
   Arquivo := Application.ExeName;
   Parquivo := StrAlloc(Length(Arquivo) + 1);
   StrPcopy(Parquivo, Arquivo);
   Len := GetFileVersionInfoSize(Parquivo, Handle);
   Result := '';
   if Len > 0 then begin
      Data := StrAlloc(Len + 1);
      if GetFileVersionInfo(Parquivo, Handle, Len, Data) then begin
         VerQueryValue(Data, '', Buffer, Tamanho);

         F := PFFI(Buffer);
         Result := Format('%d.%d.%d.%d', [HiWord(F^.dwFileVersionMs), LoWord(F^.dwFileVersionMs), HiWord(F^.dwFileVersionLs), Loword(F^.dwFileVersionLs)]);
      end;
      StrDispose(Data);
   end;
   StrDispose(Parquivo);
end;

procedure MsgWarning(sTexto, sCabecalho: string);
var
   msg: string;
begin
   if sCabecalho = '' then begin
      msg := 'Atenção';
   end else begin
      msg := sCabecalho;
   end;
   Application.MessageBox(pchar(sTexto), pchar(msg), MB_ICONWARNING + MB_OK);
end;

procedure MsgErro(sTexto, sCabecalho: string);
var
   msg: string;
begin
   if sCabecalho = '' then begin
      msg := 'Erro'; //#67191
   end else begin
      msg := sCabecalho;
   end;
   Application.MessageBox(pchar(sTexto), pchar(msg), MB_ICONERROR + MB_OK);
end;

procedure MsgInfo(sTexto, sCabecalho: string);
var
   msg: string;
begin
   if sCabecalho = '' then begin
      msg := 'Atenção';
   end else begin
      msg := sCabecalho;
   end;
   Application.MessageBox(pchar(sTexto), pchar(sCabecalho), MB_ICONINFORMATION + MB_OK);
end;

function MsgYesNo(sTexto, sCabecalho: string; iBotaoDefault: Integer): boolean;
var
   msg: string;
begin
   if sCabecalho = '' then begin
      msg := 'Confirmação';
   end else begin
      msg := sCabecalho;
   end;
   if (iBotaoDefault = WC_MB_MSGYES) then begin
      Result := Application.MessageBox(pchar(sTexto), pchar(sCabecalho), MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES;
   end else begin
      Result := Application.MessageBox(pchar(sTexto), pchar(sCabecalho), MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) = IDYES;
   end;
end;

function PasswordBox(sCabecalho, sTexto: string): string;
var
   PsswdBox: TPasswordBoxHelper;
begin
   PsswdBox := TPassWordBoxHelper.Create;
   try
      Result := PsswdBox.ShowPasswordBox(sCabecalho, sTexto);
   finally
      FreeAndNil(PsswdBox);
   end;
end;

procedure ClearMemory;
var
   Handle: THandle;
begin
   try
      Handle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
      SetProcessWorkingSetSize(Handle, $FFFFFFFF, $FFFFFFFF);
      CloseHandle(Handle);
   except
      //
   end;
   Application.ProcessMessages;
end;

function IsSelectQuery(const sSql: string): Boolean;
var
   SelectPos: Integer;
   InsertPos: Integer;
   UpdatePos: Integer;
   DeletePos: Integer;
   ExecutePos: Integer;
   ReturningPos: Integer;
begin
   SelectPos    := GetKeywordPosition(UpperCase(sSql), 'SELECT');
   InsertPos    := GetKeywordPosition(UpperCase(sSql), 'INSERT');
   UpdatePos    := GetKeywordPosition(UpperCase(sSql), 'UPDATE');
   DeletePos    := GetKeywordPosition(UpperCase(sSql), 'DELETE');
   ExecutePos   := GetKeywordPosition(UpperCase(sSql), 'EXECUTE BLOCK');
   ReturningPos := GetKeywordPosition(UpperCase(sSql), 'RETURNING');

   // Verifica se SELECT aparece antes de qualquer outro comando de ação
   Result := ((SelectPos < InsertPos) and (SelectPos < UpdatePos) and (SelectPos < DeletePos) and (SelectPos < ExecutePos)) or (ReturningPos < MaxInt);
end;

function GetKeywordPosition(const sString, Keyword: string): Integer;
begin
   Result := Pos(Keyword, sString);
   if Result = 0 then begin
      Result := MaxInt; // Se a palavra não for encontrada, retornamos o maior valor inteiro possível
   end;
end;

function ObterProximoNumeroArquivo(const sCaminho, sExtencao: string; const sPrefixos: array of string): Integer;
var
  sNomeArquivo: string;
  sNomeSemExtensao: string;
  iCont: Integer;
  iPosUnderScore: Integer;
  iNumero: Integer;
  iMaiorNumero: Integer;
begin
  iMaiorNumero := 0;
  // Busca todos os arquivos no diretório que correspondem aos prefixos fornecidos
  for sNomeArquivo in TDirectory.GetFiles(sCaminho, '*' + sExtencao) do begin
    sNomeSemExtensao := TPath.GetFileNameWithoutExtension(sNomeArquivo);
    // Verifica se o nome do arquivo começa com algum dos prefixos especificados
    for iCont := Low(sPrefixos) to High(sPrefixos) do begin
      if StartsText(sPrefixos[iCont], sNomeSemExtensao) then begin
        // Busca o número no final do nome do arquivo (depois do '_')
        iPosUnderScore := LastDelimiter('_', sNomeSemExtensao);
        if iPosUnderScore > 0 then begin
          if TryStrToInt(Copy(sNomeSemExtensao, iPosUnderScore + 1, MaxInt), iNumero) then begin
            if iNumero > iMaiorNumero then
              iMaiorNumero := iNumero;
          end;
        end;
      end;
    end;
  end;
  // Retorna o próximo número disponível
  Result := iMaiorNumero + 1;
end;

{ TPasswordBoxHelper }

class procedure TPasswordBoxHelper.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case Key of
      VK_RETURN: TForm(Sender).ModalResult := mrOk;
      VK_ESCAPE: TForm(Sender).ModalResult := mrCancel;
   end;
end;

class function TPasswordBoxHelper.ShowPasswordBox(sCabecalho, sTexto: string): string;
var
   sResult: string;
   Form: TForm;
   PromptLabel: TLabel;
   EditBox: TEdit;
   OkButton: TButton;
   TextWidth: Integer;
   TextHeight: Integer;
begin
   Form := TForm.Create(nil);
   try
      Form.Position    := poScreenCenter;
      Form.Caption     := sCabecalho;
      Form.Color       := $00FAF4E5;
      Form.KeyPreview  := True;
      Form.BorderIcons := [biSystemMenu];
      Form.OnKeyDown   := FormKeyDown;

      // PromptLabel configurado para exibir o texto e alinhado ao centro
      PromptLabel           := TLabel.Create(Form);
      PromptLabel.Parent    := Form;
      PromptLabel.Caption   := sTexto;
      PromptLabel.WordWrap  := True;
      PromptLabel.Alignment := taCenter;

      // Determinando a largura e altura baseada no conteúdo e na largura máxima desejada
      Form.Canvas.Font := PromptLabel.Font;
      TextWidth        := Form.Canvas.TextWidth(sTexto);
      TextHeight       := Form.Canvas.TextHeight(sTexto) * (1 + (TextWidth div 280));
      TextWidth        := Min(TextWidth, 280);

      // Ajuste das dimensões do PromptLabel e do Form
      Form.ClientWidth := Max(300, TextWidth + 40);
      PromptLabel.SetBounds(20, 20, Form.ClientWidth - 40, TextHeight + 20);

      // Configuração do EditBox
      EditBox        := TEdit.Create(Form);
      EditBox.Parent := Form;
      EditBox.PasswordChar := '*';
      EditBox.SetBounds(50, PromptLabel.Top + PromptLabel.Height + 10, Form.ClientWidth - 100, 21);

      // Configuração do OkButton
      OkButton        := TButton.Create(Form);
      OkButton.Parent := Form;
      OkButton.Caption := 'OK';
      OkButton.ModalResult := mrOk;
      OkButton.SetBounds((Form.ClientWidth - 75) div 2, EditBox.Top + EditBox.Height + 10, 75, 25);

      // Ajuste final da altura do Form
      Form.ClientHeight := OkButton.Top + OkButton.Height + 20;

      if Form.ShowModal = mrOk then begin
         sResult := EditBox.Text;
      end else begin
         sResult := '';
      end;
   finally
      FreeAndNil(Form);
   end;

   Result := sResult;
end;

procedure SetLibraryPath(sCaminhoApl: string);
var
   sLibPath: string;
begin
   // Obter o caminho completo para a pasta 'lib'
   sLibPath := sCaminhoApl + 'lib';

   // Configurar o diretório de pesquisa de DLLs para incluir a pasta 'lib'
   if not SetDllDirectory(PChar(sLibPath)) then begin
      raise Exception.CreateFmt('Falha ao definir o diretório de pesquisa de DLL: %s', [SysErrorMessage(GetLastError)]);
   end;
end;

function CheckAppRunning(sAplName: string): Boolean;
var
   bResult: Boolean;
   tMutexHandle: THandle;
   sMutexName: string;
begin
   bResult := True;
   // Define um nome único para o Mutex
   sMutexName := 'Global\' + sAplName; //#179684
   // Tenta criar o Mutex
   tMutexHandle := CreateMutex(nil, True, PChar(sMutexName));
   // Verifica se o Mutex já existe
   if (tMutexHandle = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then begin
      // Exibe uma mensagem informando que o programa já está em execução
      MsgWarning('A aplicação já está em execução!');
      bResult := False;
   end;

   Result := bResult;
end;

function iif(condicao : boolean; verdadeiro, falso : variant):variant;
begin
   if condicao then iif := verdadeiro else iif := falso;
end;

end.

