unit UUtils;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, System.Actions, Vcl.ActnList,
  Vcl.Styles, Vcl.Themes, Vcl.Touch.GestureMgr, Vcl.Buttons
  ,Vcl.FileCtrl
  ;

function SelectionneRepert (RepertDepart : string) : string;

implementation

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

end.
