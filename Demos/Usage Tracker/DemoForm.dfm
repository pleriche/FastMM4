object fDemo: TfDemo
  Left = 199
  Top = 114
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Usage Tracker Demo'
  ClientHeight = 53
  ClientWidth = 239
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object bShowTracker: TButton
    Left = 8
    Top = 8
    Width = 221
    Height = 37
    Caption = 'Show Usage Tracker'
    TabOrder = 0
    OnClick = bShowTrackerClick
  end
end
