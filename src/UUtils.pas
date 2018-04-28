unit UUtils;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons, Registry
  ,Vcl.FileCtrl,System.IniFiles,XMLDOC, XMLIntf,Secondary
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
    ffile : string;
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
    fAdress : string;
    fPort : string;
    fStatus : boolean;
    fWithAddons : boolean;
    fAddonList : TaddonsList;
    fAddonServer : TaddonsList;
    fGameServer : TGameServer;
  public
		property Name : string read fName write fName;
    property Status : boolean read fStatus write fStatus;
    property WithAddons : boolean read fWithAddons write fWithAddons;
    property ServerAddons : TaddonsList read fAddonServer;
    property LocalAddons : TaddonsList read fAddonList;
    constructor create;
    destructor destroy; override;
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
    //
    fServers : TserverList;
    //
    fLocalAppData : string;
    ININame : string;

    //
    procedure DefiniEnv;
    procedure SetTypeOS;
    procedure GetStoredParams;
    procedure StockeInfoServeur(NomServeur: string);
    procedure GetInfosFromForm;
    procedure SaveToFile;
    function GetDefaultProfile : string;
    function GetGameRepert : string;

  public
  	constructor create;
    destructor destroy; override;
    procedure ConnectToServer (TheServer : string) ;
    procedure SaveParams;
    procedure SetInfosToForm;
  end;

function GetSpecialFolder(folder:string) :string;
function SelectionneRepert (RepertDepart : string) : string;

implementation

function GetSpecialFolder(folder:string) :string;
var Reg : TRegistry;
    res : string;
begin
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', False)
    then res := Reg.ReadString(folder)
    else res := '';
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
  result := res;
end;

function TGameEnv.GetGameRepert : string;
var Reg : TRegistry;
    res : string;
begin
  try
    Reg := TRegistry.Create(KEY_READ);
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Wow6432Node\bohemia interactive\arma 3', False)
    then res := Reg.ReadString('main')
    else res := '';
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
  result := res;
end;

function TGameEnv.GetDefaultProfile : string;
var Reg : TRegistry;
    res : string;
begin
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Bohemia Interactive\Arma 3', False)
    then res := Reg.ReadString('Player Name')
    else res := '';
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
  result := res;
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
  DefiniEnv;
	GetStoredParams;
  SetInfosToForm;
end;

procedure TGameEnv.DefiniEnv;
begin
	fLocalAppData := IncludeTrailingBackslash(IncludeTrailingBackslash(GetSpecialFolder('Local AppData'))+'A3Launcher');
  if not DirectoryExists(fLocalAppData) then
  begin
    CreateDir(fLocalAppData);
  end;
  ININame := IncludeTrailingBackslash (fLocalAppData)+ ChangeFileExt( ExtractFileName(Application.ExeName), '.INI' );
end;

destructor TGameEnv.destroy;
begin
  fServers.Free;
  inherited;
end;

procedure TGameEnv.StockeInfoServeur (NomServeur : string);
var XMlDOC : IXMlDocument;
		II,JJ,KK : integer;
    SV,N1,N2,N3 : IXMLNode;
    OServer : TServer;
    UnAddon : TAddons;
begin
	XMlDOC := TXMLDocument.Create(nil);
  XMlDOC.LoadFromFile(IncludeTrailingBackslash (fLocalAppData)+NomServeur+'.xml');
  if not XMlDOC.IsEmptyDoc  then
  begin
  	SV := XMlDOC.documentElement.ChildNodes.Get(0);   // un serveur
    for II := 0 to SV.ChildNodes.Count -1 do
    begin  
    	if II = 0  then
      begin
      	OSerVer := TServer.Create;
        Oserver.fWithAddons := false;
        fServers.Add(Oserver);
      end;
    	N1 := SV.ChildNodes.Get(II);
      if N1.NodeName = 'Name' then
      begin
				OSerVer.fName := N1.NodeValue;
      end else if N1.NodeName = 'State' then
      begin
				if N1.NodeValue = '1' then OServer.fStatus := true else OServer.fStatus := false;
      end else if N1.NodeName = 'Addons' then
      begin
      	Oserver.WithAddons := true;
        for JJ := 0 to N1.ChildNodes.Count -1 do
        begin  
          UnAddon := TAddons.Create;
          Oserver.fAddonList.Add(UnAddon);          
        	N2 := N1.ChildNodes.Get(JJ);
          for KK  := 0 to N2.ChildNodes.Count -1 do
          begin
            N3 := N2.ChildNodes.Get(KK) ;
            if N3.NodeName ='AddonName' then
            begin
              UnAddon.fname := N3.NodeValue;
            end else if N3.NodeName ='AddonFile' then
            begin
              UnAddon.ffile := N3.NodeValue;
            end else if N3.NodeName ='AddonVersion' then
            begin
              UnAddon.fversion := N3.NodeValue;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TGameEnv.GetInfosFromForm;
begin
  if (DetailForm.CBProfileName.Text <> '<<Défaut>>') then  fDefautProfil := DetailForm.CBProfileName.Text
                                                     else  fDefautProfil := '';
  fGameEmpl := DetailForm.EmplArma.Text;
  fAddonsEmpl := DetailForm.EMPLADDONS.Text;
  fShowErrors := detailForm.CBERRORS.Checked;
  fNoPause :=  DetailForm.CBNOPAUSE.Checked;
  fWindowed :=  DetailForm.CBWINDOWED.Checked;
  fFilePatching := DetailForm.CBFILEPACHING.Checked;
  fControleSig :=  DetailForm.CBCHECKSIGN.Checked;
  fBEActive :=  DetailForm.CBENABLEBATTLEYE.Checked;
  fRSAuto := DetailForm.CBRESTART.Checked;
  // ---
  if (DetailForm.CBMEMALLOUE.Text <> '<<Défaut>>') then fMaxMemory := StrToInt(DetailForm.CBMEMALLOUE.Text)
                                                   else fMaxMemory := 0;
  if DetailForm.SELNBCORES.Text <> '<<Défaut>>' then fNbCpu := StrToInt(DetailForm.SELNBCORES.Text)
                                                else fNbCpu := 0;
  if DetailForm.CBNbEXthreads.Text <> '<<Défaut>>'  then fExThreads := StrToInt(DetailForm.CBNbEXthreads.Text)
                                                    else fExThreads := 0;
  if (DetailForm.CBMALLOC.Text <> '<<Défaut>>') then fModeAlloc := DetailForm.CBMALLOC.Text
                                                else fModeAlloc := '';

  fEnableHT := DetailForm.CBEnabledHT.Checked;
  fNoSplash := DetailForm.CBNoSplash.Checked;
  fWorldEmpty := DetailForm.CBWorldEmpty.Checked;
  fNoLogs :=  DetailForm.CBNologs.Checked;
end;

procedure TGameEnv.GetStoredParams;
var LaunchIni : TIniFile;
    lfGameEmpl,lfDefautProfil : string;
begin
	if FileExists( ININame) then
  begin
    LaunchIni := TIniFile.Create(ININame);
    TRY
      lfDefautProfil := LaunchIni.ReadString('Launcher','ProfileName',GetDefaultProfile);
      if lfDefautProfil <> '' then fDefautProfil := lfDefautProfil else fDefautProfil := GetDefaultProfile;
      lfGameEmpl :=  LaunchIni.ReadString('Launcher','GameEmpl',GetGameRepert);
      if lfGameEmpl <> '' then fGameEmpl := lfGameEmpl else fGameEmpl := GetGameRepert;
      //
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
  // chargement de la configuration courante
  if FileExists (IncludeTrailingBackslash (fLocalAppData)+'MFSERVAL.xml') then
  begin
  	StockeInfoServeur ('MFSERVAL'); // sans Addons
  end;
  if FileExists (IncludeTrailingBackslash (fLocalAppData)+'MFSERVALA.xml') then
  begin
  	StockeInfoServeur ('MFSERVALA');  // Serval avec Addons
  end;
  if FileExists (IncludeTrailingBackslash (fLocalAppData)+'MFARES.xml') then
  begin
  	StockeInfoServeur ('MFARES'); // ARES
  end;
  
end;

procedure TGameEnv.SaveParams;
begin
  GetInfosFromForm;
  SaveToFile;
end;

procedure TGameEnv.SaveToFile;
var LaunchIni : TIniFile;
    filehandle : integer;
begin
  if not FileExists(ININame ) then
  begin
    filehandle:=  FileOpen(ININame, fmOpenWrite);
    FileClose(filehandle);
  end;
  LaunchIni := TIniFile.Create(ININame);
  TRY
    LaunchIni.WriteString('Launcher','ProfileName',fDefautProfil);
    LaunchIni.WriteString('Launcher','GameEmpl',fGameEmpl);
    LaunchIni.WriteString('Launcher','AddonsEmpl',fAddonsEmpl);
    LaunchIni.WriteBool('Launcher','ShowErrors',fShowErrors);
    LaunchIni.WriteBool('Launcher','NoPause',fNoPause);
    LaunchIni.WriteBool('Launcher','Windowed',fWindowed);
    LaunchIni.WriteBool('Launcher','FilePatching',fFilePatching);
    LaunchIni.WriteBool('Launcher','SignControl',fControleSig);
    LaunchIni.WriteBool('Launcher','ActiveBE',fBEActive);
    LaunchIni.WriteBool('Launcher','RSAuto',fRSAuto);
    // ---
    LaunchIni.WriteInteger('Optimize','MaxMem',fMaxMemory);
    LaunchIni.WriteInteger('Optimize','MaxCpu',fNbCpu);
    LaunchIni.WriteInteger('Optimize','ExThreads',fExThreads);
    LaunchIni.WriteString('Optimize','Malloc',fModeAlloc);
    LaunchIni.WriteBool('Optimize','EnableHT',fEnableHT);
    LaunchIni.WriteBool('Optimize','NoSplash',fNoSplash);
    LaunchIni.WriteBool('Optimize','WorldEmpty',fWorldEmpty);
    LaunchIni.WriteBool('Optimize','NoLogs',fNoLogs);
  FINALLY
    LaunchIni.Free;
  END;
end;

procedure TGameEnv.SetInfosToForm;
var I : integer;
begin
  //
  if fDefautProfil <> '' then
  begin
    DetailForm.CBProfileName.ItemIndex :=  DetailForm.CBProfileName.Items.IndexOf(fDefautProfil);
  end;
  if fGameEmpl <> '' then DetailForm.EmplArma.Text :=fGameEmpl;
  if fAddonsEmpl <> '' then DetailForm.EMPLADDONS.Text := fAddonsEmpl;
  DetailForm.CBERRORS.Checked := fShowErrors;
  DetailForm.CBNOPAUSE.Checked := fNoPause;
  DetailForm.CBWINDOWED.Checked := fWindowed;
  DetailForm.CBFILEPACHING.Checked := fFilePatching;
  DetailForm.CBCHECKSIGN.Checked := fControleSig;
  DetailForm.CBENABLEBATTLEYE.Checked := fBEActive;
  if fMaxMemory <> 0 then
  begin
    DetailForm.CBMEMALLOUE.ItemIndex := DetailForm.CBMEMALLOUE.Items.IndexOf(IntToStr(fMaxMemory));
  end;
  if fNbCpu <> 0 then
  begin
    DetailForm.SELNBCORES.ItemIndex := DetailForm.SELNBCORES.Items.IndexOf(IntToStr(fNbCpu));
  end;
  if fExThreads <> 0 then
  begin
    DetailForm.CBNbEXthreads.ItemIndex := DetailForm.CBNbEXthreads.Items.IndexOf(IntToStr(fExThreads));
  end;
  if fModeAlloc <> '' then
  begin
    DetailForm.CBMALLOC.ItemIndex := DetailForm.CBMALLOC.Items.IndexOf(fModeAlloc);
  end;
  DetailForm.CBEnabledHT.Checked := fEnableHT;
  DetailForm.CBNoSplash.Checked := fNoSplash;
  DetailForm.CBWorldEmpty.Checked := fWorldEmpty;
  DetailForm.CBNologs.Checked :=fNoLogs;
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

{ TServer }

constructor TServer.create;
begin
	fAddonList := TaddonsList.Create;
  fAddonServer := TaddonsList.Create;
end;

destructor TServer.destroy;
begin
  fAddonList.Free;
  fAddonServer.Free;
  inherited;
end;

end.
