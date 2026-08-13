unit UntCdsProj0;

interface

uses
   System.SysUtils,
   System.Classes,
   System.IOUtils,
   Vcl.Controls,
   Vcl.Forms,
   Vcl.Dialogs,
   Vcl.Buttons,
   Vcl.StdCtrls;

type
   TFrmCdsProj0 = class(TForm)
      lblNomeProjeto: TLabel;
      fldNomeProjeto: TEdit;
      fldCaminhoProjeto: TEdit;
      lblCaminhoProjeto: TLabel;
      dlgCaminhoProjeto: TFileOpenDialog;
      btnProcurarProjeto: TSpeedButton;
      btnOk: TButton;
      procedure btnProcurarProjetoClick(Sender: TObject);
      procedure btnOkClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   end;

implementation

uses
   UntClassDialogos;

{$R *.dfm}

procedure TFrmCdsProj0.btnOkClick(Sender: TObject);
begin
   if Trim(fldNomeProjeto.Text) = '' then begin
      tDialogos.CampoObrigatorio('Nome do projeto');
      fldNomeProjeto.SetFocus;
      Exit;
   end;

   if Trim(fldCaminhoProjeto.Text) = '' then begin
      tDialogos.CampoObrigatorio('Caminho do projeto');
      fldCaminhoProjeto.SetFocus;
      Exit;
   end;

   if not TDirectory.Exists(fldCaminhoProjeto.Text) then begin
      tDialogos.CaminhoNaoEncontrado(fldCaminhoProjeto.Text);
      fldCaminhoProjeto.SetFocus;
      Exit;
   end;

   ModalResult := mrOk;
end;

procedure TFrmCdsProj0.btnProcurarProjetoClick(Sender: TObject);
begin
   if dlgCaminhoProjeto.Execute then begin
      fldCaminhoProjeto.Text := dlgCaminhoProjeto.FileName;
   end;
end;

procedure TFrmCdsProj0.FormCreate(Sender: TObject);
begin
   dlgCaminhoProjeto.Options := dlgCaminhoProjeto.Options + [fdoPickFolders, fdoPathMustExist];
end;

end.
