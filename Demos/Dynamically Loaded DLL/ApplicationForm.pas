unit ApplicationForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfAppMain = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAppMain: TfAppMain;

implementation

{$R *.dfm}

procedure TfAppMain.Button1Click(Sender: TObject);
var
  LDLLHandle: HModule;
  LShowProc: TProcedure;
begin
  LDLLHandle := LoadLibrary('TestDLL.dll');
  if LDLLHandle <> 0 then
  begin
    try
      LShowProc := GetProcAddress(LDLLHandle, 'ShowDLLForm');
      if Assigned(LShowProc) then
      begin
        LShowProc;
      end
      else
        ShowMessage('The ShowDLLForm procedure could not be found in the DLL.');
    finally
      FreeLibrary(LDLLHandle);
    end;
  end
  else
    ShowMessage('The DLL was not found. Please compile the DLL before running this application.');
end;

end.
