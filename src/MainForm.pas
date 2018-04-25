unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.ImgList, System.Actions,
  Vcl.ActnList, Vcl.Touch.GestureMgr,Shellapi;

type
  TGridForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    GroupPanel1: TPanel;
    Label2: TLabel;
    FlowPanel1: TFlowPanel;
    GroupPanel1_1: TPanel;
    GroupPanel1_2: TPanel;
    Image1: TImage;
    Image2: TImage;
    Panel6: TPanel;
    Label5: TLabel;
    GroupPanel1_3: TPanel;
    Image3: TImage;
    Panel4: TPanel;
    Label6: TLabel;
    GroupPanel2: TPanel;
    FlowPanel2: TFlowPanel;
    Label7: TLabel;
    GroupPanel2_1: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    Image4: TImage;
    Panel2: TPanel;
    GroupPanel2_2: TPanel;
    Panel3: TPanel;
    Image5: TImage;
    GroupPanel3: TPanel;
    FlowPanel3: TFlowPanel;
    GroupPanel3_1: TPanel;
    GroupPanel3_2: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Image6: TImage;
    Image7: TImage;
    ScrollBox2: TScrollBox;
    Label10: TLabel;
    AppBar: TPanel;
    Image11: TImage;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Panel7: TPanel;
    GestureManager1: TGestureManager;
    Panel5: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    GroupPanel3_4: TPanel;
    Panel11: TPanel;
    Label19: TLabel;
    Label20: TLabel;
    procedure ScrollBox2Resize(Sender: TObject);
    procedure GroupPanel1_1Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
  private
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
  public
    { Déclarations publiques }
    SelectedGroup: String;  // chaîne de groupe depuis
    procedure PickImageColor(img: TImage; AColor: TColor);
  end;

const GenericText = 'Sed ut perspiciatis unde omnis iste natus error ' +
  'sit voluptatem accusantium doloremque laudantium, totam rem aperiam, ' +
  'eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae ' +
  'vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas ' +
  'sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores ' +
  'eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, ' +
  'qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, ' +
  'sed quia non numquam eius modi tempora incidunt ut labore et dolore ' +
  'magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis ' +
  'nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut ' +
  'aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit ' +
  'qui in ea voluptate velit esse quam nihil molestiae consequatur, vel ' +
  'illum qui dolorem eum fugiat quo voluptas nulla pariatur?';

var
  GridForm: TGridForm;

implementation

{$R *.dfm}

uses Secondary;

const
  AppBarHeight = 75;

procedure TGridForm.AppBarResize;
begin
  AppBar.SetBounds(0, AppBar.Parent.Height - AppBarHeight,
    AppBar.Parent.Width, AppBarHeight);
end;

procedure TGridForm.AppBarShow(mode: integer);
begin
  if mode = -1 then // Basculer
    mode := integer(not AppBar.Visible );

  if mode = 0 then
    AppBar.Visible := False
  else
  begin
    AppBar.Visible := True;
    AppBar.BringToFront;
  end;
end;

procedure TGridForm.Action1Execute(Sender: TObject);
begin
  AppBarShow(-1);
end;

procedure TGridForm.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  AppBarShow(0);
end;

procedure TGridForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    AppBarShow(-1)
  else
    AppBarShow(0);
end;

procedure TGridForm.FormResize(Sender: TObject);
begin
  AppBarResize;
end;

procedure TGridForm.FormShow(Sender: TObject);
begin
  AppBarShow(0);
end;

procedure TGridForm.GroupPanel1_1Click(Sender: TObject);
begin
  // Supposer ici que l'image sera cliquée
  SelectedGroup := TPanel(TControl(Sender).Parent).Name;
  if not Assigned(DetailForm) then
    DetailForm := TDetailForm.Create(Self);
  DetailForm.Show;
  DetailForm.BringToFront;
end;

procedure TGridForm.Image11Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TGridForm.Image6Click(Sender: TObject);
begin
  ShellExecute (Application.Handle,'OPEN','ts3server://mercenaires-francais.fr',nil,nil,SW_SHOWDEFAULT);
end;

procedure TGridForm.Image7Click(Sender: TObject);
begin
  ShellExecute (Application.Handle,'OPEN','http://mercenaires-francais.fr',nil,nil,SW_SHOWDEFAULT);
end;

procedure TGridForm.PickImageColor(img: TImage; AColor: TColor);
begin
  Img.Canvas.Brush.Color := AColor;
  Img.Canvas.Brush.Style := bsSolid;
  Img.Canvas.FillRect(img.ClientRect);
  Img.Canvas.Refresh;
end;

procedure TGridForm.ScrollBox2Resize(Sender: TObject);
begin
  GroupPanel1.Height := TControl(Sender).ClientHeight-10;
  GroupPanel2.Height := TControl(Sender).ClientHeight-10;
  GroupPanel3.Height := TControl(Sender).ClientHeight-10;
end;

end.
