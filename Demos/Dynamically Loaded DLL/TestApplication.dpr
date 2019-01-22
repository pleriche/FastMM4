program TestApplication;

uses
  FastMM4,
  Forms,
  ApplicationForm in 'ApplicationForm.pas' {fAppMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfAppMain, fAppMain);
  Application.Run;
end.
