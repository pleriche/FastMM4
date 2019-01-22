unit DemoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FastMMUsageTracker;

type
  TfDemo = class(TForm)
    bShowTracker: TButton;
    procedure bShowTrackerClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fDemo: TfDemo;

implementation

{$R *.dfm}

procedure TfDemo.bShowTrackerClick(Sender: TObject);
begin
  ShowFastMMUsageTracker;
end;

end.
