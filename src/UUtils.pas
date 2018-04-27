unit UUtils;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons
  ,Vcl.FileCtrl,System.IniFiles
  ;

const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
  PROCESSOR_ARCHITECTURE_INTEL = 0;
  PROCESSOR_ARCHITECTURE_UNKNOWN = $FFFF;  
  
type

	TTypeOs = (ttoUndef,tto32,tto64);
  TGameServer = (TGSServal,TgsARES);

  TAddons = class (Tobject)
    fname : string;
    fversion : string;
  end;

  TaddonsList = class(TList)
  private
  	fUid : string;
    function Add(AObject: TAddons): Integer;
    function GetItems(Indice: integer): TAddons;
    procedure SetItems(Indice: integer; const Value: TAddons);
  public
  	property Version : string read fUID write fUID;
    property Items [Indice : integer] : TAddons read GetItems write SetItems;
    procedure clear; override;
    destructor destroy; override;
  end;

  TServer = class (Tobject)
  private
    fName : string;
    fStatus : boolean;
    fWithAddons : boolean;
    fAddonList : TaddonsList;
    fGameServer : TGameServer;
  public
		property Name : string read fName write fName;
    property Status : boolean read fStatus write fStatus;
    property WithAddons : boolean read fWithAddons write fWithAddons;
  end;

  TServerList = class (Tlist)
  private
    function Add(AObject: TServer): Integer;
    function GetItems(Indice: integer): TServer;
    procedure SetItems(Indice: integer; const Value: TServer);
  public
    property Items [Indice : integer] : TServer read GetItems write SetItems;
    procedure clear; override;
    destructor destroy; override;
  end;

	TGameEnv = class (Tobject)
  private
  	fTypeOS :  TTypeOs;
    fGameEmpl : string;
    fAddonsEmpl : string;
    fDefautProfil : string;
    fShowErrors : boolean;
    fNoPause : boolean;
    fWindowed : boolean;
    fFilePatching : boolean;
    fControleSig : boolean;
    fBEActive : boolean;
    fRSAuto : boolean;
    fMaxMemory : integer;
    fNbCpu : integer;
    fExThreads : integer;
    fModeAlloc : string;
    fEnableHT : boolean;
    fNoSplash : boolean;
    fWorldEmpty : boolean;
    fNoLogs : boolean;
    fServers : TserverList;
    //
    procedure SetTypeOS; 
    procedure GetStoredParams;
    procedure StoreParams;
  public
  	constructor create;
    destructor destroy; override;
    procedure ConnectToServer (TheServer : string) ;
  end;
  
function SelectionneRepert (RepertDepart : string) : string;
function GetDefaultProfile : string;
function GetGameRepert : string;

implementation

function GetGameRepert : string;
begin

end;

function GetDefaultProfile : string;
begin

end;

function SelectionneRepert (RepertDepart : string) : string;
var TT : String;
		XX : TFileOpenDialog;
begin
	XX := TFileOpenDialog.Create(Application);
  With XX do
  begin
    try
    	TT := RepertDepart;
      Title := 'Sélectionner le répertoire';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
      OkButtonLabel := 'Sélection';
      DefaultFolder := TT;
      FileName := TT;
      if Execute then result := FileName;
    finally
      Free;
    end  
  end;
end;

{ TGameEnv }


procedure TGameEnv.ConnectToServer(TheServer: string);
begin

end;

constructor TGameEnv.create;
begin
	fServers := TServerList.Create;
	SetTypeOS; 
end;

destructor TGameEnv.destroy;
begin
  fServers.Free;
  inherited;
end;

procedure TGameEnv.GetStoredParams;
var LaunchIni : TIniFile;
begin
	if FileExists( ChangeFileExt( Application.ExeName, '.INI' )) then
  begin
    LaunchIni := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
    TRY
      fDefautProfil := LaunchIni.ReadString('Launcher','ProfileName',GetDefaultProfile);
      fGameEmpl :=  LaunchIni.ReadString('Launcher','GameEmpl',GetGameRepert);
      fAddonsEmpl := LaunchIni.ReadString('Launcher','AddonsEmpl','');
      fShowErrors := LaunchIni.ReadBool('Launcher','ShowErrors',false);
      fNoPause :=  LaunchIni.ReadBool('Launcher','NoPause',true);
      fWindowed :=  LaunchIni.ReadBool('Launcher','Windowed',false);
      fFilePatching := LaunchIni.ReadBool('Launcher','FilePatching',false);
      fControleSig :=  LaunchIni.ReadBool('Launcher','SignControl',false);
      fBEActive :=  LaunchIni.ReadBool('Launcher','ActiveBE',false);
      fRSAuto := LaunchIni.ReadBool('Launcher','RSAuto',false);
      // ---
      fMaxMemory := LaunchIni.ReadInteger('Optimize','MaxMem',0);
      fNbCpu := LaunchIni.ReadInteger('Optimize','MaxCpu',0);
      fExThreads := LaunchIni.ReadInteger('Optimize','ExThreads',0);
      fModeAlloc := LaunchIni.ReadString('Optimize','Malloc','');
      fEnableHT := LaunchIni.ReadBool('Optimize','EnableHT',false);
      fNoSplash := LaunchIni.ReadBool('Optimize','NoSplash',true);
      fWorldEmpty := LaunchIni.ReadBool('Optimize','WorldEmpty',true);
      fNoLogs := LaunchIni.ReadBool('Optimize','NoLogs',true);
    FINALLY
      LaunchIni.Free;
    END;
  end else
  begin
    fDefautProfil := GetDefaultProfile;
    fGameEmpl :=  GetGameRepert;
    fAddonsEmpl := '';
    fShowErrors := false;
    fNoPause :=  true;
    fWindowed :=  false;
    fFilePatching := false;
    fControleSig := false;
    fBEActive := false;
    fRSAuto := false;
    // ---
    fMaxMemory := 0;
    fNbCpu := 0;
    fExThreads := 0;
    fModeAlloc := '';
    fEnableHT := false;
    fNoSplash := true;
    fWorldEmpty := true;
    fNoLogs := true;
  end;
  
end;

procedure TGameEnv.SetTypeOS;
var si: TSystemInfo;
begin
	GetSystemInfo(si);
  case si.wProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_AMD64: fTypeOS := tto64; 
    PROCESSOR_ARCHITECTURE_IA64:  fTypeOS := tto64; 
    PROCESSOR_ARCHITECTURE_INTEL:  fTypeOS := tto32; 
    PROCESSOR_ARCHITECTURE_UNKNOWN: fTypeOS := ttoUndef; 
  end;		
end;

procedure TGameEnv.StoreParams;
begin

end;

{ TaddonsList }

function TaddonsList.Add(AObject: TAddons): Integer;
begin
  result := Inherited Add(AObject);
end;

procedure TaddonsList.clear;
var indice : integer;
begin
  if count > 0 then
  begin
    for Indice := 0 to count -1 do
    begin
      TAddons(Items [Indice]).free;
    end;
  end;
  inherited;
end;

destructor TaddonsList.destroy;
begin
  Clear;
  inherited;
end;

function TaddonsList.GetItems(Indice: integer): TAddons;
begin
  result := TAddons (Inherited Items[Indice]);
end;

procedure TaddonsList.SetItems(Indice: integer; const Value: TAddons);
begin
  Inherited Items[Indice]:= Value;
end;

{ TServerList }

function TServerList.Add(AObject: TServer): Integer;
begin
  result := Inherited Add(AObject);
end;

procedure TServerList.clear;
var indice : integer;
begin
  if count > 0 then
  begin
    for Indice := 0 to count -1 do
    begin
      TServer(Items [Indice]).free;
    end;
  end;
  inherited;
end;

destructor TServerList.destroy;
begin
  Clear;
  inherited;
end;

function TServerList.GetItems(Indice: integer): TServer;
begin
  result := TServer (Inherited Items[Indice]);
end;

procedure TServerList.SetItems(Indice: integer; const Value: TServer);
begin
  Inherited Items[Indice]:= Value;
end;

end.
