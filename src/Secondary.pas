unit Secondary;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons
{$IFDEF WINDOWS}
  ,Vcl.FileCtrl
{$ENDIF}
  ;

type
  TDetailForm = class(TForm)
    Panel1: TPanel;
    TitleLabel: TLabel;
    Image1: TImage;
    AppBar: TPanel;
    GestureManager1: TGestureManager;
    ActionList1: TActionList;
    Action1: TAction;
    CloseButton: TImage;
    ScrollBox1: TScrollBox;
    GBArma: TGroupBox;
    GBOptimisations: TGroupBox;
    EmplArma: TEdit;
    Label1: TLabel;
    SBSelRepert: TSpeedButton;
    CBProfile: TCheckBox;
    CBProfileName: TComboBox;
    CBERRORS: TCheckBox;
    CBNOPAUSE: TCheckBox;
    CBWINDOWED: TCheckBox;
    CBFILEPACHING: TCheckBox;
    CBCHECKSIGN: TCheckBox;
    CBENABLEBATTLEYE: TCheckBox;
    CBRESTART: TCheckBox;
    CBMem: TCheckBox;
    CBCPU: TCheckBox;
    CEXthreads: TCheckBox;
    CMALLOC: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CBTHREADS: TCheckBox;
    CheckBox8: TCheckBox;
    CBMEMALLOUE: TComboBox;
    SELNBCORES: TComboBox;
    ComboBox3: TComboBox;
    CBMALLOC: TComboBox;
    procedure BackToMainForm(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SBSelRepertClick(Sender: TObject);
  private
  	NbCores : integer;
    maxMemory : integer;
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
  public
    { Déclarations publiques }
  end;

  var  DetailForm : TdetailForm;

implementation
uses MainForm,UUtils;


{$R *.dfm}


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

procedure TDetailForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	//
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
  II : integer;
begin
  AppBarShow(0);
  NbCores := System.CPUCount;
  for II := 1 to nbCores do
  begin
  	SELNBCORES.Items.Add(inttoStr(II)) ;
  end;
{$IFDEF WIN32}
{$ENDIF}
{$IFDEF WIN64}
{$ENDIF}  
  //   
  // Afficher le titre du badge d'origine
  GroupElements:= TStringList.Create;
  try
    GroupElements.Delimiter := '_';
    GroupElements.DelimitedText := GridForm.SelectedGroup;
  finally
    GroupElements.Free;
  end;
end;

procedure TDetailForm.SBSelRepertClick(Sender: TObject);
var TT : string;
begin
	TT :=  SelectionneRepert (ExtractFilePath(Application.ExeName));
  if TT <> ''  then
  begin
		EmplArma.Text := TT;  
  end;
end;

procedure TDetailForm.BackToMainForm(Sender: TObject);
begin
  Hide;
  GridForm.BringToFront;
end;

end.
