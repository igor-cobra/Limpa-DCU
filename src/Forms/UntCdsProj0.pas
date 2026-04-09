unit UntCdsProj0;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,
  System.IOUtils;

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
  private
    FSalvar: Boolean;
  public
    { Public declarations }
  published
    property Salvar: Boolean read FSalvar;
  end;

var
  FrmCdsProj0: TFrmCdsProj0;

implementation

uses
  UntClassDialogos;

{$R *.dfm}

procedure TFrmCdsProj0.btnOkClick(Sender: TObject);
begin
   if Trim(fldNomeProjeto.Text) = '' then begin
      tDialogos.CampoObrigatorio('Nome do projeto');
      fldNomeProjeto.SetFocus;
   end else begin
      if Trim(fldCaminhoProjeto.Text) = '' then begin
         tDialogos.CampoObrigatorio('Caminho do projeto');
         fldCaminhoProjeto.SetFocus;
      end else begin
         if not TDirectory.Exists(fldCaminhoProjeto.Text) then begin
            tDialogos.CaminhoNaoEncontrado(fldCaminhoProjeto.Text);
            fldCaminhoProjeto.SetFocus;
         end else begin
            FSalvar := True;
            ModalResult := mrOk;
         end;
      end;
   end;
end;

procedure TFrmCdsProj0.btnProcurarProjetoClick(Sender: TObject);
begin
   if dlgCaminhoProjeto.Execute then begin
      fldCaminhoProjeto.Text := dlgCaminhoProjeto.FileName;
   end;
end;

procedure TFrmCdsProj0.FormCreate(Sender: TObject);
begin
   FSalvar := False;
   dlgCaminhoProjeto.Options := dlgCaminhoProjeto.Options + [fdoPickFolders, fdoPathMustExist];
end;

end.
