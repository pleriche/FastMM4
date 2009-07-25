object fAppMain: TfAppMain
  Left = 0
  Top = 0
  Caption = 'FastMM Sharing Test Application'
  ClientHeight = 208
  ClientWidth = 300
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
    Left = 8
    Top = 172
    Width = 281
    Height = 25
    Caption = 'Load DLL and Display DLL Form'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 281
    Height = 157
    Enabled = False
    Lines.Strings = (
      'This application shows how to share FastMM between '
      'an application and dynamically loaded DLL, without '
      'using the borlndmm.dll library.'
      ''
      'Click the button to load the test DLL and display its '
      'form.'
      ''
      'The relevant settings for this application:'
      '1) FastMM4.pas is the first unit in the uses clause '
      '2) The "ShareMM" option is enabled'
      '3) "Use Runtime Packages" is disabled'
      '')
    TabOrder = 1
  end
end
