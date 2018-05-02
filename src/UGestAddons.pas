unit UGestAddons;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons
  ,Vcl.FileCtrl, Vcl.CheckLst, Vcl.Grids,UUtils, Vcl.ComCtrls, system.zip
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
    Panel2: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    SERVALUPDATE: TSpeedButton;
    Panel3: TPanel;
    Panel6: TPanel;
    ARESUPDATE: TSpeedButton;
    Panel7: TPanel;
    GSSERVAL: TDrawGrid;
    GSARES: TDrawGrid;
    StateGreen: TImage;
    StateRed: TImage;
    ServalPg: TProgressBar;
    ServalAddonName: TLabel;
    AresAddonName: TLabel;
    AresPg: TProgressBar;
    procedure BackToMainForm(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure GSARESDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure GSSERVALDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SERVALUPDATEClick(Sender: TObject);
    procedure ARESUPDATEClick(Sender: TObject);
  private
    fServSERVAL : TServer;
    fServARES : TServer;
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
    procedure CalcCenter(TheRect: Trect; TheText: string; var PosX,
      PosY: integer);
    procedure CalcImgCenter(TheRect: Trect; var ORect: Trect);
    procedure LanceMajAddons (NomServeur : string);
    procedure RemoveLeDir(Therepert: string);
  public
    { Déclarations publiques }
    procedure redraw;
    procedure SetForm;
  end;

  var  DetailAddons : TDetailAddons;

implementation
uses MainForm;


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

procedure TDetailAddons.ARESUPDATEClick(Sender: TObject);
var XX : Integer;
begin
  if GameEnv.AddonsEmpl ='' then
  begin
    MessageBox(application.Handle,'Veuillez définir un emplacement pour les addons',PChar(GridForm.caption),MB_ICONERROR or MB_OK);
    exit;
  end;
  XX :=  MessageBox (application.Handle,'Confirmez-vous la mise à jour des addons ?',PChar(GridForm.caption),MB_ICONQUESTION or MB_OKCANCEL);

  if XX = 1 then
  begin
  	LanceMajAddons('ARES');
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
  fServSERVAL := nil;
  fServARES := nil;
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

procedure TDetailAddons.GSARESDrawCell(Sender: TObject; ACol, ARow: Integer;Rect: TRect; State: TGridDrawState);
  function GetAddon (Arow : integer) : TAddons;
  begin
    result := fServARES.LocalAddons.Items[Arow-1];
  end;

var PosX,PosY : integer;
    TheText : string;
    TheAddon : TAddons;
    TheImage : TImage;
    sRect : Trect;
begin
  if (fServARES = nil) or (GameEnv=nil) then exit;
  //
  with GSARES do
  begin
    if Arow = 0 then
    begin
      if ACol = 0 then
      begin
        TheText := 'Addon';
        canvas.Font.Style := [fsBold];
        CalcCenter (Rect,TheText,PosX,POSY);
        canvas.FillRect(Rect);
        Canvas.TextOut(POSX, POSY, TheText);
      end else
      begin
        TheText := 'Statut';
        canvas.FillRect(Rect);
        canvas.Font.Style := [fsBold];
        CalcCenter (Rect,TheText,PosX,POSY);
        Canvas.TextOut(POSX, POSY, TheText );
      end;
    end else
    begin
      TheAddon := GetAddon(Arow);
      if ACol = 0 then
      begin
        TheText := TheAddon.fDesc;
        canvas.Font.Style := [fsBold];
        CalcCenter (Rect,TheText,PosX,POSY);
        canvas.FillRect(Rect);
        Canvas.TextOut(POSX, POSY, TheText);
      end else
      begin
        if TheAddon.fOK  then TheImage := StateGreen else TheImage := StateRed;
        //
        canvas.FillRect(Rect);
        canvas.Font.Style := [fsBold];
        CalcImgCenter (Rect,SRect);
        Canvas.StretchDraw (SRect, TheImage.Picture.Graphic );
      end;
    end;
  end;
end;


procedure TDetailAddons.CalcCenter ( TheRect : Trect; TheText : string ; var PosX,PosY : integer);
begin
  PosX := TheRect.Left + (((TheRect.Right - TheRect.Left) - Canvas.TextWidth(TheText)) div 2);
  PosY := TheRect.top + (((TheRect.bottom - TheRect.top) - Canvas.TextHeight(TheText)) div 2);
end;

procedure TDetailAddons.CalcImgCenter (TheRect : Trect ;var ORect: Trect);
begin
  Orect := TheRect;
  Orect.Left  := TheRect.Left + 15;
  Orect.Right  := Orect.Left + 27;
end;

procedure TDetailAddons.GSSERVALDrawCell(Sender: TObject; ACol, ARow: Integer;Rect: TRect; State: TGridDrawState);

  function GetAddon (Arow : integer) : TAddons;
  begin
    result := fServSERVAL.LocalAddons.Items[Arow-1];
  end;

var PosX,PosY : integer;
    TheText : string;
    TheAddon : TAddons;
    TheImage : TImage;
    sRect : Trect;
begin
  if (fServSERVAL = nil) or (GameEnv=nil) then exit;
  //
  with GSSERVAL do
  begin
    if Arow = 0 then
    begin
      if ACol = 0 then
      begin
        TheText := 'Addon';
        canvas.Font.Style := [fsBold];
        CalcCenter (Rect,TheText,PosX,POSY);
        canvas.FillRect(Rect);
        Canvas.TextOut(POSX, POSY, TheText);
      end else
      begin
        TheText := 'Statut';
        canvas.FillRect(Rect);
        canvas.Font.Style := [fsBold];
        CalcCenter (Rect,TheText,PosX,POSY);
        Canvas.TextOut(POSX, POSY, TheText );
      end;
    end else
    begin
      TheAddon := GetAddon(Arow);
      if ACol = 0 then
      begin
        TheText := TheAddon.fDesc;
        canvas.Font.Style := [fsBold];
        CalcCenter (Rect,TheText,PosX,POSY);
        canvas.FillRect(Rect);
        Canvas.TextOut(POSX, POSY, TheText);
      end else
      begin
        if TheAddon.fOK  then TheImage := StateGreen else TheImage := StateRed;
        //
        canvas.FillRect(Rect);
        canvas.Font.Style := [fsBold];
        CalcImgCenter (Rect,SRect);
        Canvas.StretchDraw (SRect, TheImage.Picture.Graphic );
      end;
    end;
  end;
end;

procedure TDetailAddons.RemoveLeDir (Therepert : string);
var Info : TSearchRec;
begin
  If FindFirst(IncludeTrailingBackslash (Therepert)+'*.*',faAnyFile,Info)=0 Then
  begin
    repeat
      If (info.Name<>'.')And(info.Name<>'..') then
      begin
        If not ((Info.Attr And faDirectory)=0) then
        begin
          RemoveLeDir (IncludeTrailingBackslash (Therepert)+Info.Name);
          RemoveDir(IncludeTrailingBackslash (Therepert)+Info.Name);
        end else
        begin
          DeleteFile(IncludeTrailingBackslash (Therepert)+Info.name);
        end;
      end;
    until FindNext (Info)<>0;
  end;
  FindClose(Info);
end;

procedure TDetailAddons.LanceMajAddons(NomServeur: string);

	procedure ExLanceMajAddOns (TheAddons : TaddonsList; AddonName : Tlabel; ProgressBar : TprogressBar);	
  var II : integer;
  		XX : TDownLoad;
      ZZ : TZipFile;
  begin
    XX := TDownLoad.Create;
    TRY
      if GameEnv.AddonsEmpl = ''  then exit;
      for II := 0 to TheAddons.Count -1 do
      begin
        if not TheAddons.Items[II].fOK  then
        begin
          if XX.GetAddonsFromServeur(TheAddons.Items[II].ffile, AddonName, ProgressBar) then
          begin
 						if DirectoryExists(IncludeTrailingBackslash (GameEnv.AddonsEmpl)+TheAddons.Items[II].fname) then
            begin
              RemoveLeDir(IncludeTrailingBackslash (GameEnv.AddonsEmpl)+TheAddons.Items[II].fname);
              RemoveDir(IncludeTrailingBackslash (GameEnv.AddonsEmpl)+TheAddons.Items[II].fname);
            end;
            if AddonName<> nil then
            begin
              AddonName.Visible := true;
              AddonName.Caption := 'Décompression';
            	AddonName.Parent.Refresh;
            end;
					  ZZ := TZipFile.Create;
            TRY        
            	ZZ.Open(IncludeTrailingBackslash(LocalGetTempPath)+TheAddons.Items[II].ffile,zmRead);
            	ZZ.ExtractAll(GameEnv.AddonsEmpl) 
            FINALLY
              ZZ.Free;
            END;
            if AddonName<> nil then AddonName.visible := false;
          end else break;
        end;
      end;
    FINALLY
			XX.Free;
    END;
  end;
  
var II : integer;
begin
  for II  := 0 to GameEnv.Servers.Count -1 do
  begin
  	if GameEnv.Servers.items[II].Name = NomServeur  then
    begin
      if NomServeur = 'SERVALA' then
      begin
			  ExLanceMajAddOns (GameEnv.Servers.items[II].LocalAddons,ServalAddonName,ServalPg);
      end else if NomServeur = 'ARES' then
      begin
			  ExLanceMajAddOns (GameEnv.Servers.items[II].LocalAddons,AresAddonName,AresPg);
      end;

    end;
  end;

  GameEnv.InitAddonState;
  GameEnv.SetAddonsState;
  GameEnv.SetAddonsServerStatus;
  GameEnv.SetInfosToForm;
  
end;

procedure TDetailAddons.redraw;
var II : integer;
begin
  //
  fServSERVAL := nil;
  fServARES := nil;
  if GameEnv = nil then exit;
  
  for II  := 0 to GameEnv.Servers.Count -1 do
  begin
    if GameEnv.Servers.Items[II].Name ='SERVALA' then
    begin
      fServSERVAL := GameEnv.Servers.Items[II];
    end;
    if GameEnv.Servers.Items[II].Name ='ARES' then
    begin
      fServARES := GameEnv.Servers.Items[II];
    end;
  end;
  if fServSERVAL <>nil then
  begin
    GSSERVAL.RowCount := fServSERVAL.LocalAddons.Count +1;
    GSSERVAL.ColWidths [0] := 70 * Canvas.TextWidth('W');
    GSSERVAL.ColWidths [1] := 6 * Canvas.TextWidth('W');
    SERVALUPDATE.Enabled := not fServSERVAL.AddonsStatus;
  end else
  begin
    GSSERVAL.RowCount := 1;
    SERVALUPDATE.Enabled := false;
  end;

  if fServARES <>nil then
  begin
    GSARES.RowCount := fServARES.LocalAddons.Count +1;
    GSARES.ColWidths [0] := 70 * Canvas.TextWidth('W');
    GSARES.ColWidths [1] := 6 * Canvas.TextWidth('W');
    ARESUPDATE.Enabled := not fServARES.AddonsStatus;
  end else
  begin
    GSARES.RowCount := 1;
    ARESUPDATE.Enabled := false;
  end;
  GSSERVAL.refresh;
  GSARES.refresh;
end;

procedure TDetailAddons.SERVALUPDATEClick(Sender: TObject);
var XX : Integer;
begin
  if GameEnv.AddonsEmpl ='' then
  begin
    MessageBox(application.Handle,'Veuillez définir un emplacement pour les addons',PChar(GridForm.caption),MB_ICONERROR or MB_OK);
    exit;
  end;
  XX :=  MessageBox (application.Handle,'Confirmez-vous la mise à jour des addons ?',PChar(GridForm.caption),MB_ICONQUESTION or MB_OKCANCEL);

  if XX = 1 then
  begin
  	LanceMajAddons('SERVALA');
  end;
end;

procedure TDetailAddons.SetForm;
begin
  redraw;
end;

procedure TDetailAddons.BackToMainForm(Sender: TObject);
begin
  Hide;
  GridForm.BringToFront;
end;


end.
