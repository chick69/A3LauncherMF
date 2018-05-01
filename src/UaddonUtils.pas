unit UaddonUtils;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons, Registry
  ,Vcl.FileCtrl,System.IniFiles,XMLDOC, XMLIntf,Secondary,WinHttp_tlb,IdHttp
  ;

function GetAddonName (DirStock,Directory : string) : string;
function GetAddonVersion (DirStock,Directory : string) : string;

implementation

function GetAddonName (DirStock,Directory : string) : string;
var F: TextFile;
    fileName : string;
    oneLine : string;
    value : string;
    Ipos : integer;
begin
  FileName := IncludeTrailingBackslash(DirStock)+IncludeTrailingBackslash(Directory)+'mod.cpp';
  AssignFile(F, FileName);
  Reset(F);
  while not eof(F) do
  begin
    ReadLn(F, oneLine);
    if pos('name',OneLine)>0 then
    begin
      Ipos := pos('=',OneLine);
      Value := copy(OneLine,Ipos+1,Length(OneLine)-Ipos-1);
      result := TrimLeft(TrimRight(value));
    end;
  end;
  CloseFile(F);
end;

function GetAddonVersion (DirStock,Directory : string) : string;
var fDir :string;
    Info : TSearchRec;
    fsig : string;
    iPos : integer;
begin
  fsig := '';
  fDir := IncludeTrailingBackslash(DirStock)+IncludeTrailingBackslash(directory)+'addons';
  If FindFirst(IncludeTrailingBackslash (fDir)+'*.bisign',faAnyFile,Info)=0 Then
  begin
    repeat
      If (info.Name<>'.')And(info.Name<>'..') then
      begin
        If ((Info.Attr And faDirectory)=0) then
        begin
          if pos('six_', info.name ) = 0 then
          begin
            iPos := pos('.pbo',info.name);
            if ipos > 0 then
            begin
              fSig := copy(info.Name,iPos+5,Length(Info.Name)-Ipos-1);
              fsig := StringReplace (fSig,'.bisign','',[rfreplaceAll]);
              break;
            end;
          end;
        end;
      end;
    until FindNext (Info)<>0;
    if fsig <> ''  then result := fSig;
  end;
  FindClose(Info);

end;

end.
