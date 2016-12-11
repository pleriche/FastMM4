unit RegisterThreadAllocations;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm5 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses
  TypInfo,
  DesignIntf,
  DesignEditors;

type
  TMyDataset = class
  end;

  TMyEditor = class(TBasePropertyEditor)
  protected
    procedure Initialize; override;
    procedure SetPropEntry(Index: Integer; AInstance: TPersistent;
      APropInfo: PPropInfo); override;
  end;

{$R *.dfm}

procedure TForm5.Button1Click(Sender: TObject);
begin
//  RegisterAllThreadAllocationsAsExpectedLeaks;
  RegisterPropertyEditor(TypeInfo(TStrings), TMyDataset, 'Test', TMyEditor);
//  StopRegisteringAllThreadAllocationsAsExpectedLeaks;
end;

{ TMyEditor }

procedure TMyEditor.Initialize;
begin
end;

procedure TMyEditor.SetPropEntry(Index: Integer; AInstance: TPersistent;
  APropInfo: PPropInfo);
begin
end;

end.
