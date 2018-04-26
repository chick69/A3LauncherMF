program A3LauncherMF;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  MainForm in '..\src\MainForm.pas' {GridForm},
  Secondary in '..\src\Secondary.pas' {DetailForm},
  UGestAddons in '..\src\UGestAddons.pas' {DetailAddons},
  UUtils in '..\src\UUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.UseMetropolisUI;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Metropolis UI Blue');
  Application.Title := 'Metropolis UI Application';
  Application.CreateForm(TGridForm, GridForm);
  Application.CreateForm(TDetailForm, DetailForm);
  Application.CreateForm(TDetailAddons, DetailAddons);
  Application.Run;
end.
