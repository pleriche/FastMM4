object fFastMMUsageTracker: TfFastMMUsageTracker
  Left = 460
  Top = 178
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FastMM Memory Usage Tracker'
  ClientHeight = 556
  ClientWidth = 553
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bClose: TBitBtn
    Left = 472
    Top = 524
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 0
    OnClick = bCloseClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333FFFFF3333333333999993333333333F77777FFF333333999999999
      3333333777333777FF3333993333339993333377FF3333377FF3399993333339
      993337777FF3333377F3393999333333993337F777FF333337FF993399933333
      399377F3777FF333377F993339993333399377F33777FF33377F993333999333
      399377F333777FF3377F993333399933399377F3333777FF377F993333339993
      399377FF3333777FF7733993333339993933373FF3333777F7F3399933333399
      99333773FF3333777733339993333339933333773FFFFFF77333333999999999
      3333333777333777333333333999993333333333377777333333}
    NumGlyphs = 2
  end
  object bUpdate: TBitBtn
    Left = 392
    Top = 524
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 1
    OnClick = bUpdateClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00370777033333
      3330337F3F7F33333F3787070003333707303F737773333373F7007703333330
      700077337F3333373777887007333337007733F773F333337733700070333333
      077037773733333F7F37703707333300080737F373333377737F003333333307
      78087733FFF3337FFF7F33300033330008073F3777F33F777F73073070370733
      078073F7F7FF73F37FF7700070007037007837773777F73377FF007777700730
      70007733FFF77F37377707700077033707307F37773F7FFF7337080777070003
      3330737F3F7F777F333778080707770333333F7F737F3F7F3333080787070003
      33337F73FF737773333307800077033333337337773373333333}
    NumGlyphs = 2
  end
  object ChkAutoUpdate: TCheckBox
    Left = 280
    Top = 528
    Width = 97
    Height = 17
    Caption = 'Auto Update'
    TabOrder = 2
    OnClick = ChkAutoUpdateClick
  end
  object pcUsageTracker: TPageControl
    Left = 0
    Top = 0
    Width = 553
    Height = 521
    ActivePage = tsAllocation
    Align = alTop
    TabOrder = 3
    object tsAllocation: TTabSheet
      Caption = 'FastMM4 Allocation'
      object sgBlockStatistics: TStringGrid
        Left = 4
        Top = 4
        Width = 533
        Height = 481
        DefaultColWidth = 83
        DefaultRowHeight = 17
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        PopupMenu = smMM4Allocation
        ScrollBars = ssVertical
        TabOrder = 0
        ColWidths = (
          83
          104
          106
          106
          108)
      end
    end
    object tsVMGraph: TTabSheet
      Caption = 'VM Graph'
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 440
        Width = 38
        Height = 13
        Caption = 'Address'
      end
      object Label2: TLabel
        Left = 152
        Top = 440
        Width = 25
        Height = 13
        Caption = 'State'
      end
      object Label3: TLabel
        Left = 8
        Top = 468
        Width = 43
        Height = 13
        Caption = 'Exe/DLL'
      end
      object eAddress: TEdit
        Left = 60
        Top = 436
        Width = 81
        Height = 21
        Enabled = False
        TabOrder = 0
        Text = '$00000000'
      end
      object eState: TEdit
        Left = 184
        Top = 436
        Width = 105
        Height = 21
        Enabled = False
        TabOrder = 1
        Text = 'Unallocated'
      end
      object eDLLName: TEdit
        Left = 60
        Top = 464
        Width = 477
        Height = 21
        ReadOnly = True
        TabOrder = 2
      end
      object ChkSmallGraph: TCheckBox
        Left = 304
        Top = 436
        Width = 97
        Height = 21
        Caption = 'Small Map'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = ChkSmallGraphClick
      end
      object dgMemoryMap: TDrawGrid
        Left = 4
        Top = 4
        Width = 533
        Height = 425
        ColCount = 64
        DefaultColWidth = 8
        DefaultRowHeight = 8
        FixedCols = 0
        RowCount = 1024
        FixedRows = 0
        GridLineWidth = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        ScrollBars = ssVertical
        TabOrder = 4
        OnDrawCell = dgMemoryMapDrawCell
        OnSelectCell = dgMemoryMapSelectCell
      end
    end
    object tsVMDump: TTabSheet
      Caption = 'VM Dump'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 281
      ExplicitHeight = 165
      object sgVMDump: TStringGrid
        Left = 4
        Top = 4
        Width = 533
        Height = 481
        DefaultColWidth = 83
        DefaultRowHeight = 17
        FixedCols = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        PopupMenu = smVMDump
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = sgVMDumpDrawCell
        OnMouseDown = sgVMDumpMouseDown
        OnMouseUp = sgVMDumpMouseUp
        ColWidths = (
          83
          96
          60
          58
          209)
      end
    end
    object tsGeneralInformation: TTabSheet
      Caption = 'General Information'
      ImageIndex = 3
      object mVMStatistics: TMemo
        Left = 4
        Top = 4
        Width = 533
        Height = 481
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        PopupMenu = smGeneralInformation
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object tTimer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = tTimerTimer
    Left = 128
    Top = 512
  end
  object smVMDump: TPopupMenu
    Left = 100
    Top = 512
    object miVMDumpCopyAlltoClipboard: TMenuItem
      Caption = '&Copy All to Clipboard'
      OnClick = miVMDumpCopyAlltoClipboardClick
    end
  end
  object smGeneralInformation: TPopupMenu
    Left = 68
    Top = 512
    object miGeneralInformationCopyAlltoClipboard: TMenuItem
      Caption = '&Copy All to Clipboard'
      OnClick = miGeneralInformationCopyAlltoClipboardClick
    end
  end
  object smMM4Allocation: TPopupMenu
    Left = 36
    Top = 512
    object siMM4AllocationCopyAlltoClipboard: TMenuItem
      Caption = '&Copy All to Clipboard'
      OnClick = siMM4AllocationCopyAlltoClipboardClick
    end
  end
end
