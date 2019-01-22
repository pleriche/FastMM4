unit DLLForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfDLLMain = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fDLLMain: TfDLLMain;

implementation

{$R *.dfm}

procedure TfDLLMain.Button1Click(Sender: TObject);
begin
  TObject.Create;
end;

procedure TfDLLMain.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
