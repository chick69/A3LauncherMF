unit UUtils;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons, Registry
  ,Vcl.FileCtrl,System.IniFiles,XMLDOC, XMLIntf,Secondary,WinHttp_tlb,IdHttp,UaddonUtils,VCL.grids,VCL.comCtrls,IdComponent
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
    fDesc : string;
    fversion : string;
    fOK : boolean;
  private
    property XFile : string read ffile;
    property XName : string read fName;
    property XDesc : string read fDesc;
    property XOk : boolean read fOk;
    constructor create;
  end;

  TaddonsList = class(TList)
  private
    function Add(AObject: TAddons): Integer;
    function GetItems(Indice: integer): TAddons;
    procedure SetItems(Indice: integer; const Value: TAddons);
  public
    property Items [Indice : integer] : TAddons read GetItems write SetItems;
    function find (Name : string) : TAddons;
    procedure clear; override;
    destructor destroy; override;
  end;

  TServer = class (Tobject)
  private
    fName : string;
    fAdress : string;
    fPort : string;
    fStatus : boolean;
    fAddonStatus : boolean;
    fWithAddons : boolean;
    fWithPassWord : boolean;
    fAddonList : TaddonsList;
    fGameServer : TGameServer;
  public
		property Name : string read fName write fName;
    property Status : boolean read fStatus write fStatus;
    property WithAddons : boolean read fWithAddons write fWithAddons;
    property WithPassword : boolean read fWithPassWord;
    property LocalAddons : TaddonsList read fAddonList;
    property AddonsStatus : boolean read fAddonStatus;
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
    procedure SetInfoServers;
    procedure GetInfosFromForm;
    procedure SaveToFile;
    function GetDefaultProfile : string;
    function GetGameRepert : string;
    procedure RecupInfosServeurs;

  public
    property Servers : TserverList read fServers;
    property AddonsEmpl : string read fAddonsEmpl;
    property GameEmpl : string read fGameEmpl;
  	constructor create;
    destructor destroy; override;
    procedure SaveParams;
    procedure SetInfosToForm;
    procedure InitAddonState;
    procedure SetAddonsState;
    procedure SetAddonsServerStatus;
    function GetArma3Exe : string;
    function SetParams (Server : Tserver; ThePassword : string) : string;
    function SetAddons (Server : Tserver) : string;
  end;

  TDownLoad = class(Tobject)
  private
  	IdHTTP1: TIdHTTP;
  	AddonName : Tlabel;
    ProgressBar : TProgressBar;
    
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;AWorkCount: Int64);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;AWorkCountMax: Int64);
  public
		function GetAddonsFromServeur( TheFile : string; TheAddonName : Tlabel; TheProgressBar : TprogressBar) : boolean;    
  end;

function GetSpecialFolder(folder:string) :string;
function SelectionneRepert (RepertDepart : string) : string;
function LocalGetTempPath: string;

var GameEnv : TGameEnv;

implementation
uses MainForm,UGestAddons;

function LocalGetTempPath: string;
var
  tempFolder: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  result := StrPas(tempFolder);
end;

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

procedure TDownLoad.IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  ProgressBar.Max := AWorkCountMax;
  ProgressBar.Position := 0;
end;

procedure TDownLoad.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  ProgressBar.Position := AWorkCount;
end;

function TDownLoad.GetAddonsFromServeur( TheFile : string; TheAddonName : Tlabel; TheProgressBar : TprogressBar) : boolean;    
var
  Stream: TMemoryStream;
  Url, FileName: String;
begin
	result := false;
  Url := 'http://mercenaires-francais.fr/Addons/repo/'+TheFile;
  Filename :=  IncludeTrailingBackslash(LocalGetTempPath)+TheFile;

  IdHTTP1 := TIdHTTP.Create(Application);
  if (TheAddonName <> nil) and (TheProgressBar <> nil) then
  begin
  	AddonName := TheAddonName;
    ProgressBar := TheProgressBar;
    //
    AddOnName.Caption := TheFile; AddonName.Visible := true;
    ProgressBar.Visible := true;
    AddonName.Parent.Refresh;
    idHttp1.OnWorkBegin := IdHttpWorkBegin;
    idHttp1.OnWork := IdHTTPWork;
  end;
  
  Stream := TMemoryStream.Create;
  try
    TRY
      IdHTTP1.Get(Url, Stream);
      Stream.SaveToFile(FileName);
      result := true;
    EXCEPT
      MessageBox (Application.Handle,'Récupération de l''addon impossible','Connection Serveur MF',MB_ICONEXCLAMATION or MB_OK);
    END;
  finally
    Stream.Free;
    IdHTTP1.Free;
    if (TheAddonName <> nil) and (TheProgressBar <> nil) then
    begin
      TheAddonName.Visible := false;
      TheProgressBar.Visible := false;
    end;
  end;
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

function TGameEnv.GetArma3Exe: string;
begin
  result := '';
  if fGameEmpl = ''  then exit;
  if fBEActive  then
  begin
    result := IncludeTrailingBackslash(fGameEmpl)+'arma3battleye.exe'
  end else
  begin
    if fTypeOS = tto64 then
    begin
      result := IncludeTrailingBackslash(fGameEmpl)+'Arma3_X64.exe'
    end else
    begin
      result := IncludeTrailingBackslash(fGameEmpl)+'Arma3.exe'
    end;
  end;
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

constructor TGameEnv.create;
begin
	fServers := TServerList.Create;
	SetTypeOS;
  DefiniEnv;
	GetStoredParams;
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

function TGameEnv.SetAddons(Server: Tserver): string;
var II : integer;
begin
  result := '';
  for II := 0 to Server.fAddonList.Count -1 do
  begin
    if result <> '' then result := result + ';' else result := '"-mod=';
    result := result + IncludeTrailingBackslash (GameEnv.fAddonsEmpl)+Server.fAddonList.Items[II].fname;
  end;
  result := result + '"';
end;

procedure TGameEnv.SetAddonsServerStatus;

  procedure PositionneAddonsStatus (TheServer : TServer);
  var II : integer;
  begin
    TheServer.fAddonStatus := true;
    for II := 0 to TheServer.fAddonList.Count -1 do
    begin
      if TheServer.fAddonList.Items[II].fOK = false then
      begin
        TheServer.fAddonStatus := false;
        exit;
      end;
    end;
  end;

var II : integer;
begin
  for II := 0  to fServers.Count -1 do
  begin
    PositionneAddonsStatus (fServers.Items [II]);
  end;
end;

procedure TGameEnv.SetAddonsState;

  procedure UpdateAddonState (AddonName : string);
  var fLocalName : string;
      LocalVersion : string;
      II : integer;
      TheAddon : Taddons;
  begin
     LocalVersion :=GetAddonVersion (IncludeTrailingBackslash (fAddonsEmpl),AddOnName);
     for II := 0  to fServers.Count -1 do
     begin
        if fServers.Items[II].fWithAddons  then
        begin
          TheAddon := fServers.items[II].fAddonList.find(Addonname);
          if TheAddon= nil then Continue;
          if TheAddon.fversion = LocalVersion  then TheAddon.fOK := true;
        end;
     end;
  end;

var Info : TSearchRec;
begin
  if fAddonsEmpl='' then exit;
  If FindFirst(IncludeTrailingBackslash (fAddonsEmpl)+'*.*',faAnyFile,Info)=0 Then
  begin
    repeat
      If (info.Name<>'.')And(info.Name<>'..') then
      begin
        If not ((Info.Attr And faDirectory)=0) then
        begin
          UpdateAddonState (Info.Name);
        end;
      end;
    until FindNext (Info)<>0;
  end;
  FindClose(Info);
end;

procedure TGameEnv.SetInfoServers;
var XMlDOC : IXMlDocument;
		II,JJ,KK,SS : integer;
    SV,N1,N2,N3 : IXMLNode;
    OServer : TServer;
    UnAddon : TAddons;
begin
	XMlDOC := TXMLDocument.Create(nil);
  XMlDOC.LoadFromFile(IncludeTrailingBackslash (LocalGetTempPath)+'SERVEURS.xml');
  if not XMlDOC.IsEmptyDoc  then
  begin
    for SS := 0 to XMlDOC.documentElement.ChildNodes.Count -1 do
    begin
      SV := XMlDOC.documentElement.ChildNodes.Get(SS);   // un serveur
      for II := 0 to SV.ChildNodes.Count -1 do
      begin
        if II = 0  then
        begin
          OSerVer := TServer.Create;
          Oserver.fWithAddons := false;
          Oserver.fWithPassWord := false;
          fServers.Add(Oserver);
        end;
        N1 := SV.ChildNodes.Get(II);
        if N1.NodeName = 'Name' then
        begin
          OSerVer.fName := N1.NodeValue;
        end else if N1.NodeName = 'Adress' then
        begin
          OSerVer.fAdress := N1.NodeValue;
        end else if N1.NodeName = 'Password' then
        begin
          OSerVer.fWithPassWord := (N1.NodeValue=1);
        end else if N1.NodeName = 'Port' then
        begin
          OSerVer.fPort := N1.NodeValue;
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
              end else if N3.NodeName ='AddonDesc' then
              begin
                UnAddon.fDesc := N3.NodeValue;
              end;
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
  RecupInfosServeurs;
  // chargement de la configuration courante
  if FileExists (IncludeTrailingBackslash (LocalGetTempPath)+'SERVEURS.xml') then
  begin
  	SetInfoServers; // sans Addons
  end;
  SetAddonsState;
  SetAddonsServerStatus;
end;

procedure TGameEnv.InitAddonState;
var II,JJ : integer;
begin
  for II  := 0 to fServers.Count -1 do
  begin
    fservers.Items[II].fAddonStatus := false;
    for JJ := 0 to fServers.Items[II].fAddonList.Count -1 do
    begin
      fservers.Items[II].fAddonList.Items[JJ].fOK := false;
    end;
  end;
end;

procedure TGameEnv.RecupInfosServeurs;
var
  IdHTTP1: TIdHTTP;
  Stream: TMemoryStream;
  Url, FileName: String;
begin
  Url := 'http://mercenaires-francais.fr/Addons/env/SERVEURS.xml';
  Filename :=  IncludeTrailingBackslash(LocalGetTempPath)+'SERVEURS.xml';

  IdHTTP1 := TIdHTTP.Create(Application);
  Stream := TMemoryStream.Create;
  try
    TRY
      IdHTTP1.Get(Url, Stream);
      Stream.SaveToFile(FileName);
    EXCEPT
      MessageBox (Application.Handle,'Récupération des configurations impossible','Connection Serveur MF',MB_ICONEXCLAMATION or MB_OK);
    END;
  finally
    Stream.Free;
    IdHTTP1.Free;
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
var II : integer;
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
  // -- Form principale
  for II := 0 to fservers.Count -1 do
  begin
    if fservers.Items[II].fName = 'SERVALA' then
    begin
      GridForm.ServalStateRed.Visible := not fservers.Items[II].fAddonStatus;
      GridForm.ServalStateGreen.Visible := fservers.Items[II].fAddonStatus;
    end;
    if fservers.Items[II].fName = 'ARES' then
    begin
      GridForm.AresStateRed.Visible := not fservers.Items[II].fAddonStatus;
      GridForm.AresStateGreen.Visible := fservers.Items[II].fAddonStatus;
    end;
  end;
  DetailAddons.SetForm;
  // -- Addons form
end;

function TGameEnv.SetParams(Server: Tserver; ThePassword : string): string;
begin
  result := '';
  if server.fAdress <> '' then
  begin
    result := '-connect='+Server.fAdress;
  end;
  if ThePassword <> '' then
  begin
    if result <> '' then result := result + ' ';
    result := '-password='+ThePassword;
  end;
  if server.fPort <> '' then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-port='+Server.fport;
  end;
  if GameEnv.fDefautProfil  <> '' then
  begin
    if result <> '' then result := result + ' ';
    result := result + '"-name='+GameEnv.fDefautProfil+'"';
  end;
  if GameEnv.fShowErrors  then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-showScriptErrors';
  end;
  if GameEnv.fNoPause  then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-noPause';
  end;
  if GameEnv.fWindowed  then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-window';
  end;
  if GameEnv.fFilePatching then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-filePatching';
  end;
  if GameEnv.fControleSig then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-checkSignatures';
  end;
  if GameEnv.fRSAuto then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-checkSignatures';
  end;
  if GameEnv.fMaxMemory <> 0 then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-maxMem='+InttOStr(GameEnv.fMaxMemory);
  end;
  if GameEnv.fNbCpu <> 0 then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-cpuCount='+InttOStr(GameEnv.fNbCpu);
  end;
  if GameEnv.fExThreads <> 0 then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-exThreads='+InttOStr(GameEnv.fExThreads);
  end;
  if GameEnv.fModeAlloc <> '' then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-malloc='+GameEnv.fModeAlloc;
  end;
  if GameEnv.fEnableHT  then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-enableHT';
  end;
  if GameEnv.fNoSplash  then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-nosplash';
  end;
  if GameEnv.fWorldEmpty then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-world=empty';
  end;
  if GameEnv.fNoLogs  then
  begin
    if result <> '' then result := result + ' ';
    result := result + '-nologs';
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

function TaddonsList.find(Name: string): TAddons;
var II : integer;
begin
  result := nil;
  for II := 0 to Count -1 do
  begin
    if Items[II].fname = Name then
    begin
      result := Items[II];
      break;
    end;
  end;
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
end;

destructor TServer.destroy;
begin
  fAddonList.Free;
  inherited;
end;

{ TAddons }

constructor TAddons.create;
begin
  fOk := false;
end;

initialization
	GameEnv := TGameEnv.create;

FINALIZATION
 	GameEnv.Free;


end.
