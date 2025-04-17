unit UntCdsProj0;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls;

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

{$R *.dfm}

procedure TFrmCdsProj0.btnOkClick(Sender: TObject);
begin
   if (fldNomeProjeto.Text <> '') and (fldCaminhoProjeto.Text <> '') then begin
      FSalvar := True;
      Close;
   end;
end;

procedure TFrmCdsProj0.btnProcurarProjetoClick(Sender: TObject);
begin
   dlgCaminhoProjeto.Execute;
   fldCaminhoProjeto.Text := dlgCaminhoProjeto.FileName;
end;

procedure TFrmCdsProj0.FormCreate(Sender: TObject);
begin
   FSalvar := False;
end;

end.
