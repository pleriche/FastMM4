program RegisterThreadAllocationsProj;

uses
  FastMM4 in '..\FastMM4.pas',
  Vcl.Forms,
  RegisterThreadAllocations in 'RegisterThreadAllocations.pas' {Form5},
  DockForm in 'DockForm.pas',
  PersonalityConst in 'PersonalityConst.pas',
  Proxies in 'Proxies.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
