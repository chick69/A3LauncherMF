unit UGestAddons;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons
  ,Vcl.FileCtrl
  ;

type
  TDetailAddons = class(TForm)
    Panel1: TPanel;
    TitleLabel: TLabel;
    Image1: TImage;
    AppBar: TPanel;
    GestureManager1: TGestureManager;
    ActionList1: TActionList;
    Action1: TAction;
    CloseButton: TImage;
    ScrollBox1: TScrollBox;
    procedure BackToMainForm(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
  public
    { Déclarations publiques }
  end;

  var  DetailAddons : TDetailAddons;

implementation
uses MainForm,UUtils;


{$R *.dfm}


procedure TDetailAddons.Action1Execute(Sender: TObject);
begin
  AppBarShow(-1);
end;

const
  AppBarHeight = 75;

procedure TDetailAddons.AppBarResize;
begin
  AppBar.SetBounds(0, AppBar.Parent.Height - AppBarHeight,
    AppBar.Parent.Width, AppBarHeight);
end;

procedure TDetailAddons.AppBarShow(mode: integer);
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

procedure TDetailAddons.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	//
end;

procedure TDetailAddons.FormCreate(Sender: TObject);
var
  LStyle: TCustomStyleServices;
  MemoColor, MemoFontColor: TColor;
begin
  // Définir la couleur d'arrière-plan des mémos sur la couleur de la fiche, depuis le style actif.
  LStyle := TStyleManager.ActiveStyle;
  MemoColor := LStyle.GetStyleColor(scGenericBackground);
  MemoFontColor := LStyle.GetStyleFontColor(sfButtonTextNormal);

end;

procedure TDetailAddons.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  AppBarShow(0);
end;

procedure TDetailAddons.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    AppBarShow(-1)
  else
    AppBarShow(0);
end;

procedure TDetailAddons.FormResize(Sender: TObject);
begin
  AppBarResize;
end;

procedure TDetailAddons.FormShow(Sender: TObject);
begin
  AppBarShow(0);
end;

procedure TDetailAddons.BackToMainForm(Sender: TObject);
begin
  Hide;
  GridForm.BringToFront;
end;

end.
