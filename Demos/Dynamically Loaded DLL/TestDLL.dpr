library TestDLL;

uses
  FastMM4,
  SysUtils,
  Classes,
  DLLForm in 'DLLForm.pas' {fDLLMain};

{$R *.res}

procedure ShowDLLForm;
begin
  with TfDLLMain.Create(nil) do
  begin
    try
      ShowModal;
    finally
      Free;
    end;
  end;
end;

exports ShowDllForm;

begin
end.
