object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'borlndmm.dll using FullDebugMode'
  ClientHeight = 146
  ClientWidth = 369
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 24
    Top = 24
    Width = 321
    Height = 25
    Caption = 'Click this button to leak a TObject'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 60
    Width = 321
    Height = 25
    Caption = 'Click this button to test the allocation grouping functionality'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 24
    Top = 96
    Width = 321
    Height = 25
    Caption = 'Cause a "virtual method on freed object" error'
    TabOrder = 2
    OnClick = Button3Click
  end
end
