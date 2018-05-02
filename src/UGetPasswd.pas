unit UGetPasswd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls;

type
  TfGetPassword = class(TForm)
    MDP: TMaskEdit;
    Label1: TLabel;
    Panel1: TPanel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    PasswordSais : string;
  end;


implementation

{$R *.dfm}

procedure TfGetPassword.Button1Click(Sender: TObject);
begin
	if MDP.Text <> '' then
  begin
    PasswordSais := MDP.Text;
  end;
end;

end.
