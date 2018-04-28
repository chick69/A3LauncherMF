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
    CBProfileName: TComboBox;
    CBERRORS: TCheckBox;
    CBNOPAUSE: TCheckBox;
    CBWINDOWED: TCheckBox;
    CBFILEPACHING: TCheckBox;
    CBCHECKSIGN: TCheckBox;
    CBENABLEBATTLEYE: TCheckBox;
    CBRESTART: TCheckBox;
    CBEnabledHT: TCheckBox;
    CBNoSplash: TCheckBox;
    CBWorldEmpty: TCheckBox;
    CBNologs: TCheckBox;
    CBMEMALLOUE: TComboBox;
    SELNBCORES: TComboBox;
    CBNbEXthreads: TComboBox;
    CBMALLOC: TComboBox;
    LEMPLADDONS: TLabel;
    EMPLADDONS: TEdit;
    SelAddons: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ActionList2: TActionList;
    Action2: TAction;
    Label6: TLabel;
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
    procedure  SaveParams;
    procedure SelAddonsClick(Sender: TObject);
  private
  	NbCores : integer;
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
    function GetMemDispo : integer;
    procedure RempliCBProfils;
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
  II : integer;
  MaxDispo : integer;
  CurMem : integer;
begin
  AppBarShow(0);
  RempliCBProfils;
  //
  NbCores := System.CPUCount;
  SELNBCORES.Items.Clear;
  SELNBCORES.Items.Add('<<Défaut>>') ; SELNBCORES.ItemIndex := 0;
  CBNbEXthreads.Items.clear;
  CBNbEXthreads.Items.Add('<<Défaut>>') ; CBNbEXthreads.ItemIndex := 0;
  for II := 1 to nbCores do
  begin
  	SELNBCORES.Items.Add(inttoStr(II)) ;
    if odd(II) then CBNbEXthreads.Items.Add(inttoStr(II));
  end;
{$IFDEF WIN32}
  CBMEMALLOUE.Items.Clear;
  CBMEMALLOUE.AddItem('<<Défaut>>',nil); CBMEMALLOUE.ItemIndex := 0;
  CBMEMALLOUE.AddItem('1024',nil);
  CBMEMALLOUE.AddItem('2047',nil);
{$ENDIF}
{$IFDEF WIN64}
  MaxDispo := GetMemDispo;
  CBMEMALLOUE.Items.Clear;
  CBMEMALLOUE.AddItem('<<Défaut>>',nil); CBMEMALLOUE.ItemIndex := 0;
  for II := 1 to 16 do
  begin
    CurMem := (II * 1024) - 1;
    if MaxDispo > CurMem then CBMEMALLOUE.AddItem(InttoStr(Curmem),nil) else break;
  end;
{$ENDIF}
  CBMALLOC.Items.Clear;
  CBMALLOC.AddItem('<<Défaut>>',nil); CBMALLOC.ItemIndex := 0;
  //
  GameEnv.SetInfosToForm;
end;

function TDetailForm.GetMemDispo: integer;
Var Memory : TMemoryStatus;
begin
  Memory.dwLength:=SizeOf(Memory);
  GlobalMemoryStatus(Memory);
  result := (Memory.dwAvailPhys div 262144) div 5;
end;

procedure TDetailForm.RempliCBProfils;
var Info   : TSearchRec;
    TheDepart,TheProfile: string;
begin
  CBProfileName.Items.Clear;
  CBProfileName.AddItem('<<Défaut>>',nil); CBProfileName.ItemIndex := 0;
  //
  TheDepart := IncludeTrailingBackslash(IncludeTrailingBackslash(GetSpecialFolder ('Personal'))+'Arma 3 - Other Profiles');
  If FindFirst(TheDepart+'*.*',faAnyFile,Info)=0 Then
  begin
    repeat
      If (info.Name<>'.')And(info.Name<>'..') then
      begin
        If Not((Info.Attr And faDirectory)=0) then
        begin
          TheProfile := IncludeTrailingBackslash(TheDepart+Info.Name)+Info.name+'.Arma3Profile';
          if FileExists (TheProfile) then
          begin
            CBProfileName.AddItem(StringReplace (Info.name,'%20',' ',[rfReplaceAll]),nil);
          end;

        end;

      end;
    until FindNext (Info)<>0;
  end;
  FindClose(Info);
end;

procedure TDetailForm.SaveParams;
begin
  GameEnv.SaveParams;
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

procedure TDetailForm.SelAddonsClick(Sender: TObject);
var TT : string;
begin
	TT :=  SelectionneRepert (ExtractFilePath(Application.ExeName));
  if TT <> ''  then
  begin
		EMPLADDONS.Text := TT;
  end;
end;

procedure TDetailForm.BackToMainForm(Sender: TObject);
begin
  SaveParams;
  Hide;
  GridForm.BringToFront;
end;

end.
