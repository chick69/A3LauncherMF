unit Secondary;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr;

type
  TDetailForm = class(TForm)
    Panel1: TPanel;
    TitleLabel: TLabel;
    Image1: TImage;
    ScrollBox1: TScrollBox;
    TextPanel: TPanel;
    ItemTitle: TLabel;
    ItemSubtitle: TLabel;
    Image2: TImage;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    AppBar: TPanel;
    GestureManager1: TGestureManager;
    ActionList1: TActionList;
    Action1: TAction;
    CloseButton: TImage;
    procedure BackToMainForm(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
  private
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
  public
    { Déclarations publiques }
  end;

var
  DetailForm: TDetailForm = nil;

implementation

{$R *.dfm}

uses MainForm;

procedure TDetailForm.Action1Execute(Sender: TObject);
begin
  AppBarShow(-1);
end;

const
  AppBarHeight = 75;

procedure TDetailForm.AppBarResize;
begin
  AppBar.SetBounds(0, AppBar.Parent.Height - AppBarHeight,
    AppBar.Parent.Width, AppBarHeight);
end;

procedure TDetailForm.AppBarShow(mode: integer);
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

procedure TDetailForm.FormCreate(Sender: TObject);
var
  LStyle: TCustomStyleServices;
  MemoColor, MemoFontColor: TColor;
begin
  // Définir la couleur d'arrière-plan des mémos sur la couleur de la fiche, depuis le style actif.
  LStyle := TStyleManager.ActiveStyle;
  MemoColor := LStyle.GetStyleColor(scGenericBackground);
  MemoFontColor := LStyle.GetStyleFontColor(sfButtonTextNormal);

  Memo1.Color := MemoColor;
  Memo1.Font.Color := MemoFontColor;
  Memo2.Color := MemoColor;
  Memo2.Font.Color := MemoFontColor;
  Memo3.Color := MemoColor;
  Memo3.Font.Color := MemoFontColor;
  Memo4.Color := MemoColor;
  Memo4.Font.Color := MemoFontColor;

  // Remplir l'image
  GridForm.PickImageColor(Image2, clBtnShadow);
end;

procedure TDetailForm.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  AppBarShow(0);
end;

procedure TDetailForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    AppBarShow(-1)
  else
    AppBarShow(0);
end;

procedure TDetailForm.FormResize(Sender: TObject);
begin
  AppBarResize;
end;

procedure TDetailForm.FormShow(Sender: TObject);
var
  GroupElements: TStringList;
  memoStr: String;
begin
  AppBarShow(0);
  // Afficher le titre du badge d'origine
  GroupElements:= TStringList.Create;
  try
    GroupElements.Delimiter := '_';
    GroupElements.DelimitedText := GridForm.SelectedGroup;
    TitleLabel.Caption := 'Title: ' + GroupElements[0];
    ItemTitle.Caption :=  'Item Title: ' + GroupElements[1];
  finally
    GroupElements.Free;
  end;

  // Remplir les mémos
  (*
  memoStr := GenericText + sLineBreak + sLineBreak +
                  GenericText + sLineBreak + sLineBreak  +
                  GenericText + sLineBreak + sLineBreak  +
                  GenericText + sLineBreak + sLineBreak  +
                  GenericText + sLineBreak + sLineBreak  +
                  GenericText + sLineBreak + sLineBreak;

//  Memo1.lines.add(memoStr);
//  Memo2.Lines.Add(memoStr);
//  Memo3.Lines.Add(memoStr);
//  Memo4.Lines.Add(memoStr);
*)
end;

procedure TDetailForm.BackToMainForm(Sender: TObject);
begin
  Hide;
  GridForm.BringToFront;
end;

end.
