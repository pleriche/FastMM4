unit DemoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FastMMDebugSupport, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  TObject.Create;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  x, y, z: TObject;
begin
  {Set the allocation group to 1}
  PushAllocationGroup(1);
  {Allocate an object}
  x := TPersistent.Create;
  {Set the allocation group to 2}
  PushAllocationGroup(2);
  {Allocate a TControl}
  y := TControl.Create(nil);
  {Go back to allocation group 1}
  PopAllocationGroup;
  {Allocate a TWinControl}
  z := TWinControl.Create(nil);
  {Pop the last group off the stack}
  PopAllocationGroup;
  {Specify the name of the log file}
  SetMMLogFileName('AllocationGroupTest.log');
  {Log all live blocks in groups 1 and 2}
  LogAllocatedBlocksToFile(1, 2);
  {Restore the default log file name}
  SetMMLogFileName(nil);
  {Free all the objects}
  x.Free;
  y.Free;
  z.Free;
  {Done}
  ShowMessage('Allocation detail logged to file.');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  with TObject.Create do
  begin
    Free;
    Free;
  end;
end;

end.
