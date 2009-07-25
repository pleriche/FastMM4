object fDLLMain: TfDLLMain
  Left = 0
  Top = 0
  Caption = 'FastMM Sharing DLL Form'
  ClientHeight = 185
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 152
    Width = 165
    Height = 25
    Caption = 'Click to leak some memory'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 317
    Height = 137
    Enabled = False
    Lines.Strings = (
      'This DLL is sharing the memory manager of the main '
      'application. '
      ''
      'The following settings were used to achieve this:'
      
        '1) FastMM4.pas is the first unit in the "uses" clause of the .dp' +
        'r'
      '2) The "ShareMM" option is enabled.'
      '3) The "AttemptToUseSharedMM" option is enabled.'
      ''
      'Click the button to leak some memory.')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 180
    Top = 152
    Width = 145
    Height = 25
    Caption = 'Unload DLL'
    TabOrder = 2
    OnClick = Button2Click
  end
end
