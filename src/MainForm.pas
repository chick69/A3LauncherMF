unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.ImgList, System.Actions,
  Vcl.ActnList, Vcl.Touch.GestureMgr,Shellapi,UUtils;

type
  TGridForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    GroupPanel1: TPanel;
    Label2: TLabel;
    FlowPanel1: TFlowPanel;
    GPSERVALADDONS: TPanel;
    GPARES: TPanel;
    ImgServal: TImage;
    ImgAres: TImage;
    Panel6: TPanel;
    Label5: TLabel;
    GPSERVALNOADDONS: TPanel;
    ImgServalNoAdd: TImage;
    Panel4: TPanel;
    Label6: TLabel;
    GroupPanel2: TPanel;
    FlowPanel2: TFlowPanel;
    Label7: TLabel;
    GroupPanel2_1: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    ImgParam: TImage;
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
    ServalStateRed: TImage;
    ServalStateGreen: TImage;
    AresStateRed: TImage;
    AresStateGreen: TImage;
    procedure ScrollBox2Resize(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure ImgParamClick(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure ImgServalNoAddClick(Sender: TObject);
    procedure ImgServalClick(Sender: TObject);
    procedure ImgAresClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure AppBarResize;
    procedure AppBarShow(mode: integer);
    procedure LanceServer(Server: Tserver; ThePassword : string);
    procedure GetPassword(var ThePasswd: string);

  public
    { Déclarations publiques }
    SelectedGroup: String;  // chaîne de groupe depuis
    procedure PickImageColor(img: TImage; AColor: TColor);
  end;


var
  GridForm: TGridForm;

implementation

{$R *.dfm}

uses Secondary, UGestAddons, UgetPasswd;

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
  GameEnv.SetInfosToForm;

end;

procedure TGridForm.LanceServer (Server : Tserver; ThePassword : string);
var ParamsB,ParamsT : string;
    ExeName : string;
    Addons : string;
begin
  ParamsB := gameEnv.SetParams (Server,ThePassword);
  ExeName := GameEnv.GetArma3Exe;
  Addons  := gameEnv.SetAddons (Server);
  if Addons <> '' then ParamsT := ParamsB + ' '+Addons
                  else ParamsT := ParamsB;
  application.Minimize;
//   MessageBox(Application.handle,Pchar(ParamsT),Pchar(GridForm.Caption),MB_OK);
  ShellExecute (Application.Handle,'OPEN',Pchar(ExeName),PChar(ParamsT),Pchar(GameEnv.GameEmpl),SW_SHOWDEFAULT);

end;

procedure TGridForm.Image11Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TGridForm.Image5Click(Sender: TObject);
begin
  if not Assigned(DetailAddons) then
    DetailAddons := TDetailAddons.Create(Self);
  DetailAddons.Show;
  DetailAddons.BringToFront;
end;

procedure TGridForm.Image6Click(Sender: TObject);
begin
  ShellExecute (Application.Handle,'OPEN','ts3server://mercenaires-francais.fr',nil,nil,SW_SHOWDEFAULT);
end;

procedure TGridForm.Image7Click(Sender: TObject);
begin
  ShellExecute (Application.Handle,'OPEN','http://mercenaires-francais.fr',nil,nil,SW_SHOWDEFAULT);
end;

procedure TGridForm.ImgAresClick(Sender: TObject);
var II : integer;
		ThePasswd : string;
begin
  for II := 0 to GameEnv.Servers.Count -1 do
  begin
    if not TServer(GameEnv.Servers[II]).AddonsStatus  then
    begin
      MessageBox(application.handle,'Vous ne pouvez rejoindre ce serveur tant que vos mods ne sont pas à jour',Pchar(GridForm.Caption),MB_ICONSTOP or MB_OK);
      exit;
    end;
    if TServer(GameEnv.Servers[II]).WithPassword then
    begin
      GetPassword (ThePasswd);     
      if ThePasswd = '' then exit;
    end;
    if TServer(GameEnv.Servers[II]).Name = 'ARES' then
    begin
      LanceServer (GameEnv.Servers[II],ThePasswd);
      break;
    end;
  end;
end;

procedure TGridForm.ImgParamClick(Sender: TObject);
begin
  if not Assigned(DetailForm) then
    DetailForm := TDetailForm.Create(Self);
  DetailForm.Show;
  DetailForm.BringToFront;
end;

procedure  TGridForm.GetPassword (var ThePasswd : string);     
var XX: TfGetPassword;
begin
  XX := TfGetPassword.Create(application);
  TRY
    XX.ShowModal;  
  FINALLY
    if XX.PasswordSais <> '' then ThePasswd := XX.PasswordSais;
    XX.Free;
  END;
end;


procedure TGridForm.ImgServalClick(Sender: TObject);

var II : integer;
		ThePasswd : string;
begin
  for II := 0 to GameEnv.Servers.Count -1 do
  begin
    if TServer(GameEnv.Servers[II]).Name = 'SERVALA' then
    begin
      if not TServer(GameEnv.Servers[II]).AddonsStatus  then
      begin
        MessageBox(application.handle,'Vous ne pouvez rejoindre ce serveur tant que vos mods ne sont pas à jour',Pchar(GridForm.Caption),MB_ICONSTOP or MB_OK);
        exit;
      end;
    	if TServer(GameEnv.Servers[II]).WithPassword then
      begin
 				GetPassword (ThePasswd);     
        if ThePasswd = '' then exit;
      end;

      LanceServer (GameEnv.Servers[II],ThePasswd);
      break;
    end;
  end;
end;

procedure TGridForm.ImgServalNoAddClick(Sender: TObject);
var II : integer;
		ThePasswd : string;
begin
  for II := 0 to GameEnv.Servers.Count -1 do
  begin
    if TServer(GameEnv.Servers[II]).Name = 'SERVAL' then
    begin
      if not TServer(GameEnv.Servers[II]).AddonsStatus  then
      begin
        MessageBox(application.handle,'Vous ne pouvez rejoindre ce serveur tant que vos mods ne sont pas à jour',Pchar(GridForm.Caption),MB_ICONSTOP or MB_OK);
        exit;
      end;
    	if TServer(GameEnv.Servers[II]).WithPassword then
      begin
 				GetPassword (ThePasswd);     
      end;
      LanceServer (GameEnv.Servers[II],ThePasswd);
      break;
    end;
  end;
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
