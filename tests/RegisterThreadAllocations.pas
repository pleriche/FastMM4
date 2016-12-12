unit RegisterThreadAllocations;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm5 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses
  FastMM4,
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

procedure TForm5.FormCreate(Sender: TObject);
begin
  //Will not be reported (1x TList, 2x Unknown, 1x UnicodeString)
  StartRegisteringAllThreadAllocationsAsExpectedLeaks;
  RegisterPropertyEditor(TypeInfo(TStrings), TMyDataset, 'Test', TMyEditor);
  StopRegisteringAllThreadAllocationsAsExpectedLeaks;

  //Will be reported (2x Unknown, 2x UnicodeString);
  RegisterPropertyEditor(TypeInfo(TStrings), TMyDataset, 'Test', TMyEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), TMyDataset, 'Test', TMyEditor);

  Application.Terminate;
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
